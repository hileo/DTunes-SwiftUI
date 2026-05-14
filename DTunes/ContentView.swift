//
//  ContentView.swift
//  DTunes
//
//  Created by OllyWang on 11/13/25.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    // MARK: - Properties
    @EnvironmentObject var musicAuth: MusicAuthViewModel

    @EnvironmentObject var player: PlayerStore
    @EnvironmentObject var playerManager: PlayerManager
    @Namespace private var namespace
    @Environment(\.isLandscape) var isLandscape

    @State private var select = 0
    @State private var selectedID : String = ""
    @State private var show = false
    @State private var showClock = false
    @State private var hasScrolled = false
    
    @State private var isGuidePresented: Bool = false
    // MARK: - Body
    var body: some View {
        ZStack {
            tabView
            if show {
                playlistDetail
            }
        }
        .task { await initializeAppData() }
        .overlay(alignment: .bottom) {
            TabBar(hasScrolled: $hasScrolled, showClock: $showClock)
        }
        .overlay {
            if showClock {
                clockOverlay
            }
        }
        .adaptivePresentation(isPresented: $playerManager.paywallShow) {
            PaywallView()
        }
        .sheet(item: $musicAuth.alertType) { type in
            sheetView(type: type)
        }
        .onChange(of: musicAuth.alertType) { _, newValue in
            if newValue != nil {
                print("sheet 展示了")
            } else {
                print("sheet 关闭了")
                isGuidePresented = true
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func sheetView(type: MusicAuthViewModel.AlertType) -> some View {
        
        switch type {
            
        case .needPermission:
            AppleMusicPermission {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .onAppear{
                print("ffeeee 11")
            }
            
        case .needSubscription:
            AppleMusicSubscription {
                if let url = URL(string: "https://music.apple.com/subscribe") {
                    UIApplication.shared.open(url)
                }
            }.onAppear{
                print("ffeeee 22")
            }
        }
    }
    
    private var tabView: some View {
        TabView(selection: $select) {
            PlaylistDtunesView(selectedID: $selectedID, show: $show, hasScrolled: $hasScrolled, namespace: namespace)
                .tag(0)
                .overlay{
                    if player.shownGuide {
                        GuideHandGestureView()
                    }
                }
            
            PlaylistUserView(selectedID: $selectedID, show: $show, hasScrolled: $hasScrolled, namespace: namespace)
                .tag(1)
        }
        .background(.black)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: select) { _,newValue in
            withAnimation(){
                player.shownGuide = false
            }
            Task {
                await musicAuth.checkAuthorization(playerManager: playerManager)
            }
        }
    }
    
    private var playlistDetail: some View {
        // 合并两个 ForEach，减少代码重复
        let allPlaylists = player.playlists + player.userPlaylists
        
        return ForEach(allPlaylists) { playlist in
            if playlist.playlistID == selectedID {
                PlaylistView(
                    playlist: playlist,
                    isAnimating: true,
                    namespace: namespace,
                    show: $show,
                    hasScrolled: $hasScrolled,
                    showClock: $showClock
                )
                .zIndex(1)
                .transition(.asymmetric(
                    insertion: .opacity.animation(.spring(response: 0.4, dampingFraction: 0.6)),
                    removal: .opacity.animation(.spring())
                ))
            }
        }
    }
    
    private var clockOverlay: some View {
        Group {
            if let firstPlaylist = loadPlaylists().first {
                ClockView(showClock: $showClock, playlist: firstPlaylist)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
    
    // MARK: - Logic Methods
    
    private func initializeAppData() async {
        await musicAuth.checkAuthorization(playerManager: playerManager)
        await loadUserPlaylists()
        await loadTracksWithPriority()
    }
    
    private func loadUserPlaylists() async {
        guard player.userPlaylists.isEmpty else { return }
        do {
            player.userPlaylists = try await fetchUserPlaylists(selectedSort: player.sortType)
        } catch {
            print("用户播放列表加载失败: \(error)")
        }
    }
    
    private func loadTracksWithPriority() async {
        guard let current = player.currentPlaylist else { return }
        let currentID = current.playlistID

        print("currentPlaylist 22=",currentID)

        if player.tracksPlaylistDict[currentID] == nil {
            do {
                let tracks = try await fetchTracksFromAMPlaylistID(from: currentID)
                
                await MainActor.run {
                    guard !show else { return } //暂时解决用户快速点击歌单问题
                    player.tracksPlaylistDict[currentID] = tracks
                    player.nowPlayingTracks = tracks
                    player.nowPlayingPlaylist = current
                }
                
                try? await playerManager.setQueue(tracks: tracks)
                await playerManager.playPause()
            } catch {
                print("音轨加载失败: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PlayerStore(purchaseManager: PurchaseManager()))
        .environmentObject(PlayerManager())
}
