//
//  PlayerCore.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/3/17.
//  Copyright © 2020 dminoror. All rights reserved.
//

import Foundation
import MediaPlayer

enum playerMetadataType: String {
    case title = "title"
    case album = "albumName"
    case artist = "artist"
    case artwork = "artwork"
}

enum playerRandomMode {
    case none, random
}
enum playerLoopMode {
    case none, loop, single
}

class PlayerCore: NSObject, DLCachePlayerDataDelegate, DLCachePlayerStateDelegate {
    
    static let shared = PlayerCore()
    
    override init() {
        super.init()
        DLCachePlayer.sharedInstance()?.setDelegate(self)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
        let remoteCenter = MPRemoteCommandCenter.shared()
        remoteCenter.previousTrackCommand.isEnabled = true
        remoteCenter.previousTrackCommand.addTarget(self, action: #selector(didPrevCommand_Received))
        remoteCenter.nextTrackCommand.isEnabled = true
        remoteCenter.nextTrackCommand.addTarget(self, action: #selector(didNextCommand_Received))
        remoteCenter.playCommand.isEnabled = true
        remoteCenter.playCommand.addTarget(self, action: #selector(didPlayPauseCommand_Received))
        remoteCenter.pauseCommand.isEnabled = true
        remoteCenter.pauseCommand.addTarget(self, action: #selector(didPlayPauseCommand_Received))
    }
    
    var playlist: [PlaylistItem]?
    var playIndex = 0
    var currentPlaylistItem: PlaylistItem?
    var currentPlayerItem: DLPlayerItem?
    var randomPlaylist: [PlaylistItem]?
    var randomMode: playerRandomMode = .random
    var loopMode: playerLoopMode = .loop
    
    // MARK: Player Info
    
    func currentTime() -> TimeInterval? {
        return DLCachePlayer.sharedInstance()?.currentTime()
    }
    func totalTime() -> TimeInterval? {
        return DLCachePlayer.sharedInstance().currentDuration()
    }
    func playState() -> DLCachePlayerPlayState {
        return DLCachePlayer.sharedInstance()?.playState ?? .stop
    }
    var currentTitle: String? {
        get {
            if let value = currentPlayerItem?.metadata?["title"] as? String {
                return value
            }
            if let value = currentPlaylistItem?.name {
                return value
            }
            return nil
        }
    }
    var currentArtist: String? {
        get {
            if let value = currentPlayerItem?.metadata?["artist"] as? String {
                return value
            }
            return nil
        }
    }
    var currentArtwork: UIImage? {
        get {
            if let value = currentPlayerItem?.metadata?["artwork"] as? UIImage {
                return value
            }
            return nil
        }
    }
    
    // MARK: DLCachePlayer Action
    @objc
    func switchState() {
        if (DLCachePlayer.sharedInstance()?.playState == .pause) {
            DLCachePlayer.sharedInstance()?.resume()
        }
        else if (DLCachePlayer.sharedInstance()?.playState == .stop) {
            DLCachePlayer.sharedInstance()?.resetAndPlay()
        }
        else if (DLCachePlayer.sharedInstance()?.playState == .playing) {
            DLCachePlayer.sharedInstance()?.pause()
        }
    }
    
    @objc
    func didPlayPauseCommand_Received() -> MPRemoteCommandHandlerStatus {
        switchState()
        return .success
    }
    @objc
    func didNextCommand_Received() -> MPRemoteCommandHandlerStatus {
        next()
        return .success
    }
    @objc
    func didPrevCommand_Received() -> MPRemoteCommandHandlerStatus {
        prev()
        return .success
    }
    
    func getNextPlayerIndex() -> Int? {
        if (loopMode == .single) {
            return playIndex
        }
        let list = (randomMode == .none) ? playlist : randomPlaylist
        if let list = list {
            var index = playIndex + 1
            if (index >= list.count) {
                if (loopMode == .loop) {
                    index = 0
                }
                else {
                    return nil
                }
            }
            return index
        }
        return nil
    }
    func getPlaylistItem(index: Int) -> PlaylistItem? {
        if (randomMode == .none) {
            return playlist?[index]
        }
        else {
            return randomPlaylist?[index]
        }
    }
    func next() {
        if let index = getNextPlayerIndex() {
            playIndex = index
        }
        DLCachePlayer.sharedInstance()?.resetAndPlay()
    }
    func prev() {
        if let playlist = playlist {
            playIndex -= 1
            if (playIndex < 0) {
                playIndex = playlist.count - 1
            }
            DLCachePlayer.sharedInstance()?.resetAndPlay()
        }
    }
    func seek(time: TimeInterval) {
        DLCachePlayer.sharedInstance()?.seek(toTimeInterval: time, completionHandler: { (result) in
            if (result) {
                if var playerInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo,
                    let currentTime = PlayerCore.shared.currentTime() {
                    playerInfo.updateValue(currentTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = playerInfo
                }
            }
        })
    }
    func switchRandom() {
        switch randomMode {
        case .none:
            randomMode = .random
            makeRandomPlaylist()
        case .random:
            randomMode = .none
        }
    }
    func makeRandomPlaylist() {
        randomPlaylist = playlist?.shuffled()
    }
    func switchLoop() {
        switch loopMode {
        case .none:
            loopMode = .loop
        case .loop:
            loopMode = .single
        case .single:
            loopMode = .none
        }
    }
    
    
    // MARK: DLCachePlayer Delegate
    func playWithPlayitems(playitems: [PlaylistItem]?, index: Int) {
        playlist = playitems
        makeRandomPlaylist()
        if (randomMode == .none) {
            playIndex = index
        }
        else {
            let randIndex = (randomPlaylist?.firstIndex(where: { (item) -> Bool in
                return item === playitems![index]
            }))!
            playIndex = randIndex
        }
        DLCachePlayer.sharedInstance()?.resetAndPlay()
    }
    
    func playerGetCurrentPlayerItem(_ block: ((DLPlayerItem?, Bool) -> DLPlayerItem?)!) {
        if let playlistItem = getPlaylistItem(index: playIndex),
            let url = URL.urlFromString(string: playlistItem.getPlayURL()) {
            let playerItem = DLPlayerItem()
            playerItem.url = url
            playerItem.identify = playlistItem.identify
            currentPlaylistItem = playlistItem
            currentPlayerItem = block(playerItem, true)
            if (currentPlayerItem?.metadata != nil) {
                playerGotMetadata(currentPlayerItem, metadata: currentPlayerItem?.metadata)
            }
        }
    }
    
    func playerGetPreloadPlayerItem(_ block: ((DLPlayerItem?, Bool) -> DLPlayerItem?)!) {
        if let nextIndex = getNextPlayerIndex(),
            let playlistItem = getPlaylistItem(index: nextIndex),
            let url = URL.urlFromString(string: playlistItem.getPlayURL()) {
            let playerItem = DLPlayerItem()
            print("preload next item: \(playlistItem.name!)")
            playerItem.url = url
            playerItem.identify = playlistItem.identify
            _ = block(playerItem, true)
        }
    }
    func playerCacheProgress(_ playerItem: DLPlayerItem!, tasks: NSMutableArray!, totalBytes: UInt) {
        if (playerItem === currentPlaylistItem) {
            NotificationCenter.default.post(name: NSNotification.Name("playerCacheProgress"), object: ["tasks" : tasks!, "totalBytes": totalBytes])
        }
    }
    
    func playerPlayerItemChanged(_ playerItem: AVPlayerItem!) {
        NotificationCenter.default.post(name: NSNotification.Name("playerPlayerItemChanged"), object: nil)
    }
    func playerGotMetadata(_ playerItem: DLPlayerItem!, metadata metadatas: [AnyHashable : Any]!) {
        let newMetadata = playerItem.metadata!.reduce(into: [String : Any]()) { (dict, metadata) in
            if let key = metadata.key as? String {
                if let value = metadata.value as? Data,
                    key.contains("artwork"),
                    let image = UIImage(data: value) {
                    dict.updateValue(image, forKey: "artwork")
                }
                else {
                    dict.updateValue(metadata.value, forKey: key)
                }
            }
        }
        playerItem.metadata = newMetadata
        if playerItem === currentPlayerItem {
            var playerInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo != nil ? MPNowPlayingInfoCenter.default().nowPlayingInfo! : [String : Any]()
            if let title = currentTitle {
                playerInfo.updateValue(title, forKey: MPMediaItemPropertyTitle)
            }
            if let artist = currentArtist {
                playerInfo.updateValue(artist, forKey: MPMediaItemPropertyArtist)
            }
            if let artwork = currentArtwork {
                let mpmedia = MPMediaItemArtwork(boundsSize: artwork.size) { (size) -> UIImage in
                    return artwork
                }
                playerInfo.updateValue(mpmedia, forKey: MPMediaItemPropertyArtwork)
            }
            if let currentTime = currentTime() {
                playerInfo.updateValue(currentTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
            }
            if let currentDuration = totalTime() {
                playerInfo.updateValue(currentDuration, forKey: MPMediaItemPropertyPlaybackDuration)
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = playerInfo
            NotificationCenter.default.post(name: NSNotification.Name("playerGotMetadata"), object: nil)
        }
    }
    func playerDidPlayStateChanged(_ state: DLCachePlayerPlayState) {
        NotificationCenter.default.post(name: NSNotification.Name("playerDidPlayStateChanged"), object: nil)
        if var playerInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo,
            let rate = state == .playing ? 1.0 : 0.0 {
            playerInfo.updateValue(rate, forKey: MPNowPlayingInfoPropertyPlaybackRate)
            if let currentTime = currentTime() {
                playerInfo.updateValue(currentTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = playerInfo
        }
    }
    func playerDidReachEnd(_ playerItem: AVPlayerItem!) {
        print("did Reach End")
        next()
    }
    
    func playerReadyToPlay() {
        print("Ready to play")
    }
    
    func playerFail(toPlay error: Error!) {
        print("Play fail, error = \(String(describing: error))")
    }
    func playerDidFail(_ playerItem: AVPlayerItem!, isCurrent: Bool, error: Error!) {
        print("Play did fail, error = \(String(describing: error))")
    }
    
}
