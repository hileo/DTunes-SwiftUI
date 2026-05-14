//
//  Wave.swift
//  DTunes
//
//  Created by OllyWang on 12/18/25.
//

import SwiftUI

/// A reusable sine-based wave shape that animates its phase.
struct Wave: Shape {
    /// Horizontal phase offset of the wave
    var phase: CGFloat
    /// Wave height relative to view height
    var amplitude: CGFloat
    /// Number of wave cycles across the width
    var frequency: CGFloat
    /// Vertical position of the baseline (0...1)
    var baseline: CGFloat

    /// Enable automatic animation of `phase`
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height * baseline
        let step: CGFloat = 1

        path.move(to: CGPoint(x: 0, y: midY))
        for x in stride(from: 0, through: width, by: step) {
            let relativeX = x / width
            // Sine wave formula
            let sine = sin((relativeX * frequency + phase) * 2 * .pi)
            let y = midY + sine * amplitude * 900
            path.addLine(to: CGPoint(x: x, y: y))
        }
        // Close the path down to the bottom corners
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        return path
    }
}
