//
//  LocalDatabase.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/6/10.
//  Copyright © 2020 dminoror. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

class LocalDatabase {
    
    static let shared = LocalDatabase()
    
    var ostFolder: GTLRDrive_File?
    var playlists: [fpPlaylist]?
    
    required init() {
        loadPlaylists()
        fetchPlaylists {
            print("playlistsFetchFinished")
            NotificationCenter.default.post(name: NSNotification.Name("playlistsFetchFinished"), object: nil)
        }
        /*
        if (playlists == nil) {
            fetchPlaylists(completion: nil)
        }*/
    }
    
    
    func fetchPlaylists(completion: (() -> Void)?) {
        if let playlists = playlists {
            GDUtility.shared.fetchGDItem(playlists: playlists) { (playlists) in
                LocalDatabase.shared.savePlaylists(playlists: playlists)
                if let completion = completion {
                    completion()
                }
            }
            return
        }
        let url = URL(string: "https://raw.githubusercontent.com/dminoror/FPlayer/master/FPlayer/bin/Debug/playlistDB.json")!
        URLSession.shared.dataTask(with: url) { [weak self, completion] (data, response, error) in
            guard let weakSelf = self else { return }
            if let data = data {
                let dict = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Dictionary<String, Any>
                if let playlistsData = (dict?["playlists"] as? Array<Any>)?.jsonData() {
                    if let playlists = try? JSONDecoder().decode([fpPlaylist].self, from: playlistsData) {
                        weakSelf.playlists = playlists
                        LocalDatabase.shared.savePlaylists(playlists: playlists)
                        LocalDatabase.shared.fetchPlaylists(completion: completion)
                        return
                    }
                }
            }
            print("fetch playlist fail")
        }.resume()
    }
    func loadPlaylists() {
        do {
            let path = URL(fileURLWithPath: String(format: "%@/Library/playlists", NSHomeDirectory()))
            let data = try Data(contentsOf: path)
            playlists = try JSONDecoder().decode([fpPlaylist].self, from: data)
            print(playlists)
        }
        catch {
            print(error)
        }
    }
    func savePlaylists(playlists: [fpPlaylist]) {
        do {
            let data = try JSONEncoder().encode(playlists)
            let path = URL(fileURLWithPath: String(format: "%@/Library/playlists", NSHomeDirectory()))
            //print(path)
            try data.write(to: path)
            //print("Save playlists Successed")
        }
        catch {
            print(error)
        }
    }
    
}
