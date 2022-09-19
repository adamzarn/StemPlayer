//
//  AVAudioFramePosition+Extension.swift
//  StemPlayer
//
//  Created by Adam Zarn on 9/19/22.
//

import Foundation
import AVFoundation

extension AVAudioFramePosition {
    func multiplied(by value: Double) -> AVAudioFramePosition {
        return AVAudioFramePosition(exactly: floor(Double(magnitude)*value)) ?? 0
    }
}
