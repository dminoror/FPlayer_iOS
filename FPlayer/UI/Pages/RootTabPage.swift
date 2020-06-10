//
//  RootTabPage.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/6/10.
//  Copyright © 2020 dminoror. All rights reserved.
//

import UIKit

class RootTabPage: UITabBarController {
    override func loadView() {
        super.loadView()
        
       
    }
    //var miniPlayer: MiniPlayerView?
    override func viewDidLoad() {
        super.viewDidLoad()
        let rect = CGRect(x: 0, y: UIScreen.main.bounds.height - 60 - self.tabBar.frame.height, width: UIScreen.main.bounds.width, height: 60)
        let miniplayer = MiniPlayerView(frame: rect)
        miniplayer.layer.zPosition = 10
        //self.miniPlayer = miniplayer
        self.view.addSubview(miniplayer)
    }
}
