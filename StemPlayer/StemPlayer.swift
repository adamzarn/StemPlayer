//
//  StemPlayer.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/9/22.
//

import Foundation
import SwiftUI
import AVFoundation

class StemPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    let songs: [Song]
    @Published var tracks: [Track] = []
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0 {
        didSet {
            currentTimeString = tracks.first?.audioPlayer.currentTime.timeString ?? "-:--"
        }
    }
    @Published var currentTotalTime: Double = 1 {
        didSet {
            currentTotalTimeString = tracks.first?.audioPlayer.duration.timeString ?? "-:--"
            currentValueRange = 0...currentTotalTime
        }
    }
    @Published var currentValueRange: ClosedRange<Double> = 0...1
    @Published var currentTimeString: String = "-:--"
    @Published var currentTotalTimeString: String = "-:--"
    @Published var isScrubbing: Bool = false
    let timer: Timer.TimerPublisher

    var index: Int = 0 {
        didSet {
            setupNewSong()
        }
    }
    
    var currentSong: Song {
        return songs[index]
    }
    
    var hasPads: Bool {
        return !tracks.compactMap { $0.padType }.isEmpty
    }
    
    init(songs: [Song]) {
        self.songs = songs
        self.timer = Timer.publish(every: 0.01, on: .main, in: .common)
        super.init()
        setupNewSong()
        updateTimes()
        let _ = self.timer.connect()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playNextSong()
    }
    
    func play() {
        tracks.playInSync()
        isPlaying = true
    }
    
    func play(song: Song) {
        pause()
        guard let songIndex = songs.firstIndex(where: { $0.id == song.id }) else { return }
        self.index = songIndex
        playSongFromStart()
    }
    
    func playNextSong() {
        pause()
        if index < songs.count - 1 {
            index += 1
        } else {
            index = 0
        }
        playSongFromStart()
    }
    
    func playPreviousSong() {
        pause()
        if index > 0 {
            index -= 1
        } else {
            index = songs.count - 1
        }
        playSongFromStart()
    }
    
    func playSongFromStart() {
        setupNewSong()
        seek(to: 0)
        play()
    }
    
    func pause() {
        tracks.pause()
        isPlaying = false
    }
    
    func toggle() {
        isPlaying ? pause() : play()
    }
    
    func toggleVolume(of padType: PadType?) {
        guard let padType = padType else { return }
        tracks.forEach { track in
            guard track.padType == padType else { return }
            track.audioPlayer.toggleVolume()
        }
        self.tracks = tracks
    }
    
    func setupNewSong() {
        guard index < songs.count else { return }
        self.tracks = songs[index].tracks
        self.tracks.first?.audioPlayer.delegate = self
    }
    
    func seek(to time: Double) {
        tracks.seek(to: time)
        updateTimes()
    }
    
    func skip(seconds: Double) {
        let newTime = currentTime + seconds
        seek(to: newTime <= currentTotalTime ? newTime : currentTotalTime)
    }
    
    func updateTimes() {
        guard tracks.first?.audioPlayer.duration ?? 0 > 0 else { return }
        currentTime = tracks.first?.audioPlayer.currentTime ?? 0
        currentTotalTime = tracks.first?.audioPlayer.duration ?? 0
    }
}
