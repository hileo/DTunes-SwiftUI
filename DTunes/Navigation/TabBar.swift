//
//  TabBar.swift
//  DTunes
//
//  Created by OllyWang on 1/11/26.
//

import SwiftUI
import Combine
import VariableBlur
import MusicKit

struct TabBar: View {
    @Binding var hasScrolled: Bool
    @Binding var showClock: Bool

    @EnvironmentObject var playerManager: PlayerManager

    @State private var icons: [FloatingIconModel] = []
    @State private var iconIndex = 0
    @State private var shadowRadius: CGFloat = 0
    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isCompact) var isCompact

    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    let iconPool = ["music.quarternote.3", "cup.and.heat.waves", "moon.zzz", "tennisball"]
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    private let buttonHeight = 54.0
    private let buttonCorner = 27.0
    private let maxRadius: CGFloat = 6

    var body: some View {
        ZStack{
            
//            HStack {
//                Spacer()
//                Group{
//                    NavigationLink {
//                        SettingsView()
//                    } label: {
//                        Image("Setting")
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 50, height: 50)
//                            .applyGlassEffect(shape: Circle())
//                    }
//                }
//                .padding(isLandscape ? 16 : 20)
//                .padding(.trailing, isLandscape ? 14 : 0)
//                .opacity(hasScrolled ? 0 : 1)
//                .scaleEffect(hasScrolled ? 0.9 : 1)
//            }
//            .frame(maxHeight: .infinity, alignment: .top)
            
            VStack {
                VariableBlurView(maxBlurRadius: 8, direction: .blurredBottomClearTop)
                    .frame(height: isCompact ? (isLandscape ? 40 : 85) : 85)
                    .allowsHitTesting(false)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)

            HStack{
                Button(){
//                    Task {
//                           await playerManager.toggleFavorite()
//                       }
//                    playerManager.isLiked.toggle()
                    feedbackGenerator.prepare()
                    feedbackGenerator.impactOccurred(intensity: 0.9)
                    if !playerManager.isLiked{
                        playerManager.addFavoriteSong()
                    }else{
                        playerManager.removeFavoriteSong()
                    }
                } label: {
                    ZStack{
                        imageLiked(image: Image(systemName: "heart.fill"), show: playerManager.isLiked, isLiked: playerManager.isLiked, animate: playerManager.animateLiked)
                        imageLiked(image: Image(systemName: "heart"), show: !playerManager.isLiked, isLiked: playerManager.isLiked, animate: playerManager.animateLiked)
                    }
                }
                .applyGlassEffect(shape: Circle())
                .scaleEffect(hasScrolled ? 0.5 : 1)
                .opacity(hasScrolled ? 0.0 : 1)
                .offset(x:hasScrolled ? 40.0 : 0)

               buttonClock
               
                Button(){
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        playerManager.isPlaying.toggle()
                    }
                    Task {
                        await playerManager.playPause()
                    }
                } label: {
                    Group {
                        if playerManager.isPlaying {
                            Image(systemName: "pause.fill")
                        } else {
                            Image(systemName: "play.fill")
                        }
                    }
                    .font(.system(size: 22))
                    .fontWeight(.regular)
                    .frame(width: buttonHeight, height: buttonHeight)
                    .foregroundStyle(Color.white)
                    .transition(.scale(scale: 0.0).combined(with: .opacity))
                }
                .applyGlassEffect(shape: Circle())
                .scaleEffect(hasScrolled ? 0.5 : 1)
                .opacity(hasScrolled ? 0.0 : 1)
                .offset(x:hasScrolled ? -40.0 : 0)
            }
            .offset(y:hasScrolled ? 18.0 : 0)
            .frame(height: 88, alignment: .top)
            .frame(maxWidth:.infinity)
            .onReceive(timer) { _ in
                if playerManager.isPlaying {
                    // 只需向数组添加数据，动画由 ModernFloatingIcon 自己处理
                    let newIcon = FloatingIconModel(
                        name: iconPool[iconIndex],
                        startX: CGFloat.random(in: -30...30)
                    )
                    
                    iconIndex = (iconIndex + 1) % iconPool.count
                    icons.append(newIcon)
                }
            }
            .onChange(of: playerManager.isPlaying) { _, newValue in
                if newValue {
                    startBreathing()
                } else {
                    stopBreathing()
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()

    }
    
    var buttonClock: some View{
        Button(){
            withAnimation(.openClock){
                showClock.toggle()
            }
        } label: {
            HStack(spacing: 0) {
                ZStack{
                   
//                        // 粒子层
//                        ForEach(icons) { icon in
//                            FloatingIcon(
//                                imageName: icon.name,
//                                xOffset: icon.startX
//                            ) {
//                                // 动画结束后移除数据，防止数组无限增长
//                                icons.removeAll(where: { $0.id == icon.id })
//                            }
//                            .offset(y:-18)
//                        }
                    
                    
                }
                
                HStack{
                    VStack{
                        if let artwork = playerManager.nowPlayingTrack?.artwork {
                            ArtworkImage(artwork, width: 32, height: 32)
                        } else {
                            ZStack{
//                                Image("DefaultIcon")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .transition(.opacity)
                                ProgressView()
                                    .tint(Color.white.opacity(0.7))
//                                    .scaleEffect(0.6)
                            }
                            
                        }
                    }
                    .id(playerManager.nowPlayingTrack?.id ?? "placeholder")
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
                    .padding(.leading, 15)
                    .scaleEffect(playerManager.isPlaying ? 1.0 : 0.9)

                    .scaleEffect(hasScrolled ? 0.5 : 1)
                    .opacity(hasScrolled ? 0.0 : 1)
                    .offset(x:hasScrolled ? 20.0 : 0)
//                    .onTapGesture {
//                        print("2")
//                    }
                    
                    Spacer()
                    
                    Text(playerManager.nowPlayingTrack?.title ?? NSLocalizedString("Play_NowPlaying", comment: "Now Playing fallback"))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width:hasScrolled ? 140 : 90)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .id(playerManager.nowPlayingTrack?.id ?? "placeholder")
                }
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.35), value: playerManager.nowPlayingTrack?.id)
                
                Spacer()
                
                // 3. 右侧 Icon：距离右边5
                Image(systemName: "circle.grid.cross.down.filled")
                    .foregroundColor(.white)
                    .font(.system(size: 22))
                    .padding(.trailing, 15)
                    .scaleEffect(hasScrolled ? 0.5 : 1)
                    .opacity(hasScrolled ? 0.0 : 1)
                    .offset(x:hasScrolled ? -20.0 : 0)
            }
            .padding(.vertical,8)
            
        }
        .frame(width: hasScrolled ? 160 : 196, height: buttonHeight)
        .applyGlassEffect(shape: RoundedRectangle(cornerRadius: buttonCorner))
        .scaleEffect(hasScrolled ? 0.65 : 1)
    }
    
    private func startBreathing() {
        shadowRadius = 0
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            shadowRadius = maxRadius
        }
    }

    private func stopBreathing() {
        withAnimation(.easeOut(duration: 0.35)) {
            shadowRadius = 0
        }
    }
}

#Preview {
    TabBar(hasScrolled: .constant(false), showClock: .constant(false))
        .environmentObject(PlayerManager())
}
