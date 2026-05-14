//
//  ClockLayout.swift
//  DTunes
//
//  Created by OllyWang on 1/20/26.
//

import SwiftUI

enum ClockLayoutStyle: CaseIterable, Identifiable {
    case layoutTime
    case layoutNone
    case layoutCover
    case layoutArtWall
    case layoutCapsuleHorizontal
    case layoutCapsuleRotation
    
    var id: Self { self }
    
    var imageName: String {
        switch self {
        case .layoutTime: return "LayoutClock"
        case .layoutNone: return "LayoutWave"
        case .layoutCover: return "LayoutCover"
        case .layoutArtWall: return "LayoutArtworkWall"
        case .layoutCapsuleHorizontal: return "LayoutCapsuleHorizontal"
        case .layoutCapsuleRotation: return "LayoutCapsuleRotation"
        }
    }
    
    var imageNameV: String {
        switch self {
        case .layoutTime: return "LayoutVClock"
        case .layoutNone: return "LayoutVWave"
        case .layoutCover: return "LayoutVCover"
        case .layoutArtWall: return "LayoutVArtworkWall"
        case .layoutCapsuleHorizontal: return "LayoutVCapsuleHorizontal"
        case .layoutCapsuleRotation: return "LayoutVCapsuleRotation"
        }
    }
}

struct ClockLayout: View {
    
    @Binding var selectedLayout: ClockLayoutStyle
    @Binding var isShow: Bool
    private let sizeWidth: CGFloat = 140
    private let sizeHeight: CGFloat = 80
    
    private let borderWidth: CGFloat = 3
    private let cornerRadius: CGFloat = 15
    @Environment(\.isLandscape) var isLandscape

    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    var body: some View {
        
        ForEach(ClockLayoutStyle.allCases) { layout in
            
            Button {
                isShow = false
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred(intensity: 0.9)
                withAnimation(.spring(response: 0.35, dampingFraction: 1.0)) {
                    selectedLayout = layout
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            layout == selectedLayout ? Color.yellow : Color.clear,
                            lineWidth: borderWidth
                        )
                        .frame(
                            width: isLandscape ? sizeWidth - borderWidth*2 - 4 : sizeHeight - borderWidth*2 + 4,
                            height: isLandscape ? sizeHeight - borderWidth : sizeWidth - borderWidth*2 - 4
                        )

                    Image(isLandscape ? layout.imageName : layout.imageNameV)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: isLandscape ? sizeWidth : sizeHeight, height: isLandscape ? sizeHeight : sizeWidth)
                        .cornerRadius(layout == selectedLayout ? 0 : cornerRadius)
                        .scaleEffect(layout == selectedLayout ? 0.9 : 1.0)
                        .shadow(
                            color: .black.opacity(0.3),
                            radius: 4,
                            x: 1,
                            y: 1
                        )
                }
            }
            .buttonStyle(.plain)
            
        }
        
        
        
    }
}

#Preview {
    ClockLayout(selectedLayout: .constant(.layoutTime), isShow: .constant(true))
}
