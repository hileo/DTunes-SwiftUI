//
//  AppleMusicPermission.swift
//  DTunes
//
//  Created by OllyWang on 4/10/26.
//

import SwiftUI

struct AppleMusicPermission: View {
    
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
                Image(systemName: "link")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(.white)

                // 标题
                Text("Lan_ConnectMusic")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)

                // 副标题
                Text("Lan_ConnectMusic_Sub")
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
                    Text("Setting")
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
            
//            VStack(spacing: 20) {
//                
//                Text("需要音乐权限")
//                    .font(.title2)
//                    .bold()
//                
//                Text("请前往设置开启 Apple Music 权限")
//                    .foregroundColor(.secondary)
//                
//                Button("去设置") {
//                    dismiss()
////                    onConfirm()
//                }
//                .buttonStyle(.borderedProminent)
//                
//                Button("取消") {
//                    dismiss()
//                }
//            }
          
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    AppleMusicPermission(){
        print("Preview confirm tapped")
    }
}
