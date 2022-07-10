//
//  Track.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/9/22.
//

import Foundation
import AVFoundation

class Track: Identifiable {
    let id: UUID = UUID()
    let fileName: String
    let padType: PadType?
    let ext: String = "wav"
    let audioPlayer: AVAudioPlayer
    
    init?(fileName: String, padType: PadType? = nil) {
        self.fileName = fileName
        self.padType = padType
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else { return nil }
        guard let audioPlayer = try? AVAudioPlayer(contentsOf: url) else { return nil }
        self.audioPlayer = audioPlayer
    }
}
