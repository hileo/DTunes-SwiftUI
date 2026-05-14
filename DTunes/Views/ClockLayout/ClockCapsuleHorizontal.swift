//
//  ClockCapsuleHorizontal.swift
//  DTunes
//
//  Created by OllyWang on 2/18/26.
//

import SwiftUI
import MusicKit

struct ClockCapsuleHorizontal: View {
    var exportMode: Bool = false
    private let barCount = 6
    @State private var animate = false
    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isCompact) var isCompact
    @EnvironmentObject var playerManager: PlayerManager

    var colorPrimaryArtwork: Color {
        playerManager.primaryColor
    }
    
    var colorSecondaryArtwork: Color {
        playerManager.secondaryColor
    }
    
    /// 更明亮的那个颜色
    var themeColor: Color {
        score(colorPrimaryArtwork) > score(colorSecondaryArtwork)
        ? colorPrimaryArtwork
        : colorSecondaryArtwork
    }
    
    let colorSteps: [(s: CGFloat, b: CGFloat)] = [
        (0.1, 0.98), // 最浅
        (0.3, 0.90),
        (0.5, 0.85),
        (0.7, 0.80),
        (0.85, 0.70),
        (1.0, 0.50)  // 最深
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
               
                Group {
                    if isLandscape {
                        HStack(spacing: -20) {
                            capsules(size: geo.size)
                        }
                    } else {
                        VStack(spacing: -20) {
                            capsules(size: geo.size)
                                .offset(y: 40)
                        }
                    }
                }
                timeView(size: geo.size)
                    .opacity(animate ? 1 : 0)
                    .offset(
                        x: isLandscape ? (animate ? 0 : -16) : 0,
                        y: isLandscape ? 0 : (animate ? 0 : -16)
                    )
                    .animation(
                        .easeOut(duration: 0.5).delay(0.25),
                        value: animate
                    )
            }
            .onAppear {
                if !exportMode {
                    animate = true
                }
            }
            .task {
                playerManager.updateThemeColor(from: playerManager.nowPlayingTrack)
            }
            .onChange(of: playerManager.nowPlayingTrack) { _, newValue in
                withAnimation() {
                    playerManager.updateThemeColor(from: newValue)
                }
            }
        }
    }
    
    
    @ViewBuilder
    func capsules(size: CGSize) -> some View {
        let minSide = min(size.width, size.height)
       
        let widthScale = isCompact
            ? (isLandscape ? 0.23 : 0.76)
            : (isLandscape ? 0.15 : 0.6)

        let heightScale = isCompact
            ? (isLandscape ? 0.76 : 0.23)
            : (isLandscape ? 0.6 : 0.15)
        
        ForEach(0..<colorSteps.count, id: \.self) { index in

            Capsule()
                .fill(themeColor.adjust(
                    saturation: colorSteps[index].s,
                    brightness: colorSteps[index].b
                ))
                .frame(
                    width:  minSide * widthScale,
                    height:  minSide * heightScale
                )
                .opacity(exportMode ? 1 : (animate ? 1 : 0))
                .offset(
                    x: isLandscape ? (exportMode ? 0 : (animate ? 0 : -10)) : 0,
                    y: isLandscape ? 0 : (exportMode ? 0 : (animate ? 0 : -10))
                )
                .animation(
                    exportMode ? nil :
                            .easeOut(duration: 0.3)
                            .delay(Double(index) * 0.15),
                    value: animate
                )
                .zIndex(Double(barCount - index))
        }
    }
    
    @ViewBuilder
    func timeView(size: CGSize) -> some View {
        let minSide = min(size.width, size.height)
        
        let widthScale = isCompact
            ? (isLandscape ? 0.23 : 0.76)
            : (isLandscape ? 0.15 : 0.6)

        let heightScale = isCompact
            ? (isLandscape ? 0.76 : 0.23)
            : (isLandscape ? 0.6 : 0.15)
        
        let fontSize = minSide * (
            isCompact
            ? (isLandscape ? 0.65 : 0.30)//iphone
            : (isLandscape ? 0.45 : 0.2)//ipad
        )
        let sacle = isCompact ? 2.8 : 3.4
        let pos = isLandscape ? -minSide * widthScale * sacle : -minSide * heightScale * sacle
        
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let date = context.date
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            let second = Calendar.current.component(.second, from: date)
            
            let stackSpacing: CGFloat = {
                if #available(iOS 26.0, *) {
                    return isLandscape ? 30 : 12
                } else {
                    return 0
                }
            }()
            
            HStack(spacing: stackSpacing) {
                if #available(iOS 26.0, *) {
                    LiquidGlassText(
                        String(format: "%02d", hour),
                        glass: .clear.tint(themeColor.opacity(0.2)),
                        size: fontSize,
                        weight: .semibold,
                        width: .standard,
                        design: .rounded
                    )
                } else {
                    Text(String(format: "%02d", hour))
                        .font(.system(size: fontSize, weight: .semibold, design: .rounded))

                }
                // 中间冒号：根据秒数闪烁
                if #available(iOS 26.0, *) {
                    LiquidGlassText(
                        ":",
                        glass: .clear.tint(themeColor.opacity(0.2)),
                        size: fontSize,
                        weight: .semibold,
                        width: .standard,
                        design: .rounded
                    )
                    .opacity(second % 2 == 0 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: second)
//                    .offset(y: isLandscape ? -10 : -2)
                    
                } else {
                    // 中间冒号：根据秒数闪烁
                    Text(":")
                        .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                        .opacity(second % 2 == 0 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: second)
                        .offset(y: isLandscape ? -20 : -12)
                }
                if #available(iOS 26.0, *) {
                    LiquidGlassText(
                        String(format: "%02d", minute),
                        glass: .clear.tint(themeColor.opacity(0.2)),
                        size: fontSize,
                        weight: .semibold,
                        width: .standard,
                        design: .rounded
                    )

                } else {
                    Text(String(format: "%02d", minute))
                        .font(.system(size: fontSize, weight: .semibold, design: .rounded))

                }
            }
            .foregroundStyle(themeColor)
            .monospacedDigit()
            .brightness(0.4)
            .offset(
                y: isLandscape ? 0 : pos
            )
        }
    }
}

#Preview {
    ClockCapsuleHorizontal()
}
