//
//  Artwork.swift
//  DTunes
//
//  Created by OllyWang on 12/20/25.
//

import SwiftUI
import MusicKit

struct ImageItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct GridArtwork2: View {
    let track: Track
    let size: CGFloat
    @State private var completedIDs: Set<MusicItemID> = [] // 记录 ID

    var body: some View {
        Group {
            if let artwork = track.artwork {
                ArtworkImage(artwork, width: size, height: size)
                    .background(.black)
//                    .opacity(completedIDs.contains(track.id) ? 1 : 0)
//                    .onAppear {
//                        if !completedIDs.contains(track.id) {
//                            withAnimation(.easeIn(duration: 0.5)) {
//                                _ = completedIDs.insert(track.id)
//                            }
//                        }
//                    }
            } else {
                Color.white.opacity(0.2)
            }
        }
        .frame(width: size, height: size)
        .clipped()
    }
}

struct GridArtwork: View {
    @Binding var showClock: Bool
    @EnvironmentObject var playerManager: PlayerManager
    let track: Track
    let size: CGFloat
    
    var body: some View {
        Button {
            impact()
            withAnimation(.openClock) {
                showClock = true
            }
            Task {
                do {
                    try await playerManager.playAtTrack(track: track)
                } catch {
                    print("点击播放失败: \(error)")
                }
            }
        } label: {
            content
        }
        .buttonStyle(PressScaleStyle())
    }
    
    private var content: some View {
        Group {
            if let artwork = track.artwork {
                ArtworkImage(artwork, width: size, height: size)
                    .background(.black)
            } else {
                Color.white.opacity(0.2)
            }
        }
        .frame(width: size, height: size)
        .clipped()
    }
    
    private func impact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: 1.0)
    }
}


struct GridCell: View {
    @StateObject private var loader: ImageLoader
    let size: CGFloat
    @State private var isVisible = false
    
    init(url: URL, size: CGFloat) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.size = size
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.white.opacity(0.2)
            }
        }
        .frame(width: size, height: size)
        .clipped()
        
    }
}

struct CurrentSong: Identifiable {
    let id = UUID()
    let title: String
    let singer: String
    let colorPrimary: Color
    let colorSecondary: Color
}
