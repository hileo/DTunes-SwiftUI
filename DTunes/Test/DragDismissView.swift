//
//  DragDismissView.swift
//  DTunes
//
//  Created by OllyWang on 1/18/26.
//

import SwiftUI

struct DragDismissView: View {
    @State private var showClock = false
    
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            
            // 底层主视图
            if !showClock {
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            showClock = true
                        }
                    }) {
                        Text("显示时钟")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .opacity(showClock ? 0 : 1) // 按钮淡出
                    .scaleEffect(showClock ? 0.8 : 1) // 按钮缩小
                    .offset(y: showClock ? 100 : 0) // 按钮向下移动
//                    .animation(.easeInOut(duration: 0.1), value: showClock)
                }
                .padding(.bottom, 50)
            }
            
            // 顶层时钟视图
            if showClock {
                TestClockView(showClock: $showClock)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .ignoresSafeArea()
    }
}

struct TestClockView: View {
    @Binding var showClock: Bool
    // 实时记录拖拽的偏移量
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            
            ZStack {
                Color.orange
                    .mask{
                        ContainerRelativeShape()
                                .inset(by: 0) // 可以根据需要缩进
                    }
                VStack {
                    // 顶部增加一个“指示条”，增加 Sheet 的视觉暗示
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding(.top, 10)
                    
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.down")
                                .font(.title2).bold().foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(.white.opacity(0.2)))
                        }
                        .padding(.leading, 20)
                        Spacer()
                    }
                    
                    Spacer()
                    Text(Date(), style: .time)
                        .font(.system(size: 80, weight: .thin, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // --- 核心手势逻辑 ---
            .offset(y: dragOffset > 0 ? dragOffset : 0) // 只允许向下拖动
            
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // 增加阻尼感：如果向上拉，拖动会变慢（可选）
                        if value.translation.height > 0 {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        // 如果下滑速度够快，或者下滑距离超过屏幕的 1/4，则关闭
                        if value.translation.height > screenSize.height * 0.25 || value.velocity.height > 500 {
                            dismiss()
                        } else {
                            // 否则弹回顶部
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            dragOffset = 0 // 重置偏移量，防止下次打开位置错误
            showClock = false
        }
    }
}

#Preview {
    DragDismissView()
}
