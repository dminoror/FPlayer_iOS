//
//  MiniPlayerView.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/3/11.
//  Copyright © 2020 dminoror. All rights reserved.
//

import UIKit

class MiniPlayerView: UIView {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "MiniPlayerView", bundle: bundle)
        ///透過nib來取得xibView
        let xibView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        addSubview(xibView)
        ///設置xibView的Constraint
        xibView.translatesAutoresizingMaskIntoConstraints = false
        xibView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        xibView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        xibView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        xibView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    @IBAction func miniPlayer_Clicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("didMiniPlayerClicked"), object: nil)
    }
    
    @IBAction func playButton_Clicked(_ sender: Any) {
        
    }
    
}
