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

struct Songs {
    static var all: [Song] {
        return [
            Song(name: "Holy, Holy, Holy",
                 tracks: [
                    Track(fileName: "00_HolyHolyHoly")
                 ]
            ),
            Song(name: "Holy, Holy, Holy - 1 Part",
                tracks: [
                    Track(fileName: "01_HolyHolyHolySoprano", padType: .soprano)
                ]
            ),

            Song(name: "Holy, Holy, Holy - 2 Parts",
                tracks: [
                    Track(fileName: "01_HolyHolyHolySoprano", padType: .soprano),
                    Track(fileName: "02_HolyHolyHolyAlto", padType: .alto)
                ]
            ),
            Song(name: "Holy, Holy, Holy - 3 Parts",
                tracks: [
                    Track(fileName: "01_HolyHolyHolySoprano", padType: .soprano),
                    Track(fileName: "02_HolyHolyHolyAlto", padType: .alto),
                    Track(fileName: "03_HolyHolyHolyTenor", padType: .tenor)
                ]
            ),
            Song(name: "Holy, Holy, Holy - 4 Parts",
                tracks: [
                    Track(fileName: "01_HolyHolyHolySoprano", padType: .soprano),
                    Track(fileName: "02_HolyHolyHolyAlto", padType: .alto),
                    Track(fileName: "03_HolyHolyHolyTenor", padType: .tenor),
                    Track(fileName: "04_HolyHolyHolyBass", padType: .bass)
                ]
            )
        ]
    }
}
