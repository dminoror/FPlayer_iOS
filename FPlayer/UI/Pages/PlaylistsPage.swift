//
//  PlaylistsPage.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/6/10.
//  Copyright © 2020 dminoror. All rights reserved.
//

import UIKit

class PlaylistsPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dataTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightItem = UIBarButtonItem(title: "menu", style: .done, target: self, action: #selector(didRightItem_Clicked(sender:)))
        rightItem.tintColor = .red
        self.navigationItem.rightBarButtonItem = rightItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataTable.reloadData()
    }
    
    @objc
    func didRightItem_Clicked(sender: UIBarButtonItem?) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let playlists = LocalDatabase.shared.playlists {
            return playlists.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "playlistCell")
        }
        if let playlists = LocalDatabase.shared.playlists {
            let playlist = playlists[indexPath.row]
            cell?.textLabel?.text = playlist.name
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let playlists = LocalDatabase.shared.playlists {
            let playlist = playlists[indexPath.row]
            let page = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaylistPage") as! PlaylistPage
            page.playlist = playlist
            self.navigationController?.pushViewController(page, animated: true)
        }
    }
}
