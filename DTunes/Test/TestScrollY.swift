//
//  TestScrollY.swift
//  DTunes
//
//  Created by OllyWang on 1/1/26.
//

import SwiftUI

struct TestScrollY: View {
    @State private var scrollY: CGFloat = 0
    // 记录初始位置，用来计算净偏移量
    @State private var initialOffset: CGFloat? = nil

    // 定义 3 列网格
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var body: some View {
            // 🎯 标题部分
        ZStack{
            VStack{
                head
                content3
            }
            
        }
           
    }
    var head:some View{
        Text("Hello, World!")
            .font(.largeTitle)
            .bold()
            // 计算相对于初始位置拉动了多少
            .scaleEffect(max(1, 1 + (scrollY / 150)))
            .padding(.vertical, 30)
            .zIndex(1) // 确保在最上层
    }
    
    var content:some View{
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 20) {
                    // 🚩 关键：放置在最顶部的追踪器
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("scroll")).minY
                        Color.clear
                            .preference(key: ScrollOffsetKey.self, value: offset)
                    }
                    .frame(height: 0)

                    // 🕸️ LazyVGrid 内容
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(0..<30) { i in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.1))
                                .frame(height: 100)
                                .overlay(Text("\(i)"))
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .coordinateSpace(name: "scroll") // 必须和上面 frame(in:) 的名字一致
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                if initialOffset == nil {
                    initialOffset = value // 捕获初始位置（通常是 0 或安全区域高度）
                }
                // 计算实际向下拉动的距离
                let diff = value - (initialOffset ?? 0)
                // 只有向下拉（diff > 0）时才赋值
                scrollY = diff > 0 ? diff : 0
                
                print("Pull distance: \(scrollY)") // 调试查看数值
            }
        }
        
    }
    
    var content2:some View{
        ScrollView {
            ZStack(alignment: .top) {
                // 🚩 追踪器：必须在 ScrollView 的最顶端
//                GeometryReader { proxy in
//                    let offset = proxy.frame(in: .named("myScroll")).minY
//                    Color.clear
//                        .preference(key: ScrollOffsetKey.self, value: offset)
//                }
//                .frame(height: 0) // 不占空间
                
                // 🕸️ 网格内容
                LazyVGrid(columns: columns, spacing: 10) {
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("myScroll")).minY
                        Color.clear
                            .preference(key: ScrollOffsetKey.self, value: offset)
                    }
                    .frame(height: 0) // 不占空间
                    ForEach(0..<60) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.2))
                            .frame(height: 100)
                            .overlay(Text("\(i)"))
                    }
                }
                .padding()
            }
        }
        // ⚠️ 关键：给 ScrollView 绑定坐标系名称
        .coordinateSpace(name: "myScroll")
    // 3. 监听变化
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            self.scrollY = value

        }
    }
    
    var content3:some View{
        ScrollView {
            VStack(spacing: 0) {


                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<60) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.2))
                            .frame(height: 100)
                            .overlay(Text("\(i)"))
                    }
                }
                .overlay(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: proxy.frame(in: .named("scroll2")).minY
                            )
                    }
                )
            }
        }
        .coordinateSpace(name: "scroll2")
        .onPreferenceChange(ScrollOffsetKey.self) { y in
            self.scrollY = y
            print("scrollY =", y)
        }
    }
}

#Preview {
    TestScrollY()
}
