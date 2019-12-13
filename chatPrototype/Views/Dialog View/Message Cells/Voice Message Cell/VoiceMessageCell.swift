//
//  VoiceMessageCell.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 13.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceMessageCell: UICollectionViewCell {
    
    private var audioPlayer: AVAudioPlayer!
    private var btnPlay: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "icon_startVoiceMessage"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfigure()
    }
    
    private func initialConfigure() {
        self.addSubview(btnPlay)
        btnPlay.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        btnPlay.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10).isActive = true
        btnPlay.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        btnPlay.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10).isActive = true
        btnPlay.addTarget(self, action: #selector(onMessageClicked(_:)), for: .touchUpInside)
    }
    
    @objc private func onMessageClicked(_ sender: UIButton?) {
        if (audioPlayer.isPlaying == true) {
            self.audioPlayer.pause()
            self.btnPlay.setImage(UIImage(named: "icon_startVoiceMessage"), for: .normal)
        } else {
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
            self.btnPlay.setImage(UIImage(named: "icon_pauseVoiceMessage"), for: .normal)
        }
    }
    
    func set(audioData: inout Data) {
        do {
            try self.audioPlayer = AVAudioPlayer(data: audioData)
        } catch {
            print("Не удалось создать аудиоплеер на дате")
        }
    }
    
}
