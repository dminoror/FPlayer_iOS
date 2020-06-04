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

class ViewController: UIViewController, GIDSignInDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
        GIDSignIn.sharedInstance()?.presentingViewController = self
        if ((GIDSignIn.sharedInstance()?.hasPreviousSignIn()) == true) {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        }
        else {
            GIDSignIn.sharedInstance()?.signIn()
        }
    }
    
    var player = AVPlayer()
    @IBAction func btnTest_Clicked(_ sender: Any) {
        /*
        var fileID: AudioFileID? = nil
        let path = String(format: "%@/tmp/sayonara.flac", NSHomeDirectory() as CVarArg)
        //let path = String(format: "%@/tmp/metadata", NSHomeDirectory() as CVarArg)
        let url = URL(fileURLWithPath: path)
        
        var status:OSStatus = AudioFileOpenURL(url as CFURL, .readPermission, kAudioFileFLACType, &fileID)
        
        guard status == noErr else {
            return
        }

        var dict: CFDictionary? = nil
        var dataSize = UInt32(MemoryLayout<CFDictionary?>.size(ofValue: dict))

        guard let audioFile = fileID else {
            return
        }

        status = AudioFileGetProperty(audioFile, kAudioFilePropertyInfoDictionary, &dataSize, &dict)

        guard status == noErr else {
            return
        }

        AudioFileClose(audioFile)

        guard let cfDict = dict else {
            return
        }

        let tagsDict = NSDictionary.init(dictionary: cfDict)
        print(tagsDict)
 */
        
        let path = String(format: "%@/tmp/sayonara.m4a", NSHomeDirectory() as CVarArg)
        //let path = String(format: "%@/tmp/metadata", NSHomeDirectory() as CVarArg)
        let file = FileHandle(forReadingAtPath: path)
        //file?.seek(toFileOffset: 10000)
        let data = file?.readData(ofLength: 1000)
        let string = String(data: data!, encoding: .unicode)
        print(string)
        
        
        
        //let asset = AVURLAsset(url: URL(string: "https://raw.githubusercontent.com/dohProject/DLCachePlayer/master/DLCachePlayerDemo/Sample/2.%20kare.m4a")!)
        //PlayerCore.shared.playWithPlayitems(playitems: nil, index: 0)
        
        
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

