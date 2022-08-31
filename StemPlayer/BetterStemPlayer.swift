//
//  BetterStemPlayer.swift
//  StemPlayer
//
//  Created by Adam Zarn on 8/31/22.
//

import Foundation
import AVFoundation

class BetterStemPlayer: ObservableObject {
    let songs: [Song]
    private let engine = AVAudioEngine()
    private var nodes: [AVAudioPlayerNode] = []
    private var files: [AVAudioFile] = []
    let timer: Timer.TimerPublisher
    
    @Published var isPlaying: Bool = false
    @Published var isPaused: Bool = false
    @Published var isStopped: Bool = true
    @Published var isScrubbing: Bool = false

    func loadFile(name: String, ext: String) -> AVAudioFile {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: name, withExtension: ext) else {
            fatalError("\(name).\(ext) file not found.")
        }
        do {
            let file = try AVAudioFile(forReading: fileURL)
            return file
        } catch {
            fatalError("Could not create AVAudioFile instance. error: \(error).")
        }
    }
    
    var index: Int = 0 {
        didSet {
            setupNewSong()
        }
    }
    
    var currentSong: Song {
        return songs[index]
    }
    
    var tracks: [Track] {
        return currentSong.tracks
    }
    
    var hasPads: Bool {
        return !tracks.compactMap { $0.padType }.isEmpty
    }
    
    public init(songs: [Song]) {
        self.songs = songs
        self.timer = Timer.publish(every: 0.01, on: .main, in: .common)
        setupNewSong()
    }
    
    func setupNewSong() {
        let hardwareFormat = engine.outputNode.outputFormat(forBus: 0)
        let currentSong = songs[index]
        files = currentSong.tracks.map { track in
            return loadFile(name: track.fileName, ext: track.ext)
        }
        nodes = Array(repeating: AVAudioPlayerNode(), count: currentSong.tracks.count)
        for track in nodes { engine.attach(track) }
        for track in nodes { engine.connect(track, to: engine.mainMixerNode, format: hardwareFormat) }
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: hardwareFormat)
        engine.prepare()
        do {
            try engine.start()
        } catch {
            fatalError("Could not start engine. error: \(error).")
        }
    }
    
    func startPlaying() {
        scheduleEffectLoop()
        resumePlaying()
    }
    
    func stopPlaying() {
        for track in nodes { track.stop() }
        engine.stop()
        isPlaying = false
        isStopped = true
    }
    
    func pausePlaying() {
        for track in nodes { track.pause() }
        isPlaying = false
        isPaused = true
    }
    
    func resumePlaying() {
        for track in nodes { track.play() }
        isPlaying = true
        isPaused = false
    }
    
    func toggle() {
        if isPlaying {
            pausePlaying()
        } else if isStopped {
            startPlaying()
        } else if isPaused {
            resumePlaying()
        }
    }
    
    private func scheduleEffectLoop() {
        for (index, (track, file)) in zip(nodes, files).enumerated() {
            track.scheduleFile(file, at: nil) {
                if index == self.nodes.count - 1 {
                    self.scheduleEffectLoop()
                }
            }
        }
    }
}
