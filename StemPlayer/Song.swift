//
//  Song.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/9/22.
//

import Foundation

class Song: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
    let tracks: [Track]
    
    init(name: String,
         tracks: [Track?]) {
        self.name = name
        self.tracks = tracks.compactMap { $0 }
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
}
