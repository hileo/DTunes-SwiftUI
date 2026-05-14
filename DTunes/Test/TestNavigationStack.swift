//
//  TestNavigationStack.swift
//  DTunes
//
//  Created by OllyWang on 1/6/26.
//

import SwiftUI

struct TestNavigationStack: View {
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(1...50, id: \.self) { index in
                        Text("项目 \(index)")
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
}

#Preview {
    TestNavigationStack()
}
