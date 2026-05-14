//
//  Landscape.swift
//  DTunes
//
//  Created by OllyWang on 1/15/26.
//

import SwiftUI

private struct IsLandscapeKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isLandscape: Bool {
        get { self[IsLandscapeKey.self] }
        set { self[IsLandscapeKey.self] = newValue }
    }
}

struct LandscapeDetector: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .environment(\.isLandscape, geometry.size.width > geometry.size.height)
                .animation(.none, value: geometry.size) // 避免布局抖动
        }
    }
}

extension View {
    /// 开启全局横竖屏检测
    func observeOrientation() -> some View {
        self.modifier(LandscapeDetector())
    }
}
