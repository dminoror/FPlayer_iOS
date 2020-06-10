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
enum FilterType {
    case none
    case lossless
    case lossy
}

class HomePage: UIViewController,
GIDSignInDelegate,
UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var table: UITableView!
    
    var folderPaths: [FolderPathType] = [.Root]
    var folderIndex = 0
    var originFolder: [GTLRDrive_File]?
    var currentFolder: [GTLRDrive_File]?
    var savedFolder = [[GTLRDrive_File]]()
    var filterType: FilterType = .none
    
    var gdAccountList = [GDAccount]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (GIDSignIn.sharedInstance()?.hasPreviousSignIn() ?? false) {
            GIDSignIn.sharedInstance()?.delegate = self
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        }
        /*
        let string = Bundle.main.path(forResource: "01. さよならメモリーズ", ofType: "flac")
        let url = URL(fileURLWithPath: string!)
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        print(playerItem.asset.commonMetadata)*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didMiniPlayerClicked), name: NSNotification.Name(rawValue: "didMiniPlayerClicked"), object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func didMiniPlayerClicked(notification: Notification) {
        let page = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullPlayerPage")
        self.present(page, animated: true, completion: nil)
    }
    
    @IBAction func backButton_Clicked(_ sender: Any) {
        if (folderIndex > 0) {
            folderIndex -= 1
            if (folderIndex > 0) {
                savedFolder.removeLast()
                setFolder(newList: savedFolder.last)
            }
            else {
                currentFolder = nil
                setFolder(newList: nil)
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
    
    @objc
    func filter_Clicked() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "無", style: .default, handler: { [weak self] (action) in
            self?.filterType = .none
            self?.setFolder(newList: self?.originFolder)
            self?.table.reloadSections(IndexSet(integer: 0), with: .none)
        }))
        sheet.addAction(UIAlertAction(title: "lossless", style: .default, handler: { [weak self] (action) in
            self?.filterType = .lossless
            self?.setFolder(newList: self?.originFolder)
            self?.table.reloadSections(IndexSet(integer: 0), with: .none)
        }))
        sheet.addAction(UIAlertAction(title: "lossy", style: .default, handler: { [weak self] (action) in
            self?.filterType = .lossy
            self?.setFolder(newList: self?.originFolder)
            self?.table.reloadSections(IndexSet(integer: 0), with: .none)
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    func setFolder(newList: [GTLRDrive_File]?) {
        originFolder = newList
        currentFolder = originFolder?.filter({ (file) -> Bool in
            if (filterType == .lossless) {
                let fileType = file.getIconType()
                if (fileType == .flac || fileType == .gdfolder) {
                    return true
                }
                return false
            }
            else if (filterType == .lossy) {
                let fileType = file.getIconType()
                if (fileType == .mp3 || fileType == .m4a || fileType == .gdfolder) {
                    return true
                }
                return false
            }
            return true
        })
    }
    
    // MARK: TableView Delegates
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if (header == nil) {
            header = UITableViewHeaderFooterView(reuseIdentifier: "header")
            let background = UIView()
            background.translatesAutoresizingMaskIntoConstraints = false
            background.backgroundColor = .gray
            header?.addSubview(background)
            header?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[background]|", options: .directionLeadingToTrailing, metrics: nil, views: ["background" : background]))
            header?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[background]|", options: .directionLeadingToTrailing, metrics: nil, views: ["background" : background]))
            let sorter = UIButton()
            sorter.translatesAutoresizingMaskIntoConstraints = false
            sorter.setTitle("排序", for: .normal)
            sorter.contentHorizontalAlignment = .center
            sorter.titleLabel?.textAlignment = .center
            background.addSubview(sorter)
            background.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[sorter]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["sorter" : sorter]))
            let filter = UIButton()
            filter.translatesAutoresizingMaskIntoConstraints = false
            filter.setTitle("過濾", for: .normal)
            filter.backgroundColor = .clear
            filter.contentHorizontalAlignment = .center
            filter.addTarget(self, action: #selector(filter_Clicked), for: .touchUpInside)
            background.addSubview(filter)
            background.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[filter]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["filter" : filter]))
            background.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[sorter]-0-[filter(sorter)]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["sorter" : sorter, "filter" : filter]))
        }
        return header
    }
    
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
            let type = folder.getIconType()
            if (type == .gdfolder) {
                listGoogleFolder(service: gdAccountList[0].driveService, name: folder.identifier!, completion: { () in
                    
                })
            }
            else if (type == .mp3 || type == .m4a || type == .flac) {
                //PlayerCore.shared.playerWithURL(url: "https://www.googleapis.com/drive/v3/files/\(folder.identifier!)?alt=media")
                
                guard let currentFile = currentFolder?[optional: indexPath.row] else { return }
                var index = 0
                var playitems = [Playitem]()
                guard let folder = originFolder else { return }
                for file in folder {
                    let type = file.getIconType()
                    if (file == currentFile) {
                        index = playitems.count
                    }
                    if (filterType == .lossless) {
                        if (type == .flac) {
                            let playitem = Playitem(file: file)
                            playitems.append(playitem)
                        }
                    }
                    else if (filterType == .lossy) {
                        if (type == .mp3 || type == .m4a) {
                            let playitem = Playitem(file: file)
                            playitems.append(playitem)
                        }
                    }
                    else if (filterType == .none) {
                        if (type == .flac ||
                            type == .mp3 || type == .m4a) {
                            let playitem = Playitem(file: file)
                            playitems.append(playitem)
                        }
                    }
                }
                PlayerCore.shared.playWithPlayitems(playitems: playitems, index: index)
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
                addList = addList.sorted(by: { (file1, file2) -> Bool in
                    let type1 = file1.getIconType() == .gdfolder, type2 = file2.getIconType() == .gdfolder
                    if (type1 && !type2) { return true }
                    else if (type2 && !type1) { return false }
                    return file1.name?.compare(file2.name!, options: .numeric) == .orderedAscending
                })
                self?.setFolder(newList: addList)
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
            GDUtility.shared.setupCurrentService(user: user)
            gdAccountList.append(account)
            table.reloadData()
        }
        else {
            print("login error: ", error!)
        }
        GIDSignIn.sharedInstance()?.delegate = nil
    }
}
