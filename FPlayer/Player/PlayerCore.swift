//
//  PlayerCore.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/3/17.
//  Copyright © 2020 dminoror. All rights reserved.
//

import Foundation

enum playerMetadataType: String {
    case title = "title"
    case album = "albumName"
    case artist = "artist"
    case artwork = "artwork"
}

class PlayerCore: NSObject, DLCachePlayerDataDelegate, DLCachePlayerStateDelegate {
    
    static let shared = PlayerCore()
    
    var currentMetadata: [String : AVMetadataItem]?
    
    override init() {
        super.init()
        DLCachePlayer.sharedInstance()?.setDelegate(self)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
    }
    
    var playlist: [Playitem]?
    var playIndex = 0
    
    // MARK: Player Info
    func metadata(type: playerMetadataType) -> Any? {
        if let metadata = currentMetadata?[type.rawValue] {
            if (type == .artwork) {
                if let data = metadata.value as? Data {
                    return UIImage(data: data)
                }
            }
            else {
                if let string = metadata.value as? String {
                    return string
                }
            }
        }
        return nil
    }
    func currentTime() -> TimeInterval? {
        return DLCachePlayer.sharedInstance()?.currentTime()
    }
    func totalTime() -> TimeInterval? {
        return DLCachePlayer.sharedInstance().currentDuration()
    }
    func playState() -> DLCachePlayerPlayState {
        return DLCachePlayer.sharedInstance()?.playState ?? .stop
    }
    
    // MARK: DLCachePlayer Action
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
    func next() {
        if let playlist = playlist {
            playIndex += 1
            if (playIndex >= playlist.count) {
                playIndex = 0
            }
            DLCachePlayer.sharedInstance()?.resetAndPlay()
        }
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
        DLCachePlayer.sharedInstance()?.seek(toTimeInterval: time, completionHandler: nil)
    }
    
    // MARK: DLCachePlayer Delegate
    func playWithPlayitems(playitems: [Playitem]?, index: Int) {
        playlist = playitems
        playIndex = index
        DLCachePlayer.sharedInstance()?.resetAndPlay()
    }
    
    func playerGetCurrentPlayURL(_ block: ((URL?, Bool) -> AVPlayerItem?)!) {
        //https://www.googleapis.com/drive/v3/files/1KHyOzaHF2y43rhn0y_HHY2lMPiujk1Jt?alt=media  playable
        //https://www.googleapis.com/drive/v3/files/1JzVt83KGCOY7kOA844O-PLcwC3FHOr_8?alt=media  no play
        //https://www.googleapis.com/drive/v3/files/1hQ6O0dog7SoDax9poGG21bML56pYvWNv?alt=media  playable flac
        //https://www.googleapis.com/drive/v3/files/1rvD5sojO4XPHLU3DJZC1A_2I_uBh14mj?alt=media  no play flac
        
        //block(URL(string: "https://www.googleapis.com/drive/v3/files/1rvD5sojO4XPHLU3DJZC1A_2I_uBh14mj?alt=media"), true)
        
        //block(URL(string: "https://www.googleapis.com/drive/v3/files/1KHyOzaHF2y43rhn0y_HHY2lMPiujk1Jt?alt=media"), true)
        //block(URL(string: "https://www.googleapis.com/drive/v3/files/1JzVt83KGCOY7kOA844O-PLcwC3FHOr_8?alt=media"), true)
        //return
        if let playitem = playlist?[optional: playIndex] {
            if let url = URL.urlFromString(string: playitem.getPlayURL()) {
                _ = block(url, true)
            }
        }
    }
    /*
    func playerGetPreloadPlayURL(_ block: ((URL?, Bool) -> AVPlayerItem?)!) {
        guard let index = playIndex else { return }
        if let playitem = playlist?[optional: index + 1] {
            if let url = URL.urlFromString(string: playitem.getPlayURL()) {
                _ = block(url, true)
            }
        }
    }*/
    func playerCacheProgress(_ playerItem: AVPlayerItem!, isCurrent: Bool, tasks: NSMutableArray!, totalBytes: UInt) {
        if (isCurrent) {
            NotificationCenter.default.post(name: NSNotification.Name("playerCacheProgress"), object: ["tasks" : tasks!, "totalBytes": totalBytes])
        }
    }
    
    func playerPlayerItemChanged(_ playerItem: AVPlayerItem!) {
        currentMetadata = nil
        NotificationCenter.default.post(name: NSNotification.Name("playerPlayerItemChanged"), object: nil)
    }
    func playerGotMetadata(_ metadatas: [AVMetadataItem]!) {
        currentMetadata = metadatas.reduce(into: [String : AVMetadataItem]()) { (dict, metadata) in
            if let key = metadata.commonKey?.rawValue {
                dict.updateValue(metadata, forKey: key)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("playerGotMetadata"), object: nil)
    }
    func playerDidPlayStateChanged(_ state: DLCachePlayerPlayState) {
        NotificationCenter.default.post(name: NSNotification.Name("playerDidPlayStateChanged"), object: nil)
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
