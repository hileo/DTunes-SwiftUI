//
//  MenuExampleView.swift
//  DTunes
//
//  Created by OllyWang on 1/19/26.
//

import SwiftUI

struct CustomMenuView: View {
    @State private var isPresented = false
    @State private var selected = "A"

    var body: some View {
        VStack{
            Spacer()
            
            Button() {
                isPresented = true
            }label: {
                Text("打开自定义菜单2")
            }
            .popover(isPresented: $isPresented) {
                // 这里你可以随心所欲地写布局，就像写普通的 SwiftUI 视图一样
                VStack(alignment: .leading, spacing: 15) {
//                    ClockFontPicker()
//                    ClockThemeColor(selectedColor: .constant(.playlistColor))
//                        .padding(.leading, 20)
                }
                .padding()
                .frame(width: 400) // 此时 frame 是生效的
                .presentationCompactAdaptation(.popover) // 关键：让 iPhone 也不全屏显示
            }
        }
        
    }
}

#Preview {
//    MenuExampleView2()
    CustomMenuView()
        .preferredColorScheme(.dark)
}
