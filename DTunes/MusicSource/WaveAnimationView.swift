//
//  WaveAnimationView.swift
//  kelly
//
//  Created by OllyWang on 4/10/26.
//

import SwiftUI

struct WaveAnimationContentView: View {
    var body: some View {
        WaveAnimationView()
            .frame(height: 320)
    }
}

struct WaveLine: Identifiable {
    let id = UUID()
    let amplitude: CGFloat
    let frequency: CGFloat
    let phaseOffset: CGFloat
    let color: Color
}

struct WaveAnimationView: View {

    private let waves: [WaveLine] = [
        WaveLine(amplitude: 36, frequency: 0.6, phaseOffset: 0, color: .blue),
        WaveLine(amplitude: 30, frequency: 0.4, phaseOffset: .pi / 2, color: .purple),
        WaveLine(amplitude: 18, frequency: 0.3, phaseOffset: .pi, color: .pink),
//        WaveLine(amplitude: 42, frequency: 0.7, phaseOffset: .pi / 6, color: .orange),
//        WaveLine(amplitude: 30, frequency: 0.8, phaseOffset: .pi / 3, color: .cyan)
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                for wave in waves {
                    let path = createWavePath(
                        size: size,
                        time: time,
                        wave: wave
                    )

                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [
                                wave.color.opacity(0.0),
                                wave.color,
                                wave.color.opacity(0.0)
                            ]),
                            startPoint: CGPoint(x: 0, y: size.height / 2),
                            endPoint: CGPoint(x: size.width, y: size.height / 2)
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                }
            }
        }
    }

    private func createWavePath(
        size: CGSize,
        time: TimeInterval,
        wave: WaveLine
    ) -> Path {

        let midY = size.height / 2
        let width = size.width

        var path = Path()
        path.move(to: CGPoint(x: 0, y: midY))

        let phase = time * 1.2 // 控制速度

        for x in stride(from: -10, through: width, by: 1) {
            let relativeX = x / width

            let y = midY + sin(
                relativeX * .pi * 2 * wave.frequency
                + phase
                + wave.phaseOffset
            ) * wave.amplitude

            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

#Preview {
    WaveAnimationContentView()
}
