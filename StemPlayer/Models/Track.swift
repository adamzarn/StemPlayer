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
    var isMuted: Bool = false
    var isSoloed: Bool = false
    
    init?(fileName: String, padType: PadType? = nil) {
        self.fileName = fileName
        self.padType = padType
    }
}
