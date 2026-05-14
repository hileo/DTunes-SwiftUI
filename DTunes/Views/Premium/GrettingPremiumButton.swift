//
//  GrettingPremiumButton.swift
//  DTunes
//
//  Created by OllyWang on 4/13/26.
//

import SwiftUI

struct GrettingPremiumButton: View {
    var onConfirm: () -> Void

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
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
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
                                .font(.system(size: 33))
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
            }
        }
       
    }
}

#Preview {
    GrettingPremiumButton(){}
}
