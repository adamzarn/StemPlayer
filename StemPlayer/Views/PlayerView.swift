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
        self._stemPlayer = StateObject(wrappedValue: StemPlayer(songs: Songs.all))
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text(stemPlayer.currentSong.name)
                if stemPlayer.hasPads {
                    LazyVGrid(columns: columns) {
                        ForEach(stemPlayer.tracks) { track in
                            PadView(stemPlayer: stemPlayer, track: track)
                        }
                    }
                }
                Spacer().frame(height: 20)
                slider
                .padding()
                .onReceive(stemPlayer.timer) { input in
                    guard stemPlayer.isScrubbing == false else { return }
                    stemPlayer.updateTimes()
                }
                playbackControls
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
    
    var slider: some View {
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
                .foregroundColor(.lightGray)
                .frame(maxWidth: .infinity, maxHeight: 4)
                .fixedSize(horizontal: false, vertical: true)
        }, fill: {
            Capsule()
                .foregroundColor(.blue)
        }, thumb: {
            Circle()
                .fill(Color.lightGray, strokeBorder: .gray)
        }, thumbSize: CGSize(width: 12, height: 12))
    }
    
    var playbackControls: some View {
        HStack {
            Spacer()
            Spacer()
            Image(systemName: "backward.fill")
                .foregroundColor(.gray)
                .onTapGesture {
                stemPlayer.playPreviousSong()
            }
            Spacer()
            Image(systemName: stemPlayer.isPlaying ? "pause.fill" : "play.fill")
                .foregroundColor(.gray)
                .onTapGesture {
                stemPlayer.toggle()
            }
            Spacer()
            Image(systemName: "forward.fill")
                .foregroundColor(.gray)
                .onTapGesture {
                stemPlayer.playNextSong()
            }
            Spacer()
            Spacer()
        }
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
