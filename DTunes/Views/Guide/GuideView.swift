//
//  GuideView.swift
//  DTunes
//
//  Created by OllyWang on 4/21/26.
//

import SwiftUI

struct GuideView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Guide_Tip")
                    .foregroundColor(.white)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                
                Image(systemName: "hand.point.up.left.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white)
                    .phaseAnimator([0, 1], content: { content, phase in
                        content
                            .offset(x: phase == 0 ? 60 : -60)
                            .opacity(phase == 0 ? 0 : 1)
                    }, animation: { phase in
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: false)
                    })
                
            }
        }
        .ignoresSafeArea()
        
    }
}

enum SwipeAnimationPhase {
    case start
    case middle
    case end
}

struct GuideHandGestureView: View {
    private let fingerIconName = "hand.tap.fill"
    @State private var isVisible = false
    @EnvironmentObject var player: PlayerStore

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("左滑进入您的\n私人歌单")
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Image(systemName: fingerIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .foregroundColor(.white)
                    .phaseAnimator(
                        [SwipeAnimationPhase.start, .middle, .end]
                    ) { content, phase in
                        content
                            .offset(x: offset(for: phase))
                            .opacity(opacity(for: phase))
                        
                    } animation: { phase in
                        switch phase {
                        case .start:
                            return .instant
                        case .middle:
                            return .easeInOut(duration: 0.8)
                        case .end:
                            return .easeInOut(duration: 0.7)
                        }
                    }
            }
        }
        .background(.ultraThinMaterial)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3).delay(1.0)) {
                isVisible = true
            }
        }
        .onTapGesture {
            withAnimation(){
                player.shownGuide = false
            }
        }
    }
    
    private func offset(for phase: SwipeAnimationPhase) -> CGFloat {
        switch phase {
        case .start:  return 80
        case .middle: return 0
        case .end:    return -80
        }
    }
    
    private func opacity(for phase: SwipeAnimationPhase) -> Double {
        switch phase {
        case .start:  return 0
        case .middle: return 1
        case .end:    return 0
        }
    }
}

extension Animation {
    static var instant: Animation {
        .linear(duration: 0.01)
    }
}



#Preview {
    GuideView()
}
