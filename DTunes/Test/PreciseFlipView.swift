//
//  PreciseFlipView.swift
//  DTunes
//
//  Created by OllyWang on 1/17/26.
//

import SwiftUI

struct PreciseFlipView: View {
    @State private var playButton = false
        
        // 定义动画的三个阶段：0度，90度（侧面），180度（翻面）
        enum FlipPhase: CaseIterable {
            case initial, middle, final
            
            var angle: Double {
                switch self {
                case .initial: return 0
                case .middle: return 90
                case .final: return 180
                }
            }
        }

        var body: some View {
            VStack(spacing: 50) {
                Image("DefaultIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
                    // 移除 padding 干扰，确保绕中心轴转动
                    .padding(.leading, 15)
                    .phaseAnimator(FlipPhase.allCases, trigger: playButton) { content, phase in
                        content
                            .rotation3DEffect(
                                .degrees(playButton ? phase.angle : 0),
                                // y: 1 表示绕纵向中心轴水平翻转
                                axis: (x: 0, y: 1, z: 0),
                                perspective: 0.5
                            )
                    } animation: { phase in
                        switch phase {
                        case .initial:
                            // 从 180 回到 0 的过程不设延迟，瞬间或快速重置准备下一轮
                            return .linear(duration: 0)
                        case .middle:
                            // 第一步：从 0 转到 90，延迟 1 秒触发
                            return .easeInOut(duration: 0.35).delay(1.0)
                        case .final:
                            // 第二步：从 90 转到 180，紧接着转动
                            return .easeInOut(duration: 0.35)
                        }
                    }

                Button(action: { playButton.toggle() }) {
                    Text(playButton ? "停止" : "开始循环翻转")
                        .padding()
                        .background(playButton ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
}

#Preview {
    PreciseFlipView()
}
