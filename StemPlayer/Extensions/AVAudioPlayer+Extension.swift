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
        isMuted ? unmute() : mute()
    }
    
    func mute() {
        volume = 0
    }
    
    func unmute() {
        volume = 1
    }
    
    var isMuted: Bool {
        return volume == 0
    }
}
