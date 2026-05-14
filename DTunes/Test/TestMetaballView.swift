//
//  TestMetaballView.swift
//  DTunes
//
//  Created by OllyWang on 1/10/26.
//

import SwiftUI

struct TestMetaballView: View {
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        Canvas { context, size in

            // 🔴 Alpha 阈值：让模糊后的形状重新变成实心
            context.addFilter(.alphaThreshold(min: 0.5, color: .red))
            
            // 🔴 模糊半径：决定“水滴黏连”的柔软程度
            context.addFilter(.blur(radius: 20))

            context.drawLayer { layer in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                // 第一个圆（固定）
                layer.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x - 40,
                        y: center.y - 40,
                        width: 80,
                        height: 80
                    )),
                    with: .color(.red)
                )

                // 第二个圆（向右拖拽）
                layer.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x - 40 + dragOffset.width,
                        y: center.y - 40 + dragOffset.height,
                        width: 80,
                        height: 80
                    )),
                    with: .color(.red)
                )
            }

        }
        .frame(height: 300)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // 👉 只允许向右拖（更像水滴拉伸）
                    dragOffset = CGSize(
                        width: max(0, value.translation.width),
                        height: value.translation.height * 0.3
                    )
                }
                .onEnded { _ in
                    // 松手回弹
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        dragOffset = .zero
                    }
                }
        )
    }
}

#Preview {
    TestMetaballView()
}
