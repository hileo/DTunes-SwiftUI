//
//  DraggableFullScreenView.swift
//  DTunes
//
//  Created by OllyWang on 1/14/26.
//

import SwiftUI

struct DraggableFullScreenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 背景颜色
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.blue.gradient)
                            .frame(height: 200)
                        
                        ForEach(0..<10) { _ in
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                                .frame(height: 100)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("详情页面")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
            // 关键：应用位移
            .offset(y: scrollOffset)
            // 关键：手势处理
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // 允许下拉，阻断上划
                        if value.translation.height > 0 {
                            scrollOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 150 {
                            // 使用 iOS 17 推荐的动画曲线
                            withAnimation() {
                                dismiss()
                            }
                        } else {
                            withAnimation() {
                                scrollOffset = 0
                            }
                        }
                    }
            )
        }
    }
}

#Preview {
    DraggableFullScreenView()
}
