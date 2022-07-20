//
//  PadView.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/20/22.
//

import Foundation
import SwiftUI

struct PadView: View {
    @ObservedObject var stemPlayer: StemPlayer
    let track: Track
    
    var body: some View {
        ZStack {
            padType
            Text(track.isMuted ? "M" : (track.isSoloed ? "S" : "")).font(.system(size: 80))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture {
            stemPlayer.mute(padType: track.padType)
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                stemPlayer.solo(padType: track.padType)
            }
        )
        .background(track.audioPlayer.isMuted ? .white : .orange)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.orange, lineWidth: 2))
        .cornerRadius(16)
        .padding()
    }
    
    var padType: some View {
        VStack {
            HStack {
                Text(track.padType?.displayName ?? "")
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
}

struct PadView_Previews: PreviewProvider {
    static var previews: some View {
        PadView(stemPlayer: StemPlayer(songs: []),
                track: Songs.all[4].tracks[0])
        .previewLayout(.sizeThatFits)
    }
}
