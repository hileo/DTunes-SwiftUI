//
//  TestLoading.swift
//  DTunes
//
//  Created by OllyWang on 1/27/26.
//

import SwiftUI


struct TestLoading: View {
    @State var start = false

    var body: some View {
        VStack{
            HStack{
                
                Rectangle ()
                    .overlay {
                        LinearGradient(colors: [.clear, .white, .clear], startPoint: .leading,
                                       endPoint: .trailing)
                        .offset(x: start ? -1110 : 50)
                    }
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: start)
                    .mask {
                        Image(systemName: "shuffle")
                            .resizable()
                            .fontWeight(.thin)
                            .frame(width: 40, height: 30)
                    }
                    .onAppear {
                        start.toggle()
                    }
                    .background(.gray)

            }
          
            HStack {
                Circle()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(AngularGradient.init(gradient: Gradient(colors:[.gray.opacity(0.1), .gray.opacity(0.25),.gray.opacity(0.5), .gray]), center: .center, angle:.degrees(start ? 360 : 0)))
                    . mask {
                        Image(systemName: "shuffle.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    .onAppear() {
                        withAnimation (.linear(duration: 1).repeatForever(autoreverses:false)){
                            start.toggle()
                        }
                    }
            }
        }
        
    }
}

#Preview {
    TestLoading()
}
