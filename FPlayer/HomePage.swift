//
//  HomePage.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/2/21.
//  Copyright © 2020 dminoror. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

enum FolderPathType {
    case Root
    case GoogleDrive(String)
    case Local(String)
}

class HomePage: UIViewController,
GIDSignInDelegate,
UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var table: UITableView!
    
    var folderPaths: [FolderPathType] = [.Root]
    var folderIndex = 0
    var currentFolder: [GTLRDrive_File]?
    var savedFolder = [[GTLRDrive_File]]()
    
    var gdAccountList = [GDAccount]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (GIDSignIn.sharedInstance()?.hasPreviousSignIn() ?? false) {
            GIDSignIn.sharedInstance()?.delegate = self
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        }
    }
    
    @IBAction func backButton_Clicked(_ sender: Any) {
        if (folderIndex > 0) {
            folderIndex -= 1
            if (folderIndex > 0) {
                savedFolder.removeLast()
                currentFolder = savedFolder.last
            }
            else {
                currentFolder = nil
            }
            table.reloadSections(IndexSet(integer: 0), with: .right)
        }
    }
    
    func refreshFolder() {
        switch folderPaths[folderIndex] {
            case .Root:
                backButton.isHidden = true
                break
            default:
                backButton.isHidden = false
        }
        
    }
    
    // MARK: TableView Delegates
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (folderIndex == 0) {
            return 1 + gdAccountList.count
        }
        else {
            return currentFolder?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        if (folderIndex == 0) {
            if (indexPath.row == 0) {
                cell = tableView.dequeueReusableCell(withIdentifier: "addDriveCell")
                if (cell == nil) {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "addDriveCell")
                }
                cell?.imageView?.image = UIImage(named: "addIcon")
                cell?.textLabel?.text = "Add a Google Drive"
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "googleDriveCell")
                if (cell == nil) {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "googleDriveCell")
                }
                cell?.imageView?.image = UIImage(named: "googleDriveIcon")
                let account = gdAccountList[indexPath.row - 1]
                cell?.textLabel?.text = account.email
            }
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "fileCell")
            if (cell == nil) {
                cell = UITableViewCell(style: .default, reuseIdentifier: "fileCell")
            }
            let file = currentFolder![indexPath.row]
            cell?.imageView?.image = UIImage(named: file.getIconType().rawValue)
            cell?.textLabel?.text = file.name
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (folderIndex == 0) {
            if (indexPath.row == 0) {
                if (gdAccountList.count == 0) {
                    GIDSignIn.sharedInstance()?.delegate = self
                    GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
                    GIDSignIn.sharedInstance()?.presentingViewController = self
                    GIDSignIn.sharedInstance()?.signIn()
                }
            }
            else if (indexPath.row == 1) {
                listGoogleFolder(service: gdAccountList[indexPath.row - 1].driveService, name: "root", completion: nil)
            }
        }
        else {
            let folder = currentFolder![indexPath.row]
            if (folder.getIconType() == .gdfolder) {
                listGoogleFolder(service: gdAccountList[0].driveService, name: folder.identifier!, completion: { () in
                    
                })
            }
        }
    }
    
    // MARK: Google Drive Functions
    func listGoogleFolder(service: GTLRDriveService, name: String, completion: (() -> Void)?) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "'\(name)' in parents"
        service.executeQuery(query) { [name, weak self] (_, result, error) in
            guard error == nil else {
                print("list folder fail: \(error!)")
                return
            }
            if let folderList = (result as? GTLRDrive_FileList)?.files {
                self?.folderPaths.append(.GoogleDrive(name))
                self?.folderIndex += 1
                var addList = [GTLRDrive_File]()
                for file in folderList {
                    if (file.getIconType() != .none){
                        addList.append(file)
                    }
                }
                self?.currentFolder = addList
                self?.savedFolder.append(addList)
                self?.table.reloadSections(IndexSet(integer: 0), with: .left)
            }
            completion?()
        }
    }
    
    // MARK: Google Login
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Include authorization headers/values with each Drive API request.
            print("login success: ")
            print((String(describing: GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken)))
            let account = GDAccount(user: user)
            gdAccountList.append(account)
            table.reloadData()
        }
        else {
            print("login error: ", error!)
        }
        GIDSignIn.sharedInstance()?.delegate = nil
    }
}
