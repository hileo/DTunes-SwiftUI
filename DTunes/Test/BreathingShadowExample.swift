//
//  BreathingShadowExample.swift
//  DTunes
//
//  Created by OllyWang on 1/17/26.
//

import SwiftUI

struct BreathingShadowImage: View {

    @State private var playShadow: Bool = false
    @State private var shadowRadius: CGFloat = 0

    private let maxRadius: CGFloat = 6

    var body: some View {
        VStack(spacing: 20) {

            Image("DefaultIcon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 32, height: 32)
                .cornerRadius(6)
                .padding(.leading, 15)
                .shadow(
                    color: .red,
                    radius: shadowRadius
                )
                .scaleEffect(1 + 0.01 * shadowRadius)
            Button(playShadow ? "Stop Shadow" : "Play Shadow") {
                playShadow.toggle()
            }
        }
        // 监听 playShadow 的变化
        .onChange(of: playShadow) { _, newValue in
            if newValue {
                startBreathing()
            } else {
                stopBreathing()
            }
        }
    }

    private func startBreathing() {
        shadowRadius = 0
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            shadowRadius = maxRadius
        }
    }

    private func stopBreathing() {
        withAnimation(.easeOut(duration: 0.2)) {
            shadowRadius = 0
        }
    }
}

#Preview {
    BreathingShadowImage()
}
