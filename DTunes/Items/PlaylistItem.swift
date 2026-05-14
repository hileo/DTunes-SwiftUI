//
//  PlaylistItem.swift
//  DTunes
//
//  Created by OllyWang on 12/17/25.
//

import SwiftUI

struct PlaylistItem: View {
    var playlist: PlaylistDT
    let isActive: Bool
    let isLock: Bool
    var isAnimating: Bool
    var namespace: Namespace.ID
    @State private var isPressing = false

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
                    .fill(Color(hex: playlist.backColor))
                    .matchedGeometryEffect(id: "backColor\(playlist.id)", in: namespace)
            )
            .overlay(
                WaveView(
                    color: Color(hex: playlist.waveColor),
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
                    if isLock {
                        Button{
                            print("lock")
                        }label: {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .padding(6)
                                .background(Color(UIColor.systemBackground).opacity(0.1), in:Circle())
                        }
                        .disabled(true)
                    } else {
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
            }
            .padding(.trailing, 20)
            
        }
        .mask{
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .matchedGeometryEffect(id: "mask\(playlist.id)", in: namespace)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    PlaylistItem(
           playlist: loadPlaylists().first!,
           isActive: true,
           isLock: true,
           isAnimating: true,
           namespace: namespace
       )
}
