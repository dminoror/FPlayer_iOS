//
//  GDUtility.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/6/9.
//  Copyright © 2020 dminoror. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GTMSessionFetcher
import GoogleSignIn

class GDUtility {
    
    static let shared = GDUtility()
    
    var gdCache: [String : [GTLRDrive_File]]?
    var service = GTLRDriveService()
    var ostFolder: GTLRDrive_File?
    
    func setupCurrentService(user: GIDGoogleUser) {
        service.authorizer = user.authentication.fetcherAuthorizer()
        service.shouldFetchNextPages = true
        listGoogleFolder(identify: "root") { (files) in
            if let folder = files?.first(where: { (file) -> Bool in
                return file.name! == "OST"
            }) {
                self.ostFolder = folder
                print("OST folder found")
            }
        }
    }
    
    func fetchGDItem(playlists: [fpPlaylist], completion: @escaping (([fpPlaylist]) -> Void)) {
        gdCache = [String : [GTLRDrive_File]]()
        
        fetchGDItemQueue(playlists: playlists, playlistIndex: 0, playitemIndex: 0) { [playlists] in
            print("fetch playlist finished")
            //LocalDatabase.shared.savePlaylists(playlists: playlists)
            completion(playlists)
        }
    }
    func fetchGDItemQueue(playlists: [fpPlaylist], playlistIndex: Int, playitemIndex: Int, completion: @escaping (() -> Void)) {
        let playlist = playlists[playlistIndex]
        if let playitem = playlist.list?[playitemIndex] {
            let gdID = playitem.gdID
            let folders = playitem.folders
            if ((gdID != nil && gdID!.count > 0) || folders == nil) {
                print("exist playitem = \(String(describing: folders!.last)) : \(String(describing: playitem.gdID))")
                var playitemIndex = playitemIndex + 1
                var playlistIndex = playlistIndex
                if (playitemIndex >= playlist.list!.count) {
                    playitemIndex = 0
                    playlistIndex += 1
                    if (playlistIndex >= playlists.count) {
                        completion()
                        return
                    }
                }
                fetchGDItemQueue(playlists: playlists, playlistIndex: playlistIndex, playitemIndex: playitemIndex, completion: completion)
            }
            else {
                fetchGDFolders(head: ostFolder!, folders: folders!) { [playlists, playlistIndex, playitemIndex, completion, weak self] (file) in
                    guard let weakSelf = self else { return }
                    if let file = file {
                        playitem.gdID = file.identifier
                    }
                    print("\(String(describing: folders!.last)) : \(String(describing: playitem.gdID))")
                    //LocalDatabase.shared.savePlaylists(playlists: playlists)
                    var playitemIndex = playitemIndex + 1
                    var playlistIndex = playlistIndex
                    if (playitemIndex >= playlist.list!.count) {
                        playitemIndex = 0
                        playlistIndex += 1
                        if (playlistIndex >= playlists.count) {
                            completion()
                            return
                        }
                    }
                    weakSelf.fetchGDItemQueue(playlists: playlists, playlistIndex: playlistIndex, playitemIndex: playitemIndex, completion: completion)
                }
            }
        }
        else {
            print("error")
        }
    }
    func fetchGDFolders(head: GTLRDrive_File, folders: [String], completion: @escaping ((GTLRDrive_File?) -> Void)) {
        let nextFolderName = folders.first
        let identifier = head.identifier!
        if let existFolder = gdCache![identifier] {
            if let nextFolder = existFolder.first(where: { (file) -> Bool in
                return file.name == nextFolderName
            }) {
                if (folders.count == 1) {
                    completion(nextFolder)
                }
                else {
                    var folders = folders
                    folders.remove(at: 0)
                    fetchGDFolders(head: nextFolder, folders: folders, completion: completion)
                }
                return
            }
            else {
                print("nextFolderName not found")
                //_ = fileList.map({ print($0.name!) })
                completion(nil)
            }
            return
        }
        listGoogleFolder(identify: identifier) { [identifier, nextFolderName, folders, completion, weak self] (fileList) in
            if let fileList = fileList,
                let weakSelf = self {
                weakSelf.gdCache!.updateValue(fileList, forKey: identifier)
                if let nextFolder = fileList.first(where: { (file) -> Bool in
                    return file.name == nextFolderName
                }) {
                    if (folders.count == 1) {
                        completion(nextFolder)
                    }
                    else {
                        var folders = folders
                        folders.remove(at: 0)
                        weakSelf.fetchGDFolders(head: nextFolder, folders: folders, completion: completion)
                    }
                    return
                }
                else {
                    print("nextFolderName not found")
                    //_ = fileList.map({ print($0.name!) })
                    completion(nil)
                }
            }
            //print("error")
        }
    }
    
    func listGoogleFolder(identify: String, completion: @escaping ([GTLRDrive_File]?) -> Void) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "'\(identify)' in parents"
        service.executeQuery(query) { [completion] (_, result, error) in
            guard error == nil else {
                print("list folder fail: \(error!)")
                completion(nil)
                return
            }
            if let folder = result as? GTLRDrive_FileList {
                let files = folder.files
                completion(files)
            }
            else {
                completion(nil)
            }
        }
    }
    

}

