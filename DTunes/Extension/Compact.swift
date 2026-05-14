//
//  Compact.swift
//  DTunes
//
//  Created by OllyWang on 3/9/26.
//

import SwiftUI

extension EnvironmentValues {
    var isCompact: Bool {
        self.horizontalSizeClass == .compact
    }
}
