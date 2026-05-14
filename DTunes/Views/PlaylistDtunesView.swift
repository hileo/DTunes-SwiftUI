//
//  DtunesPlaylistView.swift
//  DTunes
//
//  Created by OllyWang on 11/13/25.
//

import SwiftUI
import MusicKit

struct PlaylistDtunesView: View {
    // MARK: - Properties
    @Binding var selectedID: String
    @Binding var show: Bool
    @Binding var hasScrolled: Bool

    var namespace: Namespace.ID
    
    @EnvironmentObject var player: PlayerStore
    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var purchaseManager: PurchaseManager

    
    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isCompact) var isCompact
    @Environment(\.isPad) var isPad

    @State private var showSheet = false
    @State private var lastOffset: CGFloat = 0
    @State private var startOffset: CGFloat? = nil
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

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
    
    /// 顶部标题与设置按钮
    var head: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                GreetingTitleView()
                    .onTapGesture(count: 2) {
                        let currentPlaylist = TimePeriod.current().playlist(from: player.playlists)
                        print("double tap ",currentPlaylist.id)
                        withAnimation(.openCard) {
                            selectedID = currentPlaylist.playlistID
                            show.toggle()
                        }

                    }
                Text("Lan_DailySceneMusic")
                    .PlaylistSubTitle()
                    .foregroundStyle(.gray.opacity(0.7))
            }
            .padding(.leading, 10)

            Spacer()
            
            Group {
                
                premiumBnt

                Button {
                    showSheet = true
                } label: {
                    Image("Setting")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .applyGlassEffect(shape: Circle())
                }
                .padding(.top, isLandscape ? 10 : 6)
                .padding(.trailing, isLandscape ? 20 : 6)
                .sheet(isPresented: $showSheet) {
                    SettingsView()
                }
            }
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
    
    @ViewBuilder
    var premiumBnt:some View{
        if !player.appIsPro {
            GrettingPremiumButton(){
                playerManager.paywallShow = true
            }
            .padding(.top, isLandscape ? 10 : 6)
            .padding(.trailing, 5)
        }
    }
    
    /// 播放列表卡片列表
    var cards: some View {
        LazyVStack(spacing: 20) {
            ForEach(Array(player.playlists.enumerated()), id: \.element.id) { index, playlist in
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .scrollView(axis: .vertical))
                    let distance = min(0, frame.minY)
                    // 只有当卡片未被推到顶部模糊区时才允许点击
                    let isClickable = distance > -10

                    let isLock = !player.appIsPro

                    PlaylistItem(
                        playlist: playlist,
                        isActive: playlist.id == player.currentPlaylist?.id,
                        isLock: isLock,
                        isAnimating: playlist.id == player.currentPlaylist?.id,
                        namespace: namespace
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
                        let canAccess = (index == 0) || player.appIsPro
                        
                        guard canAccess else {
                            playerManager.paywallShow = true
                            return
                        }
                        
                        if playlist.playlistID != player.currentPlaylist?.playlistID {
                            player.nowPlayingTracks = player.tracksPlaylistDict[playlist.playlistID] ?? []
                        }
                        print("当前播放列表 ",playlist.title, playlist.playlistID)
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
                    .task {
                        await fetchPlaylistTracks(for: playlist)
                    }
                }
                .frame(height: 220)
                .padding(.horizontal, 20)
            }
        }
    }
    
    /// 展开状态下的占位布局
    var cardsBlank: some View {
        LazyVStack(spacing: 20) {
            ForEach(player.playlists) { _ in
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.white.opacity(0))
                    .frame(height: 220)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    /// 滚动侦测器
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
    
    private func fetchPlaylistTracks(for playlist: PlaylistDT) async {
        let id = playlist.playlistID
        // 如果已经缓存则跳过
        if player.tracksPlaylistDict[id] == nil
        {
            do {
                let tracks = try await fetchTracksFromAMPlaylistID(from: id)
                await MainActor.run {
                    player.tracksPlaylistDict[id] = tracks
                }
            } catch {
                print("Failed to load playlist \(id):", error)
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    PlaylistDtunesView(selectedID: .constant(""), show: .constant(true), hasScrolled: .constant(false), namespace: namespace)
        .environmentObject(PlayerStore(purchaseManager: PurchaseManager()))
}
