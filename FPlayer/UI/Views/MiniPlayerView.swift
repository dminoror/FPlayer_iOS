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
    var playButtonBorder = CAShapeLayer()
    
    var progressTimer: Timer?
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playButton.layoutIfNeeded()
        playButton.clipsToBounds = false
        playButton.setImage(UIImage(named: "pauseIcon"), for: .selected)
        
        let backBorder = CAShapeLayer()
        backBorder.lineWidth = 2
        backBorder.fillColor = UIColor.clear.cgColor
        backBorder.strokeColor = UIColor.gray.cgColor
        backBorder.frame = playButton.bounds
        let aDegree = CGFloat.pi / 180
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: playButton.frame.width / 2, y: playButton.frame.width / 2), radius: playButton.frame.width / 2, startAngle: aDegree * -90, endAngle: aDegree * 450, clockwise: true)
        backBorder.path = path.cgPath
        playButton.layer.addSublayer(backBorder)
        
        playButtonBorder.lineWidth = 3
        playButtonBorder.fillColor = UIColor.clear.cgColor
        playButtonBorder.strokeColor = UIColor.black.cgColor
        playButtonBorder.frame = playButton.bounds
        playButton.layer.addSublayer(playButtonBorder)
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if (newWindow != nil) {
            NotificationCenter.default.addObserver(self, selector: #selector(playerPlayerItemChanged), name: NSNotification.Name("playerPlayerItemChanged"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerGotMetadata), name: NSNotification.Name("playerGotMetadata"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayStateChanged), name: NSNotification.Name("playerDidPlayStateChanged"), object: nil)
            progressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(progressTimer_Tick), userInfo: nil, repeats: true)
            updatePlayInfo()
            updatePlayState()
        }
        else {
            NotificationCenter.default.removeObserver(self)
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }
    
    func updatePlayInfo() {
        coverImage.image = PlayerCore.shared.metadata(type: .artwork) as? UIImage
        titleLabel.text = PlayerCore.shared.metadata(type: .title) as? String
    }
    func resetPlayInfo() {
        coverImage.image = nil
        titleLabel.text = nil
    }
    func updatePlayState() {
        playButton.isSelected = (PlayerCore.shared.playState() == .playing)
        playButton.isEnabled = (PlayerCore.shared.playState() == .pause || PlayerCore.shared.playState() == .playing)
    }
    
    @objc
    func progressTimer_Tick() {
        let progress = PlayerCore.shared.currentTime()! / PlayerCore.shared.totalTime()!
        updateProgress(progress: progress)
    }
    func updateProgress(progress: Double) {
        let progressAngle = progress * 360
        let aDegree = CGFloat.pi / 180
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: playButton.frame.width / 2, y: playButton.frame.width / 2), radius: playButton.frame.width / 2, startAngle: aDegree * (-90), endAngle: aDegree * CGFloat((-90 + progressAngle)), clockwise: true)
        playButtonBorder.path = path.cgPath
    }
    
    
    @IBAction func miniPlayer_Clicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("didMiniPlayerClicked"), object: nil)
    }
    
    @IBAction func playButton_Clicked(_ sender: Any) {
        PlayerCore.shared.switchState()
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
