//
//  FlipImage.swift
//  DTunes
//
//  Created by OllyWang on 1/17/26.
//

import SwiftUI



struct FlipImage: View {
    @State private var isPlaying = false

       var body: some View {
           VStack(spacing: 20) {

               FlipPlayingImage(image: Image("DefaultIcon"), isPlaying: $isPlaying)

               Button(isPlaying ? "Pause" : "Play") {
                   isPlaying.toggle()
               }
           }
       }
}

#Preview {
    FlipImage()
}
