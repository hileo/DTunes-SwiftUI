//
//  iOS17DismissView.swift
//  DTunes
//
//  Created by OllyWang on 1/14/26.
//

import SwiftUI

struct iOS17DismissView: View {
    @State private var showDetail = false
    
    var body: some View {
        Button(action: { showDetail = true }) {
            Text("打开全屏视图")
                .font(.headline)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
        }
        // 使用 fullScreenCover
        .fullScreenCover(isPresented: $showDetail) {
            DraggableFullScreenView()
        }
    }
}

#Preview {
    iOS17DismissView()
}
