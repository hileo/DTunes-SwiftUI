//
//  ClockCapsuleRotation.swift
//  DTunes
//
//  Created by OllyWang on 2/18/26.
//

import SwiftUI
import Combine
import MusicKit

struct ClockCapsuleRotation: View {
    // 只需要输入一个色值
    var exportMode: Bool = false

    @EnvironmentObject var playerManager: PlayerManager
    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isCompact) var isCompact
    @State private var animate = false
    
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
        (0.35, 1.0),   // 1. 最浅（低饱和度，高亮度）
        (0.85, 0.85),  // 2.
        (0.95, 0.70),  // 3.
        (1.0, 0.40)    // 4. 最深（全饱和度，低亮度）
    ]


    var body: some View {
        GeometryReader { geo in
            
            let minSide = min(geo.size.width, geo.size.height)
           
            let widthScale = isCompact
                ? (isLandscape ? 0.3 : 0.76)//iphone
                : (isLandscape ? 0.23 : 0.6)

            let heightScale = isCompact
                ? (isLandscape ? 0.76 : 0.3)//iphone
                : (isLandscape ? 0.6 : 0.23)
            
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                RadialGradient(
                    colors: [themeColor.adjust(
                        saturation: colorSteps[2].s,
                        brightness: colorSteps[2].b
                    ).opacity(0.7), themeColor.adjust(
                        saturation: colorSteps[2].s,
                        brightness: colorSteps[2].b
                    ).opacity(0.0)],
                    center: isLandscape ? .topLeading : .topTrailing,
                    startRadius: 10,
                    endRadius: isCompact ? 400 : 1000
                )
                .ignoresSafeArea()
                
                ZStack {
                    // 堆叠方向
                    if isLandscape {
                        HStack(spacing: -15) {
                            capsules(minSide: minSide, widthScale: widthScale, heightScale: heightScale)
                        }
                        capsuleBig(minSide: minSide, widthScale: widthScale, heightScale: heightScale)
                    } else {
                        VStack(spacing: -15) {
                            capsules(minSide: minSide, widthScale: widthScale, heightScale: heightScale)
                        }
                        capsuleBig(minSide: minSide, widthScale: widthScale, heightScale: heightScale)
                    }
                }
                .offset(
                    x: isLandscape ? 80 : 0,
                    y: isLandscape ? 0 : 110
                )
                
                timeView(size: geo.size, minSide: minSide, widthScale: widthScale, heightScale: heightScale)
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
    func capsuleBig(minSide: CGFloat, widthScale: CGFloat, heightScale: CGFloat) -> some View{
        let pos = isLandscape ? -minSide * widthScale * 1.8 : -minSide * heightScale * 1.8
        Capsule()
            .fill(themeColor.adjust(
                saturation: colorSteps[0].s,
                brightness: colorSteps[0].b
            ))
            .frame(
                width: minSide * widthScale,
                height: minSide * heightScale
            )
            .brightness(0.1)
            .offset(
                x: isLandscape ? (exportMode ? pos : (animate ? pos : pos - 20)) : 0,
                y: isLandscape ? 0 : (exportMode ? pos : (animate ? pos :  pos - 20))
            )
            .opacity(exportMode ? 1 : (animate ? 1 : 0))
            .animation(
                exportMode ? nil :
                    .easeOut(duration: 0.5).delay(0.0),
                value: animate
            )
    }
    
    @ViewBuilder
    func timeView(size: CGSize, minSide: CGFloat, widthScale: CGFloat, heightScale: CGFloat) -> some View {
        let minSide = min(size.width, size.height)
        let fontSize = minSide * (
            isCompact
            ? (isLandscape ? 0.65 : 0.30)//iphone
            : (isLandscape ? 0.45 : 0.2)//ipad
        )
        let sacle = isCompact ? 2.2 : 2.38
        let pos = isLandscape ? -minSide * widthScale * sacle : -minSide * heightScale * sacle
        
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let date = context.date
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            let second = Calendar.current.component(.second, from: date)
            
            HStack(spacing: 0) {
                Text(String(format: "%02d", hour))
                // 中间冒号：根据秒数闪烁
                Text(":")
                    .opacity(second % 2 == 0 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: second)
                    .offset(y: isLandscape ? -20 : -12)
                Text(String(format: "%02d", minute))
            }
            .font(.system(size: fontSize, weight: .thin, design: .rounded))
            .foregroundStyle(themeColor)
            .monospacedDigit()
            .brightness(0.4)
            .offset(
                y: isLandscape ? 0 : pos
            )
            .shadow(
                color: isLandscape ? .black.opacity(0.2) : .clear,
                radius: isLandscape ? 12 : 0,
                x: 0,
                y: 3
            )
            .onAppear{
                print("minSide * widthScale = ", -minSide * widthScale * 1.8)
                print("minSide * heightScale = ",  -minSide * heightScale * 1.8)
                print("pos = ", pos)

            }
        }
    }
    
    @ViewBuilder
    func capsules(minSide: CGFloat, widthScale: CGFloat, heightScale: CGFloat) -> some View{
        Group {
            Capsule()
                .fill(themeColor.adjust(
                    saturation: colorSteps[1].s,
                    brightness: colorSteps[1].b
                ))
                .frame(
                    width: minSide * widthScale,
                    height: minSide * heightScale
                )
                .rotationEffect(.degrees(-6))
                .opacity(exportMode ? 1 : (animate ? 0.9 : 0))
                .offset(
                    x: isLandscape ? (exportMode ? 0 : (animate ? 0 : -16)) : 0,
                    y: isLandscape ? 0 : (exportMode ? 0 : (animate ? 0 : -16))
                )
                .animation(
                    exportMode ? nil :
                        .easeOut(duration: 0.5).delay(0.15),
                    value: animate
                )

            Capsule()
                .fill(themeColor.adjust(
                    saturation: colorSteps[2].s,
                    brightness: colorSteps[2].b
                ))
                .frame(
                    width: minSide * widthScale,
                    height: minSide * heightScale
                )
                .rotationEffect(.degrees(10))
                .opacity(exportMode ? 1 : (animate ? 0.7 : 0))
                .offset(
                    x: isLandscape ? (exportMode ? 0 : (animate ? 0 : -16)) : 0,
                    y: isLandscape ? 0 : (exportMode ? 0 : (animate ? 0 : -16))
                )
                .animation(
                    exportMode ? nil :
                        .easeOut(duration: 0.5).delay(0.3),
                    value: animate
                )

            Capsule()
                .fill(themeColor.adjust(
                    saturation: colorSteps[3].s,
                    brightness: colorSteps[3].b
                ))
                .frame(
                    width: minSide * widthScale,
                    height: minSide * heightScale
                )
                .rotationEffect(.degrees(-8))
                .opacity(exportMode ? 1 : (animate ? 0.4 : 0))
                .offset(
                    x: isLandscape ? (exportMode ? 0 : (animate ? 0 : -16)) : 0,
                    y: isLandscape ? 0 : (exportMode ? 0 : (animate ? 0 : -16))
                )
                .animation(
                    exportMode ? nil :
                        .easeOut(duration: 0.5).delay(0.45),
                    value: animate
                )
        }
    }
}

#Preview {
    ClockCapsuleRotation()
}
