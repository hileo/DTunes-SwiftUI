//
//  ClockFontPicker.swift
//  DTunes
//
//  Created by OllyWang on 1/19/26.
//

import SwiftUI


enum ClockFontStyle: CaseIterable, Identifiable {
    case colorFont1   // Button 1
    case colorFont2     // Button 2
    case colorFont3       // Button 3
    case colorFont4      // Button 4
    
    var id: Self { self }
    
    func font(fontSize: CGFloat) -> Font {
        switch self {
        case .colorFont1:
            // 可以在 baseSize 基础上微调偏移量
            return .system(size: fontSize, weight: .thin, design: .rounded)
        case .colorFont2:
            return .system(size: fontSize, weight: .medium, design: .rounded)
        case .colorFont3:
            return .custom("TrainOne-Regular", size: fontSize * 0.9)
        case .colorFont4:
            return .custom("Prisma", size: fontSize)
        }
    }
    
    func fontDate(size: CGFloat) -> Font {
        switch self {
        case .colorFont1:
            // 可以在 baseSize 基础上微调偏移量
            return .system(size: size, weight: .thin, design: .rounded)
        case .colorFont2:
            return .system(size: size, weight: .medium, design: .rounded)
        case .colorFont3:
            return .custom("TrainOne-Regular", size: size)
        case .colorFont4:
            return .custom("Prisma", size: size)
        }
    }
    
    // ✅ 关键：是否使用 .monospacedDigit()
    var usesMonospacedDigit: Bool {
        switch self {
        case .colorFont1, .colorFont2:
            return true
        case .colorFont3, .colorFont4:
            return false
        }
    }
    
    var name: String {
        switch self {
        case .colorFont1: return "System Medium"
        case .colorFont2: return "System Thin"
        case .colorFont3: return "TrainOne-Regular"
        case .colorFont4: return "Prisma"
        }
    }
    
    var imageName: String {
        switch self {
        case .colorFont1: return "ClockFont1"
        case .colorFont2: return "ClockFont2"
        case .colorFont3: return "ClockFont3"
        case .colorFont4: return "ClockFont4"
        }
    }
}

struct ClockFontPicker: View {

    @Binding var selectedFont: ClockFontStyle
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    var body: some View {
        HStack(spacing: 15) { //横向排列，间隔 20
            ForEach(ClockFontStyle.allCases) { font in
                Button {
                    feedbackGenerator.prepare()
                    feedbackGenerator.impactOccurred(intensity: 0.9)
                    withAnimation(.easeInOut(duration: 0.35)) {
                        selectedFont = font
                    }
                } label: {
                    Image(font.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 40) // 根据需求调整尺寸
                        .background(Color.gray.opacity(0.2)) // 添加背景色方便观察圆角
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay {
                            // 5. 条件渲染：仅在选中时显示白色描边
                            if selectedFont == font {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(.white, lineWidth: 2)
                                    .transition(.opacity)   // 👈 淡入淡出
                            }
                        }
                        .scaleEffect(selectedFont == font ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedFont)
                        .shadow(
                            color: .black.opacity(0.3),
                            radius: 4,
                            x: 1,
                            y: 1
                        )
                }
                // 去除按钮默认的高亮变色效果（可选）
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}

extension View {
    @ViewBuilder
    func monospacedDigitIf(_ condition: Bool) -> some View {
        if condition {
            self.monospacedDigit()
        } else {
            self
        }
    }
}


// 1. 定义一个可动画的字体 Modifier
struct AnimatableFontModifier: AnimatableModifier {
    var fontSize: CGFloat
    var fontName: String // 传入字体名称

    var animatableData: CGFloat {
        get { fontSize }
        set { fontSize = newValue }
    }

    func body(content: Content) -> some View {
        // 每次 fontSize 改变时，这里都会重新执行
        content.font(.custom(fontName, size: fontSize))
    }
}

// 2. 封装成方便调用的扩展
extension View {
    func animatableClockFont(name: String, size: CGFloat) -> some View {
        self.modifier(AnimatableFontModifier(fontSize: size, fontName: name))
    }
}
