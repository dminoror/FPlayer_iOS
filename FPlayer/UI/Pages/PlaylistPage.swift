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
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlayerItemChanged), name: NSNotification.Name("playerPlayerItemChanged"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func playerPlayerItemChanged() {
        DispatchQueue.main.async {
            print("playeritem changed")
            self.dataTable.reloadData()
        }
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
        cell?.tag = indexPath.row
        if let list = playlist?.list {
            let playableItem = list[indexPath.row]
            cell?.textLabel?.text = playableItem.name
            if (PlayerCore.shared.currentPlayableItem === playableItem) {
                cell?.backgroundColor = UIColor(named: "MaxTrack")
            }
            else {
                cell?.backgroundColor = UIColor(named: "Background")
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let playlist = playlist,
            let items = playlist.list,
            indexPath.row < items.count {
            PlayerCore.shared.playWithPlayitems(playitems: items, index: indexPath.row)
        }
        else {
            print("playerItem error")
        }
    }
}
