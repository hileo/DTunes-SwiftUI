//
//  ControllableFloatingView.swift
//  kelly
//
//  Created by OllyWang on 1/17/26.
//

import SwiftUI
import Combine


// 1. 单个粒子的视图：负责自己的动画生命周期
struct ModernFloatingIcon: View {
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

// 2. 主控制视图
struct ControllableFloatingView2: View {
    @State private var icons: [FloatingIconModel] = []
    @State private var isPlaying: Bool = true
    
    let iconPool = ["face.smiling", "quote.bubble", "heart.fill"]
    let timer = Timer.publish(every: 0.9, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 60) {
            ZStack(alignment: .bottom) {
                // 底座图标
                mainIconBase
                
                // 粒子层
                ForEach(icons) { icon in
                    ModernFloatingIcon(
                        imageName: icon.name,
                        xOffset: icon.startX
                    ) {
                        // 动画结束后移除数据，防止数组无限增长
                        icons.removeAll(where: { $0.id == icon.id })
                    }
                }
            }
            .frame(height: 200)

            // 播放/暂停控制
            Button(action: { isPlaying.toggle() }) {
                Label(isPlaying ? "Pause" : "Play",
                      systemImage: isPlaying ? "pause.fill" : "play.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(isPlaying ? Color.red : Color.blue)
                    .clipShape(Capsule())
            }
        }
        .onReceive(timer) { _ in
            if isPlaying {
                // 只需向数组添加数据，动画由 ModernFloatingIcon 自己处理
                let newIcon = FloatingIconModel(
                    name: iconPool.randomElement()!,
                    startX: CGFloat.random(in: -30...30)
                )
                icons.append(newIcon)
            }
        }
    }
    
    private var mainIconBase: some View {
        Image(systemName: "app.fill")
            .resizable()
            .frame(width: 80, height: 80)
            .foregroundColor(.orange)
            .background(RoundedRectangle(cornerRadius: 15).fill(.white).shadow(radius: 5))
    }
}


#Preview {
    ControllableFloatingView2()
}
