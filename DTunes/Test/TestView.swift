//
//  TestView.swift
//  DTunes
//
//  Created by OllyWang on 12/27/25.
//

import SwiftUI

struct TestView: View {
    
    @State private var selectedIndex: Int = 0
    private let imageNames = [
           "LayoutClock",
           "LayoutCover",
           "LayoutArtworkWall",
           "LayoutWave"
       ]
    
    private let sizeWidth: CGFloat = 140
    private let sizeHeight: CGFloat = 80

    private let borderWidth: CGFloat = 3
    private let cornerRadius: CGFloat = 15

    var body: some View {
        ViewThatFits(in: .horizontal) {

            // 横屏：一排 4 个
            HStack(spacing: 30) {
                layoutButtons
            }

            // 竖屏：2 × 2
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2)
                ],
                spacing: 30
            ) {
                layoutButtons
            }
        }
        .background(Color.gray)
    }

    private var layoutButtons: some View {
        ForEach(0..<4, id: \.self) { index in
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 1.0)) {
                    selectedIndex = index
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            index == selectedIndex ? Color.green : Color.clear,
                            lineWidth: borderWidth
                        )
                        .frame(
                            width: sizeWidth - borderWidth*2 - 4,
                            height: sizeHeight - borderWidth
                        )

                    Image(imageNames[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: sizeWidth, height: sizeHeight)
                        .cornerRadius(index == selectedIndex ? 0 : cornerRadius)
                        .scaleEffect(index == selectedIndex ? 0.91 : 1.0)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
//
//    @State private var selectedIndex: Int = 0   // 默认选中第一个
//
//    private let size: CGFloat = 100
//    private let borderWidth: CGFloat = 3
//    private let cornerRadius: CGFloat = 25
//
//    var body: some View {
//        HStack(spacing: 16) {
//            ForEach(0..<4, id: \.self) { index in
//                Button {
//                    withAnimation(.spring(response: 0.35, dampingFraction: 1.0)) {
//                        selectedIndex = index
//                    }
//                } label: {
//                    ZStack {
//                        // 边框（始终占位）
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .stroke(
//                                index == selectedIndex ? Color.green : Color.clear,
//                                lineWidth: borderWidth
//                            )
//                            .frame(
//                                width: size - borderWidth,
//                                height: size - borderWidth
//                            )
//                            .opacity(index == selectedIndex ? 1.0 : 0.0)
//
//                        // 图片
//                        Image("Widget3")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: size, height: size)
//                            .cornerRadius(cornerRadius)
//                            .scaleEffect(index == selectedIndex ? 0.88 : 1.0)
//                    }
//                }
//                .buttonStyle(.plain)
//            }
//        }
//    }
}

#Preview {
    TestView()
}
