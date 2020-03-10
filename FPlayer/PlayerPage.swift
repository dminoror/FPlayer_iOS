//
//  PlayerPage.swift
//  FPlayer
//
//  Created by DoubleLight on 2020/3/4.
//  Copyright © 2020 dminoror. All rights reserved.
//

import UIKit

class PlayerPage: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var loopButton: UIButton!
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var playlistButton: UIButton!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressSlider: DLProgressSlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = self.view.frame.width
        let playRowWidth = (width - (32 * 2) - playButton.frame.width - (nextButton.frame.width * 2)) / 4
        let secondRowWidth = (width - (20 * 2) - (closeButton.frame.width * 4)) / 3
        for constraint in self.view.constraints {
            if let identifier = constraint.identifier {
                if (identifier == "playRow") {
                    constraint.constant = playRowWidth
                }
                else if (identifier == "secondRow") {
                    constraint.constant = secondRowWidth
                }
            }
        }
    }
    
    // MARK: Buttons Clicked
    @IBAction func playButton_Clicked(_ sender: Any) {
        
    }
    @IBAction func prevButton_Clicked(_ sender: Any) {
        
    }
    @IBAction func nextButton_Clicked(_ sender: Any) {
        
    }
    @IBAction func closeButton_Clicked(_ sender: Any) {
        
    }
    @IBAction func loopButton_Clicked(_ sender: Any) {
        
    }
    @IBAction func randomButton_Clicked(_ sender: Any) {
        
    }
    @IBAction func playlistButton_Clicked(_ sender: Any) {
        
    }
    
    
}
