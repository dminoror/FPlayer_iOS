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
    
    var progressTimer: Timer?
    
    
    override func loadView() {
        super.loadView()
        progressSlider.cachedColor = UIColor(white: 0.5, alpha: 1)
        progressSlider.maximumTrackTintColor = UIColor(named: "MaxTrack")
        progressSlider.minimumTrackTintColor = UIColor(named: "Text")
        progressSlider.setThumbImage(UIImage.makeCircleWith(size: CGSize(width: 12, height: 12), backgroundColor: UIColor(named: "Text")!), for: .normal)
        playButton.setImage(state: "playing", image: UIImage(named: "pauseIcon"))
        playButton.setImage(state: "pause", image: UIImage(named: "playIcon"))
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(playerCacheProgress), name: NSNotification.Name("playerCacheProgress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlayerItemChanged), name: NSNotification.Name("playerPlayerItemChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerGotMetadata), name: NSNotification.Name("playerGotMetadata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayStateChanged), name: NSNotification.Name("playerDidPlayStateChanged"), object: nil)
        updatePlayInfo()
        updatePlayState()
        progressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(progressTimer_Tick), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    func updatePlayInfo() {
        coverImage.image = PlayerCore.shared.currentArtwork
        titleLabel.text = PlayerCore.shared.currentTitle
        artistLabel.text = PlayerCore.shared.currentArtist
        if let currentTime = PlayerCore.shared.currentTime() {
            progressSlider.value = Float(currentTime)
            currentTimeLabel.text = currentTime.durationFormat()
        }
        if let totalTime = PlayerCore.shared.totalTime() {
            progressSlider.maximumValue = Float(totalTime)
            totalTimeLabel.text = totalTime.durationFormat()
        }
    }
    func resetPlayInfo() {
        coverImage.image = nil
        titleLabel.text = nil
        artistLabel.text = nil
        currentTimeLabel.text = "00:00"
        totalTimeLabel.text = "00:00"
    }
    func updatePlayState() {
        playButton.setState(state: (PlayerCore.shared.playState() == .playing) ? "playing" : "pause")
        playButton.isEnabled = (PlayerCore.shared.playState() == .pause || PlayerCore.shared.playState() == .playing)
    }
    
    @objc
    func progressTimer_Tick() {
        if let currentTime = PlayerCore.shared.currentTime() {
            progressSlider.value = Float(currentTime)
            currentTimeLabel.text = currentTime.durationFormat()
        }
    }
    
    // MARK: Buttons Clicked
    @IBAction func playButton_Clicked(_ sender: Any) {
        PlayerCore.shared.switchState()
    }
    @IBAction func prevButton_Clicked(_ sender: Any) {
        PlayerCore.shared.prev()
    }
    @IBAction func nextButton_Clicked(_ sender: Any) {
        PlayerCore.shared.next()
    }
    @IBAction func closeButton_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func loopButton_Clicked(_ sender: Any) {
        
    }
    @IBAction func randomButton_Clicked(_ sender: Any) {
        
    }
    @IBAction func playlistButton_Clicked(_ sender: Any) {
        
    }
    @IBAction func progressSlider_Changed(_ sender: Any) {
        PlayerCore.shared.seek(time: TimeInterval(progressSlider.value))
    }
    
    @objc
    func playerCacheProgress(notification: Notification) {
        if let dict = notification.object as? Dictionary<String, Any> {
            let tasks = dict["tasks"] as! NSMutableArray
            let totalBytes = dict["totalBytes"] as! UInt
            progressSlider.updateProgress(tasks, totalBytes: totalBytes)
        }
    }
    @objc
    func playerPlayerItemChanged() {
        DispatchQueue.main.async {
            self.resetPlayInfo()
        }
    }
    @objc
    func playerGotMetadata() {
        DispatchQueue.main.async {
            self.updatePlayInfo()
        }
    }
    @objc
    func playerDidPlayStateChanged() {
        DispatchQueue.main.async {
            self.updatePlayState()
        }
    }
    
}
