//
//  StemPlayer.swift
//  StemPlayer
//
//  Created by Adam Zarn on 8/31/22.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

@MainActor
class StemPlayer: ObservableObject {
    let songs: [Song]
    public var engine = AVAudioEngine()
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
            if currentTotalTime - currentTime <= refreshRate && !isScrubbing {
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
    @Published var currentSong: Song
    @Published var tracks: [Track]
    
    var hasPads: Bool {
        return !tracks.compactMap { $0.padType }.isEmpty
    }
    
    public init(songs: [Song],
                startingIndex: Int = 0,
                refreshRate: TimeInterval = 0.01) {
        self.songs = songs
        let currentSong = songs[startingIndex]
        self.currentSong = currentSong
        self.tracks = currentSong.tracks
        self.refreshRate = refreshRate
        self.timer = Timer.publish(every: refreshRate, on: .main, in: .common).autoconnect()
        startEngine()
        currentTimeString = currentTime.timeString
        currentTotalTime = referenceFile?.durationInSeconds(recordedSampleRate: currentSong.sampleRate) ?? 1
        currentTotalTimeString = currentTotalTime.timeString
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, options: .allowBluetooth)
            try audioSession.setActive(true)
        } catch {
            fatalError("Could not configure audio session. error: \(error).")
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(engineConfigurationDidChange),
                                               name: NSNotification.Name.AVAudioEngineConfigurationChange,
                                               object: nil)
    }
    
    @objc func engineConfigurationDidChange(_ notification: Notification) {
        startEngine()
        startingFrame = referenceFile?.frameAtSeconds(seconds: currentTime,
                                                      recordedSampleRate: currentSong.sampleRate,
                                                      outputSampleRate: engine.outputSampleRate) ?? 0
        if isPlaying {
            play()
        }
    }
    
    func startEngine() {
        engine = AVAudioEngine()
        let hardwareFormat = engine.outputNode.outputFormat(forBus: 0)
        print(hardwareFormat.sampleRate)
        print(hardwareFormat.channelCount)
        guard hardwareFormat.sampleRate > 0, hardwareFormat.channelCount > 0 else {
            startEngine()
            return
        }
        files = tracks.map { track in
            return loadFile(name: track.fileName, ext: track.ext)
        }
        nodes = tracks.map { track in
            let node = AVAudioPlayerNode()
            node.volume = track.isMuted ? 0 : 1
            return node
        }
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
    
    @MainActor
    func play() {
        if !engine.isRunning {
            print("Engine is not running, starting it up again...")
            startEngine()
        }
        scheduleSegments()
        for node in nodes { node.play() }
        DispatchQueue.main.async {
            self.isPlaying = true
            self.isPaused = false
        }
    }
    
    func pause() {
        guard let currentFrame = referenceNode?.currentFrame(startingFrame: startingFrame) else { return }
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
    
    private func scheduleSegments() {
        guard let numberOfFrames = referenceFile?.adjustedNumberOfFrames(recordedSampleRate: currentSong.sampleRate,
                                                                         outputSampleRate: engine.outputSampleRate) else { return }
        let frameCount = AVAudioFrameCount(numberOfFrames.magnitude - startingFrame.magnitude)
        let startingFrame = startingFrame.multiplied(by: currentSong.sampleRate.asPercentageOf(engine.outputSampleRate))
        guard frameCount > 0 else { return }
        for (_, (node, file)) in zip(nodes, files).enumerated() {
            node.scheduleSegment(file,
                                 startingFrame: startingFrame,
                                 frameCount: frameCount,
                                 at: nil) {
            }
        }
    }
    
    func updateTimes() {
        guard let currentFrame = referenceNode?.currentFrame(startingFrame: startingFrame),
              let currentSeconds = referenceFile?.secondsAtFrame(frame: currentFrame,
                                                                 recordedSampleRate: currentSong.sampleRate,
                                                                 outputSampleRate: engine.outputSampleRate),
              let duration = referenceFile?.durationInSeconds(recordedSampleRate: currentSong.sampleRate) else { return }
        currentTime = currentSeconds
        currentTotalTime = duration
    }
    
    func seek(to time: Double) {
        guard let newFrame = referenceFile?.frameAtSeconds(seconds: time,
                                                           recordedSampleRate: currentSong.sampleRate,
                                                           outputSampleRate: engine.outputSampleRate) else { return }
        startingFrame = newFrame
        for node in nodes { node.stop() }
        if isPlaying {
            play()
        }
    }
    
    func playNextSong() {
        incrementIndex()
        playNewSong()
    }
    
    func playPreviousSong() {
        decrementIndex()
        playNewSong()
    }
    
    func incrementIndex() {
        if index < songs.count - 1 {
            setIndex(index + 1)
        } else {
            setIndex(0)
        }
    }
    
    func decrementIndex() {
        if index > 0 {
            setIndex(index - 1)
        } else {
            setIndex(songs.count - 1)
        }
    }
    
    func playNewSong(forcePlay: Bool = false) {
        startingFrame = 0
        engine.stop()
        startEngine()
        if isPlaying || forcePlay {
            play()
        } else {
            currentTime = 0
        }
    }
    
    func play(song: Song) {
        guard let newIndex = songs.firstIndex(where: { $0.id == song.id }) else { return }
        guard index != newIndex else { return }
        setIndex(newIndex)
        playNewSong(forcePlay: true)
    }
    
    func mute(padType: PadType?) {
        guard let trackToMuteIndex = tracks.firstIndex(where: { $0.padType == padType }) else { return }
        nodes[trackToMuteIndex].toggleVolume()
        tracks[trackToMuteIndex].isMuted = nodes[trackToMuteIndex].isMuted
        if nodes.filter({ $0.volume == 1 }).count > 1 {
            tracks.forEach { $0.isSoloed = false }
        }
        setIndex(index)
    }
    
    func solo(padType: PadType?) {
        guard let trackToSoloIndex = tracks.firstIndex(where: { $0.padType == padType }) else { return }
        for (trackIndex, track) in tracks.enumerated() {
            if trackIndex == trackToSoloIndex {
                nodes[trackIndex].volume = 1
                track.isSoloed = true
                track.isMuted = false
            } else {
                nodes[trackIndex].volume = 0
                track.isSoloed = false
                track.isMuted = true
            }
        }
        setIndex(index)
    }
    
    func setIndex(_ index: Int) {
        self.index = index
        self.currentSong = songs[index]
        self.tracks = songs[index].tracks
    }
}
