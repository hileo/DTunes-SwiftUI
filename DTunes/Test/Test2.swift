//
//  Test2.swift
//  DTunes
//
//  Created by OllyWang on 12/27/25.
//

import SwiftUI

struct Test2: View {
    @Namespace var namesapce2

    var body: some View {
        ScrollView {
            VStack(spacing: 3) {
                ForEach(0..<20) { i in
                    TestItem(namespace: namesapce2)
                }
            }
            .padding()
        }
    }
}

#Preview {
    Test2()
}
