//
//  PlaylistItem.swift
//  DTunes
//
//  Created by OllyWang on 12/17/25.
//

import SwiftUI
import MusicKit

struct UserPlaylistItem: View {
    var playlist: PlaylistDT
    let isActive: Bool
    var isAnimating: Bool
    var namespace: Namespace.ID
    @State private var isPressing = false
    let backColor: Color
    let waveColor: Color

    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 10){
                Text(playlist.subtitle)
                    .font(.body.weight(.semibold))
                    .matchedGeometryEffect(id: "subtitle\(playlist.id)", in: namespace)
                Text(playlist.title)
                    .font(.title.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .matchedGeometryEffect(id: "title\(playlist.id)", in: namespace)
                Spacer()
            }
            .padding(20)
            .padding(.top, 25)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(backColor)
                    .matchedGeometryEffect(id: "backColor\(playlist.id)", in: namespace)
            )
            .overlay(
                WaveView(
                    color: waveColor,
                    isActive: .constant(isActive),
                    isAnimating: .constant(isAnimating)
                )
                .mask{
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                }
                .matchedGeometryEffect(id: "wave\(playlist.id)", in: namespace)

            )
            .frame(height: 220)
            
            HStack{
                Spacer()
                if !isActive{
                    Button{
                        print("fff")
                    }label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .padding(6)
                            .background(Color(UIColor.systemBackground).opacity(0.1), in:Circle())
    //                        .strokeStyle(cornerRadius: 20)
                    }
                    .disabled(true)
                }
            }
            .padding(.trailing, 20)
            
        }
        .mask{
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .matchedGeometryEffect(id: "mask\(playlist.id)", in: namespace)
        }
    }
}
//
//#Preview {
//    @Previewable @Namespace var namespace
//    UserPlaylistItem(
//        playlist: PlayerStore().userPlaylists.first!,
//           isActive: true,
//           isAnimating: true,
//           namespace: namespace
//       )
//}
