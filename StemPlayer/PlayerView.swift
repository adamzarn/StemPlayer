//
//  PlayerView.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/9/22.
//

import SwiftUI
import AVFoundation
import AZSlider

struct PlayerView: View {
    @StateObject var stemPlayer: StemPlayer
    @State var listViewIsPresented: Bool = false
    
    init() {
        self._stemPlayer = StateObject(wrappedValue: StemPlayer(
            songs: [
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
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text(stemPlayer.currentSong.name)
                if stemPlayer.hasPads {
                    ForEach(stemPlayer.tracks) { track in
                        VStack {
                            Text(track.padType?.displayName ?? "")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            stemPlayer.toggleVolume(of: track.padType)
                        }
                        .padding()
                        .background(track.audioPlayer.volume == 1 ? .orange : .white)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.orange, lineWidth: 2))
                        .cornerRadius(16)
                        .padding()
                    }
                }
                Spacer().frame(height: 20)
                AZSlider(value: $stemPlayer.currentTime,
                         in: stemPlayer.currentValueRange,
                         minimumValueLabel: {
                    Text(stemPlayer.currentTimeString).font(.caption)
                },
                         maximumValueLabel: {
                    Text(stemPlayer.currentTotalTimeString).font(.caption)
                },
                         didStartDragging: didStartDragging,
                         didStopDragging: didStopDragging,
                         track: {
                    Capsule()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: 4)
                        .fixedSize(horizontal: false, vertical: true)
                }, fill: {
                    Capsule()
                        .foregroundColor(.blue)
                }, thumb: {
                    Circle()
                        .fill(.gray, strokeBorder: .black)
                }, thumbSize: CGSize(width: 12, height: 12))
                .padding()
                .onReceive(stemPlayer.timer) { input in
                    guard stemPlayer.isScrubbing == false else { return }
                    stemPlayer.updateTimes()
                }
                HStack {
                    Spacer()
                    Spacer()
                    Image(systemName: "backward.fill").onTapGesture {
                        stemPlayer.playPreviousSong()
                    }
                    Spacer()
                    Image(systemName: stemPlayer.isPlaying ? "pause.fill" : "play.fill").onTapGesture {
                        stemPlayer.toggle()
                    }
                    Spacer()
                    Image(systemName: "forward.fill").onTapGesture {
                        stemPlayer.playNextSong()
                    }
                    Spacer()
                    Spacer()
                }
            }
            .navigationBarTitle("Stem Player")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        listViewIsPresented = true
                    }, label: {
                        Image(systemName: "list.bullet")
                    })
                })
            }
        }
        .sheet(isPresented: $listViewIsPresented, content: {
            ListView(stemPlayer: stemPlayer)
        })
    }
    
    func didStartDragging(_ value: Double) {
        stemPlayer.isScrubbing = true
    }
    
    func didStopDragging(_ value: Double) {
        stemPlayer.isScrubbing = false
        stemPlayer.seek(to: value)
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}

extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill,
                                                    strokeBorder strokeStyle: Stroke,
                                                    lineWidth: CGFloat = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}
