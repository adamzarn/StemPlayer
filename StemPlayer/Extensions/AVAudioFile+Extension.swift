//
//  AVAudioFile+Extension.swift
//  StemPlayer
//
//  Created by Adam Zarn on 9/19/22.
//

import Foundation
import AVFoundation

extension AVAudioFile {
    func durationInSeconds(recordedSampleRate: SampleRate) -> Double {
        return Double(numberOfFrames)/recordedSampleRate.value
    }
    
    var numberOfFrames: UInt64 {
        return length.magnitude
    }
    
    func adjustedNumberOfFrames(recordedSampleRate: SampleRate, outputSampleRate: SampleRate) -> UInt64 {
        return UInt64(Double(length.magnitude) * outputSampleRate.asPercentageOf(recordedSampleRate))
    }
    
    func frameAtSeconds(seconds: Double,
                        recordedSampleRate: SampleRate,
                        outputSampleRate: SampleRate) -> AVAudioFramePosition? {
        let durationInSeconds = durationInSeconds(recordedSampleRate: recordedSampleRate)
        guard seconds >= 0 else { return nil }
        let ratio = seconds / durationInSeconds
        return frameAtRatio(ratio: ratio,
                            recordedSampleRate: recordedSampleRate,
                            outputSampleRate: outputSampleRate)
    }
    
    func frameAtRatio(ratio: Double,
                      recordedSampleRate: SampleRate,
                      outputSampleRate: SampleRate) -> AVAudioFramePosition? {
        guard ratio >= 0 else { return nil }
        let frame = floor(ratio * Double(adjustedNumberOfFrames(recordedSampleRate: recordedSampleRate,
                                                                outputSampleRate: outputSampleRate)))
        return AVAudioFramePosition(exactly: frame)
    }
    
    func secondsAtFrame(frame: AVAudioFramePosition,
                        recordedSampleRate: SampleRate,
                        outputSampleRate: SampleRate) -> Double? {
        guard frame >= 0 else { return nil }
        let percentageOfSong = Double(frame.magnitude)/Double(numberOfFrames)
        let unadjustedSeconds = percentageOfSong * durationInSeconds(recordedSampleRate: recordedSampleRate)
        return unadjustedSeconds * recordedSampleRate.asPercentageOf(outputSampleRate)
    }
}
