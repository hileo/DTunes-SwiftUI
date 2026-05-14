//
//  WaveView.swift
//  DTunes
//
//  Created by OllyWang on 12/18/25.
//

import SwiftUI

struct WaveView: View {
    var color: Color
    var speed: CGFloat = 0.22
    var baseline: CGFloat = 0.65
    
    @Binding var isActive: Bool     // 是否启用 TimelineView
    @Binding var isAnimating: Bool  // 是否流动
    
    var body: some View {
        Group {
            if isActive {
                TimelineView(.animation) { timeline in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    let phase = isAnimating ? CGFloat(now) * speed : 0
                    waves(phase: phase)
                }
            } else {
                waves(phase: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func waves(phase: CGFloat) -> some View {
        ZStack {
            Wave(phase: phase,
                 amplitude: 0.015,
                 frequency: 0.8,
                 baseline: baseline)
                .fill(color.opacity(1))
            
            Wave(phase: phase + 0.35,
                 amplitude: 0.02,
                 frequency: 0.5,
                 baseline: baseline - 0.05)
                .fill(color.opacity(0.6))
            
            Wave(phase: phase + 0.55,
                 amplitude: 0.025,
                 frequency: 0.25,
                 baseline: baseline - 0.1)
                .fill(color.opacity(0.4))
        }
        .background(Color.clear)
    }
}

#Preview {
    WaveView(color: .blue, isActive: .constant(true), isAnimating: .constant(true))
}
