//
//  UserPlaylistView.swift
//  DTunes
//
//  Created by OllyWang on 11/13/25.
//

import SwiftUI
import MusicKit

struct PlaylistUserView: View {
    // MARK: - Properties
    @Binding var selectedID: String
    @Binding var show: Bool
    @Binding var hasScrolled: Bool
    
    var namespace: Namespace.ID
    
    @EnvironmentObject var player: PlayerStore
    @EnvironmentObject var playerManager: PlayerManager
    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isCompact) var isCompact
    @Environment(\.isPad) var isPad

    @State private var showSheet = false
    @State private var lastOffset: CGFloat = 0
    @State private var startOffset: CGFloat? = nil
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    // MARK: - Constants
    private let cellBackgroundColors = (start: Color(hex: "23D5A3"), end: Color(hex: "1F82CC"))
    private let waveViewColors = (start: Color(hex: "53FFC2"), end: Color(hex: "54B6FF"))
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    scrollDetection
                    
                    head
                        .padding(.horizontal)
                    
                    cards
                }
            }
            .coordinateSpace(name: "scroll")
            .background(Color.black)
            .ignoresSafeArea()
        }
    }
    
    // MARK: - View Components
    
    /// 顶部用户信息与图标
    var head: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                UserTitleView()
                
                Text("Lan_UserPlaylistForYou")
                    .PlaylistSubTitle()
                    .foregroundStyle(.gray.opacity(0.7))
            }
            .padding(.leading, 10)
            
            Spacer()
            
            SortMenuView()
                .padding(.top, isLandscape ? 10 : 6)
                .padding(.trailing, isLandscape ? 20 : 6)
        }
        .padding(.top, isLandscape ? 10 : 20)
        .padding(.bottom, isPad ? 5 : 0)
        .padding(.vertical)
        .visualEffect { content, proxy in
            let frame = proxy.frame(in: .scrollView(axis: .vertical))
            let distance = min(0, frame.minY)
            let opacity = max(0, 1 + (distance / 110))
            return content.opacity(opacity)
        }
    }
    
    /// 用户自定义播放列表卡片
    var cards: some View {
        LazyVStack(spacing: 20) {
            // 注意：这里使用了 $player.userPlaylists 以便在闭包中直接修改属性
            ForEach(Array($player.userPlaylists.enumerated()), id: \.offset) { index, $playlist in
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .scrollView(axis: .vertical))
                    let distance = min(0, frame.minY)
                    let isClickable = distance > -10

                    // 根据滚动位置计算颜色进度
                    let normalizedY = calculateNormalizedY(from: frame.minY)
                    
                    let backColor = interpolateColor(
                        from: cellBackgroundColors.start,
                        to: cellBackgroundColors.end,
                        progress: normalizedY
                    )
                    
                    let waveColor = interpolateColor(
                        from: waveViewColors.start,
                        to: waveViewColors.end,
                        progress: normalizedY
                    )
                    
                    UserPlaylistItem(
                        playlist: playlist,
                        isActive: playlist.playlistID == player.currentPlaylist?.playlistID,
                        isAnimating: playlist.playlistID == player.currentPlaylist?.playlistID,
                        namespace: namespace,
                        backColor: backColor,
                        waveColor: waveColor
                    )
                    .frame(height: 220)
                    .visualEffect { content, proxy in
                        content
                            .scaleEffect(1 + distance / 900)
                            .offset(y: -distance / 1.35)
                            .blur(radius: -distance / 60)
                            .brightness(distance / 500)
                    }
                    .allowsHitTesting(isClickable)
                    .onTapGesture {
                        playlist.backColor = backColor.toHex() ?? "ff0000"
                        playlist.waveColor = waveColor.toHex() ?? "00ff00"
                       
                        print("要进入的播放列表 ",playlist.title)
                        
                        //用playlistID 判断唯一性 和 PlaylistDtunesView 不一样
                        if playlist.playlistID != player.currentPlaylist?.playlistID {
                            player.nowPlayingTracks = player.tracksPlaylistDict[playlist.playlistID] ?? []
                        }
                        withAnimation(.openCard) {
                            selectedID = playlist.playlistID
                            show.toggle()
                        }
                    }
                    .onChange(of: frame.minY) { oldValue, newValue in
                        if (oldValue > 0 && newValue <= 0) || (oldValue < 0 && newValue >= 0) {
                            feedbackGenerator.prepare()
                            feedbackGenerator.impactOccurred(intensity: 0.8)
                        }
                    }
                }
                .frame(height: 220)
                .padding(.horizontal, 20)
            }
        }
    }
    
    // 滚动侦测器
    var scrollDetection: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("scroll")).minY
            Color.clear
                .preference(key: ScrollOffsetKey.self, value: minY)
        }
        .frame(height: 0)
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            dispatchScrollLogic(currentOffset: value)
        }
    }
    
    // MARK: - Logic Methods

    /// 计算 Y 轴百分比，用于颜色渐变插值
    private func calculateNormalizedY(from minY: CGFloat) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return (minY / screenHeight).truncatingRemainder(dividingBy: 1)
    }
    
    private func dispatchScrollLogic(currentOffset: CGFloat) {
        // 1. 初始化起点
        if startOffset == nil {
            startOffset = currentOffset
        }
        
        let totalDragDistance = currentOffset - (startOffset ?? currentOffset)
        
        withAnimation(.easeOut(duration: 0.25)) {
            if totalDragDistance < -200 {
                hasScrolled = true
            } else if totalDragDistance > 200 {
                hasScrolled = false
            }
            
            // 回到顶部强制重置
            if currentOffset > -10 {
                hasScrolled = false
            }
        }
        
        // 2. 检测滑动方向切换，重置计算起点
        let delta = currentOffset - lastOffset
        if (delta > 0 && totalDragDistance < 0) || (delta < 0 && totalDragDistance > 0) {
            startOffset = currentOffset
        }

        lastOffset = currentOffset
    }
    
}

//#Preview {
//    @Previewable @Namespace var namespace
//    PlaylistUserView(selectedID: .constant(UUID()), show: .constant(true), hasScrolled: .constant(false), namespace: namespace)
//        .environmentObject(PlayerStore(purchaseManager: PurchaseManager()))
//}
