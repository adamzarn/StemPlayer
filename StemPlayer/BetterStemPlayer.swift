//
//  BetterStemPlayer.swift
//  StemPlayer
//
//  Created by Adam Zarn on 8/31/22.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

@MainActor
class BetterStemPlayer: ObservableObject {
    let songs: [Song]
    public let engine = AVAudioEngine()
    private var nodes: [AVAudioPlayerNode] = []
    var referenceNode: AVAudioPlayerNode? {
        return nodes.first
    }
    private var files: [AVAudioFile] = []
    var referenceFile: AVAudioFile? {
        return files.first
    }
    let refreshRate: TimeInterval
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    @Published var currentTime: Double = 0 {
        didSet {
            currentTimeString = currentTime.timeString
            if currentTotalTime - currentTime <= refreshRate {
                print("Did finish playing song")
                playNextSong()
            }
        }
    }
    @Published var currentTotalTime: Double = 1 {
        didSet {
            currentTotalTimeString = currentTotalTime.timeString
            currentValueRange = 0...currentTotalTime
        }
    }
    @Published var currentValueRange: ClosedRange<Double> = 0...1
    @Published var currentTimeString: String = "-:--"
    @Published var currentTotalTimeString: String = "-:--"
    
    @Published var isPlaying: Bool = false
    @Published var isPaused: Bool = false
    @Published var isStopped: Bool = true
    @Published var isScrubbing: Bool = false
    var startingFrame: AVAudioFramePosition = 0

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
    
    var index: Int = 0
    
    var currentSong: Song {
        return songs[index]
    }
    
    var tracks: [Track] {
        return currentSong.tracks
    }
    
    var hasPads: Bool {
        return !tracks.compactMap { $0.padType }.isEmpty
    }
    
    public init(songs: [Song], refreshRate: TimeInterval = 0.01) {
        self.songs = songs
        self.refreshRate = refreshRate
        self.timer = Timer.publish(every: refreshRate, on: .main, in: .common).autoconnect()
        setupNewSong()
    }
    
    func setupNewSong() {
        startingFrame = 0
        let hardwareFormat = engine.outputNode.outputFormat(forBus: 0)
        let currentSong = songs[index]
        files = currentSong.tracks.map { track in
            return loadFile(name: track.fileName, ext: track.ext)
        }
        nodes = currentSong.tracks.map { _ in AVAudioPlayerNode() }
        for node in nodes { engine.attach(node) }
        for node in nodes { engine.connect(node, to: engine.mainMixerNode, format: hardwareFormat) }
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: hardwareFormat)
        engine.prepare()
        do {
            try engine.start()
        } catch {
            fatalError("Could not start engine. error: \(error).")
        }
    }
    
    func play() {
        scheduleEffectLoop()
        for node in nodes { node.play() }
        isPlaying = true
        isPaused = false
    }
    
    func pause() {
        guard let currentFrame = referenceNode?.currentFrame(given: startingFrame) else { return }
        startingFrame = currentFrame
        for node in nodes { node.stop() }
        isPlaying = false
        isPaused = true
    }
    
    func toggle() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    private func scheduleEffectLoop() {
        guard let numberOfFrames = referenceFile?.numberOfFrames else { return }
        for (_, (node, file)) in zip(nodes, files).enumerated() {
            node.scheduleSegment(file,
                                 startingFrame: startingFrame,
                                 frameCount: AVAudioFrameCount(numberOfFrames.magnitude - startingFrame.magnitude),
                                 at: nil) {
            }
        }
    }
    
    func updateTimes() {
        guard let currentFrame = referenceNode?.currentFrame(given: startingFrame),
        let currentSeconds = referenceFile?.secondsAtFrame(frame: currentFrame, framesPerSecond: engine.framesPerSecond),
        let duration = referenceFile?.durationInSeconds(given: engine.framesPerSecond) else { return }
        currentTime = currentSeconds
        currentTotalTime = duration
    }
    
    func seek(to time: Double) {
        for node in nodes { node.stop() }
        guard let newFrame = referenceFile?.frameAtSeconds(seconds: time, framesPerSecond: engine.framesPerSecond) else { return }
        startingFrame = newFrame
        play()
    }
    
    func playNextSong() {
        if index < songs.count - 1 {
            index += 1
        } else {
            index = 0
        }
        engine.stop()
        setupNewSong()
        play()
    }
    
    func playPreviousSong() {
        if index > 0 {
            index -= 1
        } else {
            index = songs.count - 1
        }
        engine.stop()
        setupNewSong()
        play()
    }
    
    func play(song: Song) {
        guard let newIndex = songs.firstIndex(where: { $0.id == song.id }) else { return }
        guard index != newIndex else { return }
        index = newIndex
        engine.stop()
        setupNewSong()
        play()
    }
}

extension AVAudioEngine {
    var framesPerSecond: Double {
        return outputNode.outputFormat(forBus: 0).sampleRate
    }
}

extension AVAudioFile {
    func durationInSeconds(given framesPerSecond: Double) -> Double {
        return Double(numberOfFrames)/framesPerSecond
    }
    
    var numberOfFrames: UInt64 {
        return length.magnitude
    }
    
    func frameAtSeconds(seconds: Double, framesPerSecond: Double) -> AVAudioFramePosition? {
        let durationInSeconds = durationInSeconds(given: framesPerSecond)
        guard seconds >= 0, seconds <= durationInSeconds else { return nil }
        let ratio = seconds/durationInSeconds
        return frameAtRatio(ratio: ratio, framesPerSecond: framesPerSecond)
    }
    
    func frameAtRatio(ratio: Double, framesPerSecond: Double) -> AVAudioFramePosition? {
        guard ratio >= 0, ratio <= 1 else { return nil }
        let frame = floor(ratio * Double(numberOfFrames))
        return AVAudioFramePosition(exactly: frame)
    }
    
    func secondsAtFrame(frame: AVAudioFramePosition, framesPerSecond: Double) -> Double? {
        guard frame >= 0, frame <= length else { return nil }
        return Double(frame.magnitude)/Double(numberOfFrames) * durationInSeconds(given: framesPerSecond)
    }
}

extension AVAudioPlayerNode {
    func currentFrame(given startingFrame: AVAudioFramePosition) -> AVAudioFramePosition? {
        guard let lastRenderTime = lastRenderTime else { return nil }
        guard let playerTime = playerTime(forNodeTime: lastRenderTime) else { return nil }
        return playerTime.sampleTime + startingFrame
    }
}
