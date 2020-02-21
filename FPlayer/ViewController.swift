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

class ViewController: UIViewController, GIDSignInDelegate, DLCachePlayerDataDelegate, DLCachePlayerStateDelegate {
    func playerPlayerItemChanged(_ playerItem: AVPlayerItem!) {
        
    }
    
    func playerDidReachEnd(_ playerItem: AVPlayerItem!) {
        
    }
    
    func playerDidPlayStateChanged(_ state: DLCachePlayerPlayState) {
        
    }
    
    func playerReadyToPlay() {
        
    }
    
    func playerFail(toPlay error: Error!) {
        
    }
    
    func playerPlayingChanged(_ isPlaying: Bool) {
        
    }
    
    
    func playerGetCurrentPlayURL(_ block: ((URL?, Bool) -> AVPlayerItem?)!) {
        let url = URL(string: "https://www.googleapis.com/drive/v3/files/1a6W8RFgIn8lsbRNLrdbUa0h_kvr23Kg3?alt=media") as! URL
        block(url, true)
    }
    
    func playerGetPreloadPlayURL(_ block: ((URL?, Bool) -> AVPlayerItem?)!) {
        block(nil, true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /*
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()*/
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
        
        DLCachePlayer.sharedInstance()?.setDelegate(self)
    }
    
    @IBAction func btnTest_Clicked(_ sender: Any) {
        
        DLCachePlayer.sharedInstance()?.resetAndPlay()
        
        
        //downloadFile()
          
        /*
        getFolderID(name: "OST", service: googleDriveService, user: googleUser!) { (identify) in
            print(identify)
        }*/
    }
    
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // A nil error indicates a successful login
        if (error == nil) {
            // Include authorization headers/values with each Drive API request.
            print("login success: ")
            self.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
            self.googleUser = user
            print(GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken)
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

