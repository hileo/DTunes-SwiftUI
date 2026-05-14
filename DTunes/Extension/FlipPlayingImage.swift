//
//  FlipPlayingImage.swift
//  DTunes
//
//  Created by OllyWang on 1/17/26.
//

import SwiftUI

struct FlipPlayingImageModifier: ViewModifier {
    @Binding var isPlaying: Bool
    @State private var rotation: Double = 0
    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.6
            )
            .onChange(of: isPlaying, initial: true) { _, newValue in
                if newValue {
                    startFlip()
                } else {
                    stopFlip()
                }
            }
            .onDisappear {
                stopFlip()
            }
    }

    @MainActor
    private func startFlip() {
        stopFlip() // 防止重复 Task

        task = Task {
            while isPlaying {
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotation += 180
                }

                // 动画 0.6s + 停顿 5s
                try? await Task.sleep(for: .seconds(5.6))
            }
        }
    }

    private func stopFlip() {
        task?.cancel()
        task = nil
    }
}

extension View {
    func flipPlayingImage(isPlaying: Binding<Bool>) -> some View {
        modifier(FlipPlayingImageModifier(isPlaying: isPlaying))
    }
}
