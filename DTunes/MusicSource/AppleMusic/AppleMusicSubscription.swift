//
//  AppleMusicSubscription.swift
//  DTunes
//
//  Created by OllyWang on 4/10/26.
//

import SwiftUI

struct AppleMusicSubscription: View {
    
    var onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 背景
            
//            Color.black
//                .ignoresSafeArea()
            
            
            // 2️⃣ 底部波浪背景（重点）
            WaveAnimationView()
                .frame(height: 80)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false) // 不拦截点击

            VStack(spacing: 24) {

                Spacer()

                // 图标
                Image(systemName: "music.note")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.45, blue: 0.95),
                                Color(red: 0.95, green: 0.35, blue: 0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // 标题
                Text("Lan_JoinAppleMusic")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)

                // 副标题
                Text("Lan_JoinAppleMusic_Sub")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)


                // 按钮
//                Button {
//
//                } label: {
//                    Text("Apple Music")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundStyle(.black)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 56)
//                        .background(Color.white)
//                        .clipShape(Capsule())
//                }
//                .padding(.horizontal, 60)
//                .padding(.bottom, 20)
//                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button{
                    dismiss()
                    onConfirm()
                } label: {
                    Text("Apple Music")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                    
                }
                .preferredColorScheme(.dark)
                .applyGlassEffect(shape: RoundedRectangle(cornerRadius: 27))


                .padding(.horizontal, 60)
                .padding(.bottom, 50)
                // 添加一个轻微的阴影或交互缩放效果（可选）
//                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    AppleMusicSubscription(){
        print("Preview confirm tapped")
    }
}
