//
//  Song.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/9/22.
//

import Foundation

enum SampleRate {
    case hertz(_ value: Double)
    case kilohertz(_ value: Double)
    
    var value: Double {
        switch self {
        case .hertz(let value): return value
        case .kilohertz(let value): return value * 1_000
        }
    }
    
    func asPercentageOf(_ sampleRate: SampleRate) -> Double {
        return value/sampleRate.value
    }
}

class Song: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
    var tracks: [Track]
    let sampleRate: SampleRate = .kilohertz(44.1)
    
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
