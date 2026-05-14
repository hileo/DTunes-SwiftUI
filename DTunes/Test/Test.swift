//
//  Test.swift
//  DTunes
//
//  Created by OllyWang on 12/21/25.
//


import SwiftUI

struct Test: View {
    // 模拟数据
    let items = Array(0..<69)
    // 定义 3 列网格
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // 控制动画触发的状态
    @State private var startAnimation = false
    
    var body: some View {
        ScrollView {
            // 顶部标题区域（模拟视频头部）
            VStack(alignment: .leading) {
                Text("慵懒的")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text("午后 ☀️")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.top, 40)
            
            // 核心网格部分
            LazyVGrid(columns: columns, spacing: 10) {
                // 关键点 1: 获取索引 (index)
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    AlbumCard()
                        // 关键点 2: 将动画修饰符应用在每个 Cell 上
                        .offset(y: startAnimation ? 0 : 14)
                        .opacity(startAnimation ? 1 : 0)       // 初始透明，结束显示
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.5)
                            .delay(Double(index) * 0.02), // 关键点 3: 错峰延迟
                            value: startAnimation
                        )
                }
            }
            .padding(.horizontal)
        }
        .background(Color.yellow.opacity(0.8)) // 模拟视频背景色
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // 关键点 4: 视图出现时触发动画
            startAnimation = true
        }
    }
}

// 模拟的卡片视图
struct AlbumCard: View {
    
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.3)) // 模拟封面占位
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(systemName: "music.note")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            )
            .cornerRadius(8)
    }
}

 
#Preview {
    Test()
}
