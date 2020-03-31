//
//  PlayerObjects.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/3/20.
//  Copyright © 2020 dminoror. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

class Playitem {
    var name: String?
    
    var playURL: [String]?
    
    required init() {
        
        playURL = [String]()
    }
    convenience init(file: GTLRDrive_File) {
        self.init()
        playURL?.append("https://www.googleapis.com/drive/v3/files/\(file.identifier!)?alt=media")
        name = file.name
    }
    
    func getPlayURL() -> String? {
        return playURL?.first
    }
}
