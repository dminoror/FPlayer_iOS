//
//  PlaylistPage.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/6/10.
//  Copyright © 2020 dminoror. All rights reserved.
//

import UIKit

class PlaylistPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dataTable: UITableView!
    var playlist: fpPlaylist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightItem = UIBarButtonItem(title: "menu", style: .done, target: self, action: #selector(didRightItem_Clicked(sender:)))
        rightItem.tintColor = .red
        self.navigationItem.rightBarButtonItem = rightItem
        if let playlist = playlist {
            self.title = playlist.name
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc
    func didRightItem_Clicked(sender: UIBarButtonItem?) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = playlist?.list {
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "playlistCell")
        }
        if let list = playlist?.list {
            cell?.textLabel?.text = list[indexPath.row].name
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let playlist = playlist ,
            let playerItems = playlist.playitem,
            indexPath.row < playerItems.count {
            PlayerCore.shared.playWithPlayitems(playitems: playerItems, index: indexPath.row)
        }
        else {
            print("playerItem error")
        }
    }
}
