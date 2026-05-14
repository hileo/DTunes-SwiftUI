//
//  TestSheetView.swift
//  DTunes
//
//  Created by OllyWang on 1/18/26.
//

import SwiftUI

struct TestSheetView: View {
    @State private var isShowingSheet = false
        var body: some View {
            Button(action: {
                isShowingSheet.toggle()
            }) {
                Text("Show License Agreement")
            }
            .sheet(isPresented: $isShowingSheet,
                   onDismiss: didDismiss) {
                VStack {
                    Text("License Agreement")
                        .font(.title)
                        .padding(50)
                    Text("""
                            Terms and conditions go here.
                        """)
                        .padding(50)
                    Button("Dismiss",
                           action: { isShowingSheet.toggle() })
                }
                .presentationDetents([.height(300)])
            }
        }


        func didDismiss() {
            // Handle the dismissing action.
        }
}

#Preview {
    TestSheetView()
}
