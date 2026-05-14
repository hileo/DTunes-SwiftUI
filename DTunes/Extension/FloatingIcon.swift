//
//  FloatingIcon.swift
//  DTunes
//
//  Created by OllyWang on 1/17/26.
//

import SwiftUI
import Combine

// 简单的辅助模型
struct FloatingIconModel: Identifiable {
    let id = UUID()
    let name: String
    let startX: CGFloat
}

// 1. 单个粒子的视图：负责自己的动画生命周期
struct FloatingIcon: View {
    let imageName: String
    let xOffset: CGFloat
    var onFinished: () -> Void // 动画结束后的回调
    
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .foregroundColor(.gray.opacity(0.7))
            // iOS 17 关键：定义从 phase A 到 phase B 的变换
            .phaseAnimator([0, 1]) { content, phase in
                content
                    .offset(x: xOffset + (phase == 1 ? CGFloat.random(in: -20...20) : 0),
                            y: phase == 1 ? -90 : 0)
                    .opacity(phase == 1 ? 0 : 1)
                    .blur(radius: phase == 1 ? 10 : 0)
                    .scaleEffect(phase == 1 ? 1.5 : 0.2)
            } animation: { phase in
                .easeOut(duration: 2.5)
            }
            .onAppear {
                // 2.5秒后通知父视图从数组中移除自己，保持内存整洁
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    onFinished()
                }
            }
    }
}

