//
//  PremiumButton.swift
//  DTunes
//
//  Created by OllyWang on 4/12/26.
//

import SwiftUI

struct PremiumButton: View {
    var onConfirm: () -> Void
    @Environment(\.isLandscape) private var isLandscape
    @Environment(\.isPad) private var isPad

    @State private var phase: CGFloat = -1.5
    @State private var offset: CGFloat = -1.0

    var body: some View {
        Button{
            onConfirm()
        }label: {
            premiumView
        }
        .buttonStyle(.plain)
    }
    
    var premiumView:some View{
        ZStack{
            HStack(spacing: 20,) {
                // 左侧星星图标
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 10)
                    .overlay {
                        GeometryReader { geo in
                            let width = geo.size.width
                            
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.8),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: width * 0.5)
                            .rotationEffect(.degrees(20)) // 让高光有一点斜角，更高级
                            .offset(x: offset * width * 2)
                            .blendMode(.plusLighter) // 关键：高光叠加效果
                        }
                        .mask(
                            Image(systemName: "sparkles")
                                .font(.system(size: 45))
                        )
                    }
                    .onAppear {
                        offset = -1
                        withAnimation(
                            .linear(duration: 2.0)
                            .repeatForever(autoreverses: false)
                        ) {
                            offset = 1.5
                        }
                    }
                    .padding(.leading, 20)
                // 右侧文字
                VStack(alignment: .leading, spacing: 4) {
                    Text("Setting_Premium")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Setting_PremiumTip")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
        }
        .background{
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial) // 深褐色背景
                .frame(height: isPad ? 130 : 90)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 4)
                )
                .preferredColorScheme(.dark)
        }
        .padding(.horizontal, isLandscape
            ? (isPad ? 260 : 160)
            : (isPad ? 100 : 30)
        )
        .onAppear {
            // 创建循环动画
            withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                phase = 1.5
            }
        }
    }
}


#Preview {
    PremiumButton(){
        print("ff")
    }
}

