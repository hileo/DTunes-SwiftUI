//
//  TestButton.swift
//  DTunes
//
//  Created by OllyWang on 1/2/26.
//

import SwiftUI

struct TestButton: View {
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        ZStack{
            VStack{
                head
                Spacer()

            }
           
        }
        .mask {
            RoundedRectangle(cornerRadius:30, style: .continuous)
        }
        .ignoresSafeArea()
    }
    
    var button: some View{
        Button {
          
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.1), in: Circle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(30)
    }
    
    var head: some View {
        ZStack(alignment: .top){
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.gray)
                .frame(height: 140)
                .overlay(
                    VStack(alignment: .leading, spacing: 10){
                        Text("d")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.black)
                        Text("s")
                            .font(.title.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(90)
                    .padding(.top, 25)
                    .foregroundStyle(.red)
                    .background(.cyan)
                )
            
           
            button
        }
//        .frame(height: verticalSizeClass == .compact ? 180 : 240)
        .frame(height: 180)
        .clipped()
        .background(.green)
    }
    
}

#Preview {
    TestButton()
}
