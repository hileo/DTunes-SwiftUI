//
//  TestItem.swift
//  DTunes
//
//  Created by OllyWang on 12/27/25.
//

import SwiftUI

struct TestItem: View {
    var namespace: Namespace.ID

    var body: some View {
        ZStack{
            VStack{
                Color.blue
            }
            .frame(height: 220)
            .mask{
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .matchedGeometryEffect(id: "maskItem\(UUID())", in: namespace)
            }
        }
    }
}

//#Preview {
////    @Previewable @Namespace var namespace
////    TestItem(namespace: namespace)
//    TestItem()
//}
