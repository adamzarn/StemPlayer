//
//  AVAudioEngine+Extension.swift
//  StemPlayer
//
//  Created by Adam Zarn on 9/19/22.
//

import Foundation
import AVFoundation

extension AVAudioEngine {
    var outputSampleRate: SampleRate {
        return .hertz(outputNode.outputFormat(forBus: 0).sampleRate)
    }
}
