//
//  ClockThemeColor.swift
//  DTunes
//
//  Created by OllyWang on 1/19/26.
//

import SwiftUI


enum ClockThemeColorStyle: CaseIterable, Identifiable {
    case playlistColor
    case artworkColor
    case darkColor
    var id: Self { self }
}

struct ClockThemeColorButton: View {
    // 状态：是否被选中
    @Binding var isSelected:Bool
    
    // 颜色与样式参数
    let topColor: Color
    let bottomColor: Color
    let defaultStrokeColor: Color
    let selectedStrokeColor: Color
    let size: CGFloat
    
    // 点击事件回调
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            action()
        }) {
            Circle()
                .fill(AngularGradient(
                    gradient: Gradient(stops: [
                        .init(color: topColor, location: 0.5),
                        .init(color: bottomColor, location: 0.5)
                    ]),
                    center: .center,
                    angle: .degrees(180)
                ))
                .overlay(
                    Circle().stroke(isSelected ? selectedStrokeColor : defaultStrokeColor, lineWidth: 2)
                        .id(isSelected)
                        .transition(.opacity)   // 👈 淡入淡出
                )
                .frame(width: 32, height: 32)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .shadow(
                    color: .black.opacity(0.3),
                    radius: 4,
                    x: 1,
                    y: 1
                )
        }
        .frame(width: size, height: size)
        .buttonStyle(.plain) // 可选：去除默认按钮高亮效果
        .animation(.easeInOut(duration: 0.15), value: isSelected) // 添加动画效果
    }
}

struct ClockThemeColor: View {
    @Binding var selectedColor: ClockThemeColorStyle
    var colorPrimaryPlaylist:Color
    var colorSecondaryPlaylist: Color
    
    var colorPrimaryArtwork:Color
    var colorSecondaryArtwork: Color
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    var body: some View {
        HStack(spacing: 15){
            ClockThemeColorButton(
                isSelected: .constant(selectedColor == .artworkColor),
                topColor: colorPrimaryArtwork,
                bottomColor: colorSecondaryArtwork,
                defaultStrokeColor: .black.opacity(0.7),
                selectedStrokeColor: selectedColor == .artworkColor ? .white : .clear,
                size: 44
            ) {
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred(intensity: 0.9)
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedColor = .artworkColor
                }
            }
            
            ClockThemeColorButton(
                isSelected: .constant(selectedColor == .playlistColor),
                topColor: colorPrimaryPlaylist,
                bottomColor: colorSecondaryPlaylist,
                defaultStrokeColor: .black.opacity(0.7),
                selectedStrokeColor: selectedColor == .playlistColor ? .white : .clear,
                size: 44
            ) {
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred(intensity: 0.9)
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedColor = .playlistColor
                }
            }
            
            ClockThemeColorButton(
                isSelected: .constant(selectedColor == .darkColor),
                topColor: .black,
                bottomColor: Color(hex: "2E2E2E"),
                defaultStrokeColor: .black.opacity(0.7),
                selectedStrokeColor: selectedColor == .darkColor ? .white : .clear,
                size: 44
            ) {
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred(intensity: 0.9)
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedColor = .darkColor
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.leading,10)
    }
}

#Preview {
    ClockThemeColor(selectedColor: .constant(.playlistColor), colorPrimaryPlaylist: .purple, colorSecondaryPlaylist: .red, colorPrimaryArtwork: .blue, colorSecondaryArtwork: .green)
//        .preferredColorScheme(.dark)
}
