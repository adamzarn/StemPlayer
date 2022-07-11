//
//  TrackArray+Extension.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/10/22.
//

import Foundation
import AVFoundation

extension Array where Element == Track {
    var referenceAudioPlayer: AVAudioPlayer? {
        return first?.audioPlayer
    }
    
    var audioPlayers: [AVAudioPlayer] {
        return map { $0.audioPlayer }
    }
    
    func playInSync(delay: TimeInterval? = nil) {
        audioPlayers.playInSync(delay: delay)
    }
    
    func pause() {
        audioPlayers.pause()
    }
}
