//
//  ListView.swift
//  StemPlayer
//
//  Created by Adam Zarn on 7/10/22.
//

import Foundation
import SwiftUI

struct ListView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @ObservedObject var stemPlayer: StemPlayer
    
    var body: some View {
        NavigationView {
            List {
                ForEach(stemPlayer.songs) { song in
                    HStack {
                        Text(song.name)
                        Spacer()
                        if stemPlayer.isPlaying && stemPlayer.currentSong == song {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        stemPlayer.play(song: song)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                })
            }
        }
    }
}
