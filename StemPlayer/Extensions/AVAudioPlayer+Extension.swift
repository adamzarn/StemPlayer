//
//  AVAudioPlayer+Extension.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/10/22.
//

import Foundation
import AVFoundation

extension AVAudioPlayer {
    func toggleVolume() {
        isMuted ? (volume = 1) : (volume = 0)
    }
    
    var isMuted: Bool {
        return volume == 0
    }
}
