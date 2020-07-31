//
//  ViewController.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/2/19.
//  Copyright © 2020 dminoror. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import TagLibIOS

class ViewController: UIViewController, GIDSignInDelegate {
    
    var ostFolder: GTLRDrive_File?
    var playlists: [fpPlaylist]?
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
        GIDSignIn.sharedInstance()?.presentingViewController = self
        if ((GIDSignIn.sharedInstance()?.hasPreviousSignIn()) == true) {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        }
        else {
            GIDSignIn.sharedInstance()?.signIn()
        }*/
        
        //loadPlaylists()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        //btnTest_Clicked(0)
    }
    func didSignIn() {
        
    }
    
    var player = AVPlayer()
    @IBAction func btnTest_Clicked(_ sender: Any) {
        /*
        if let playlists = playlists {
            self.fetchGDItem(playlists: playlists)
            return
        }
        let url = URL(string: "https://raw.githubusercontent.com/dminoror/FPlayer/master/FPlayer/bin/Debug/playlistDB.json")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let dict = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Dictionary<String, Any>
                if let playlistsData = (dict?["playlists"] as? Array<Any>)?.jsonData() {
                    if let playlists = try? JSONDecoder().decode([fpPlaylist].self, from: playlistsData) {
                        self.fetchGDItem(playlists: playlists)
                        return
                    }
                }
            }
            print("fetch playlist fail")
        }.resume()*/
    }
    /*
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
    
    var gdCache: [String : [GTLRDrive_File]]?
    func fetchGDItem(playlists: [fpPlaylist]) {
        gdCache = [String : [GTLRDrive_File]]()
        
        fetchGDItemQueue(playlists: playlists, playlistIndex: 0, playitemIndex: 0) { [playlists, weak self] in
            print("fetch playlist finished")
            /*
            guard let weakSelf = self else { return }
            weakSelf.savePlaylists(playlists: playlists)*/
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
                    weakSelf.savePlaylists(playlists: playlists)
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
        GDUtility.listGoogleFolder(service: googleDriveService, identify: identifier) { [identifier, nextFolderName, folders, completion, weak self] (fileList) in
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
    */
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // A nil error indicates a successful login
        if (error == nil) {
            // Include authorization headers/values with each Drive API request.
            print("login success: ")
            self.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
            self.googleDriveService.shouldFetchNextPages = true
            self.googleUser = user
            print(GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken)
            didSignIn()
        } else {
            print("login error: ", error!)
            self.googleDriveService.authorizer = nil
            self.googleUser = nil
        }
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func getFolderID(
        name: String,
        service: GTLRDriveService,
        user: GIDGoogleUser,
        completion: @escaping (String?) -> Void) {
        
        
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "'1tRJdjag-2u21uY0wyLsrtuXmPzaPwISO' in parents"
        // ost 1E8KDO0oEhjDyZPZ5v83iz51t9rk-z3i7
        // single 1tRJdjag-2u21uY0wyLsrtuXmPzaPwISO
        // japan tunes 1jZmNIIjSDGqgCC2lMnS_RUZnQu8VScSV
        // 旅行途中 1a6W8RFgIn8lsbRNLrdbUa0h_kvr23Kg3
        
        //query.pageSize = 10
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            if let folderList = (result as? GTLRDrive_FileList)?.files {
                
                for file in folderList {
                    print(file.name, file.mimeType, file.identifier)
                }
                
            }
        }
    }
    var bytesCount: Int = 0
    func downloadFile() {
        
        let query = GTLRDriveQuery_FilesGet.query(withFileId: "1jZmNIIjSDGqgCC2lMnS_RUZnQu8VScSV")
        query.downloadAsDataObjectType = "media"
        query.additionalHTTPHeaders = ["Range":"bytes=4000000-"]
        let ticket = googleDriveService.executeQuery(query) { (ticket, result, error) in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            print(result)
            
        }//7083768
        
        bytesCount = 0
        ticket.objectFetcher?.accumulateDataBlock = { (data) in
            self.bytesCount += data?.count ?? 0
            print("data count = \(self.bytesCount)")
        }
    
    }
    
    @objc func fileDownloaded() {
        
    }

}

