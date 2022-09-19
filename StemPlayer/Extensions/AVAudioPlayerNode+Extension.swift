//
//  AVAudioPlayerNode+Extension.swift
//  StemPlayer
//
//  Created by Adam Zarn on 9/19/22.
//

import Foundation
import AVFoundation

extension AVAudioPlayerNode {
    func currentFrame(startingFrame: AVAudioFramePosition) -> AVAudioFramePosition? {
        guard engine != nil else { return nil }
        guard let lastRenderTime = lastRenderTime else { return nil }
        guard let playerTime = playerTime(forNodeTime: lastRenderTime) else { return nil }
        return playerTime.sampleTime + startingFrame
    }
    
    var isMuted: Bool {
        return volume == 0
    }
    
    func toggleVolume() {
        if isMuted {
            volume = 1
        } else {
            volume = 0
        }
    }
}
