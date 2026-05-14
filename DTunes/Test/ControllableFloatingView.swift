//
//  ControllableFloatingView.swift
//  DTunes
//
//  Created by OllyWang on 1/17/26.
//

import SwiftUI
import Combine

// 2. 主控制视图
struct ControllableFloatingView: View {
    @State private var isPlaying: Bool = false

    
    @State private var icons: [FloatingIconModel] = []
    @State private var iconIndex = 0
    let iconPool = ["music.quarternote.3", "cup.and.heat.waves", "moon.zzz", "tennisball"]
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 60) {
            ZStack(alignment: .bottom) {
                // 底座图标
                mainIconBase
                
                // 粒子层
                ForEach(icons) { icon in
                    FloatingIcon(
                        imageName: icon.name,
                        xOffset: icon.startX
                    ) {
                        // 动画结束后移除数据，防止数组无限增长
                        icons.removeAll(where: { $0.id == icon.id })
                    }
                    .offset(y:-70)
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
                    name: iconPool[iconIndex],
                    startX: CGFloat.random(in: -30...30)
                )
                
                iconIndex = (iconIndex + 1) % iconPool.count
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
    ControllableFloatingView()
}
