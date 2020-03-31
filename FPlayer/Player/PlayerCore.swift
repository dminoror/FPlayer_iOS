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
    }
    
    var playlist: [Playitem]?
    var playIndex: Int?
    
    func getCurrentMetadata(type: playerMetadataType) -> Any? {
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
    func getCurrentTime() -> TimeInterval? {
        return DLCachePlayer.sharedInstance()?.currentTime()
    }
    func getTotalTime() -> TimeInterval? {
        return DLCachePlayer.sharedInstance().currentDuration()
    }
    
    func playWithPlayitems(playitems: [Playitem]?, index: Int) {
        playlist = playitems
        playIndex = index
        DLCachePlayer.sharedInstance()?.resetAndPlay()
    }
    
    func playerGetCurrentPlayURL(_ block: ((URL?, Bool) -> AVPlayerItem?)!) {
        /*
        block(URL(string: "https://raw.githubusercontent.com/dohProject/DLCachePlayer/master/DLCachePlayerDemo/Sample/2.%20kare.m4a"), true)
        return*/
        guard let index = playIndex else { return }
        if let playitem = playlist?[optional: index] {
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
