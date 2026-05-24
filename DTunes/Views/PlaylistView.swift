//
//  PlaylistView.swift
//  DTunes
//
//  Created by OllyWang on 12/19/25.
//

import SwiftUI
import Combine
import VariableBlur
import MusicKit

private extension View {
    @ViewBuilder
    func matchedGeometryEffectIf(_ condition: Bool, id: String, in namespace: Namespace.ID) -> some View {
        if condition {
            matchedGeometryEffect(id: id, in: namespace)
        } else {
            self
        }
    }
}

struct PlaylistView: View {
    // MARK: - Properties
    var playlist: PlaylistDT
    var isAnimating: Bool
    var namespace: Namespace.ID

    @Binding var show: Bool
    @Binding var hasScrolled: Bool
    @Binding var showClock: Bool

    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isCompact) var isCompact
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject var player: PlayerStore
    @EnvironmentObject var playerManager: PlayerManager
    
    // Internal State
    @State private var gridAnimation = false
    @State private var offsetY: CGFloat = 0
    @State private var appear = [false, false, false]
    @State private var scrollY: CGFloat = 0
    @State private var initialOffset: CGFloat? = nil
    @State private var viewState: CGSize = .zero
    @State private var lastOffset: CGFloat = 0
    @State private var startOffset: CGFloat? = nil
    @State private var hasTriggeredRefresh = false
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    @State private var useMatchedHeroEffects = true

    @State private var showPremiumButton = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    head(size: geo.size)
                    ZStack(alignment: .top) {
                        refreshIndicator
                        content(size: geo.size)
                            .opacity(appear[0] ? 1 : 0)
                    }
                }
                .background(Color(hex: playlist.waveColor))
                .task {
                    handleOnAppear()
                }
                .onChange(of: show) { _, newValue in
                    if !newValue { fadeOut() }
                }
                
                // Top gap filler for scroll transitions
                Color(hex: playlist.backColor)
                    .frame(height: isCompact ? 20 : 0)
                
                if player.tracksPlaylistDict[playlist.playlistID] == nil {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                }
            }
            .mask {
                detailMask
            }
            .mask(RoundedRectangle(cornerRadius: viewState.height / 2.5))
            .scaleEffect(-viewState.height / 800 + 1)
            .gesture(dragGesture)
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                if !player.appIsPro && showPremiumButton {
                    PremiumButton() {
                        playerManager.paywallShow = true
                    }
                    .padding(.bottom, 130)
                    // 使用 transition 组合位移和透明度
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 10)),
                            removal: .opacity
                        )
                    )
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    guard show else { return }

                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        useMatchedHeroEffects = false
                    }
                }

                withAnimation(.easeIn(duration: 0.25).delay(1.2)) {
                    showPremiumButton = true
                }
            }
            .alert(
                NSLocalizedString("AlertPlaylistNotFoundTitle", comment: ""),
                isPresented: $showAlert
            ) {
                Button(NSLocalizedString("AlertOK", comment: ""), role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - View Components
    @ViewBuilder
    private var detailMask: some View {
        RoundedRectangle(cornerRadius: isCompact ? 36 : 18, style: .continuous)
            .matchedGeometryEffectIf(useMatchedHeroEffects, id: "mask\(playlist.id)", in: namespace)
    }

        @ViewBuilder
        private func head(size: CGSize) -> some View {
            let baseHeight = isCompact
            ? (size.height * (isLandscape ? 0.279 : 0.258)).rounded()
            : (size.height * (isLandscape ? 0.26 : 0.19)).rounded()
            
            let extraHeight = isCompact
            ? (size.height * (isLandscape ? 0 : 0.023)).rounded()
            : -(size.height * 0.023).rounded()
            
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(hex: playlist.backColor))
                    .frame(height:baseHeight)
                    .matchedGeometryEffectIf(useMatchedHeroEffects, id: "backColor\(playlist.id)", in: namespace)
                    .overlay {
                        VStack(alignment: .leading, spacing: isLandscape ? 14 : 10) {
                            Text(playlist.subtitle)
                                .font(.body.weight(.semibold))
                                .offset(y: scrollY > 0 ? min(20, scrollY * 0.08) : 0)
                                .matchedGeometryEffectIf(useMatchedHeroEffects, id: "subtitle\(playlist.id)", in: namespace)
                            
                            Text(isCompact
                                 ? (isLandscape ? playlist.title.replacingOccurrences(of: "\n", with: " ") : playlist.title)
                                 : playlist.title
                                )
                                .font(.title.weight(.bold))
                                .offset(y: scrollY > 0 ? min(30, scrollY * 0.12) : 0)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(isCompact ? (isLandscape ? 1 : nil) : nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .matchedGeometryEffectIf(useMatchedHeroEffects, id: "title\(playlist.id)", in: namespace)
                            
                            Spacer()
                        }
                        .padding(20)
                        .padding(.top, isLandscape ? 25 : 45)
                        .foregroundStyle(.white)
                        .overlay(
                            Group {
                                if scenePhase == .active {
                                    WaveView(
                                        color: Color(hex: playlist.waveColor),
                                        isActive: .constant(true),
                                        isAnimating: .constant(true)
                                    )
                                    .scaleEffect(scrollY > 0 ? min(1.3, scrollY / 200 + 1) : 1)
                                    .blur(radius: min(6, scrollY / 120))
                                    .matchedGeometryEffectIf(useMatchedHeroEffects, id: "wave\(playlist.id)", in: namespace)
                                } else {
                                    WaveView(
                                        color: Color(hex: playlist.waveColor),
                                        isActive: .constant(true),
                                        isAnimating: .constant(false)
                                    )
                                    .scaleEffect(scrollY > 0 ? min(1.3, scrollY / 200 + 1) : 1)
                                    .blur(radius: 0)
                                }
                            }
                        )
                    }
                
                closeButton
            }
            .frame(height: baseHeight + extraHeight)
        }
    
    private func content(size: CGSize) -> some View {
        let columnCount = isLandscape ? 5 : 3
        let cellSize = size.width / CGFloat(columnCount)

        return ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(cellSize), spacing: 0), count: columnCount),
                spacing: 0
            ) {
                ForEach(Array(player.nowPlayingTracks.enumerated()), id: \.offset) { index, track in
                    GridArtwork(showClock: $showClock, track: track, size: cellSize)
                        .offset(y: gridAnimation ? 0 : 13)
                        .opacity(gridAnimation ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.9)
                            .delay(Double(index) * 0.02),
                            value: gridAnimation
                        )
                }
            }
            .overlay(
                GeometryReader { proxy in   // ✅ 这个可以保留（只用于offset测量）
                    let offset = proxy.frame(in: .named("scroll")).minY
                    Color.clear.preference(key: ScrollOffsetKey.self, value: offset)
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            handleScrollPreferenceChange(value: value, size: size) // ✅ 改这里
        }
        .mask(
            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
        )
    }
    
    private var refreshIndicator: some View {
        HStack {
            if !isCompact || !isLandscape {
                Image(systemName: "arrow.trianglehead.2.clockwise")
                    .font(.title)
                    .fontWeight(.regular)
                    .foregroundStyle(hasTriggeredRefresh ? Color.white.opacity(0.5) : Color(hex: playlist.backColor).opacity(0.5))
                    .animation(.easeInOut(duration: 0.1), value: hasTriggeredRefresh)
                    .opacity(scrollY > 50 ? max(0.2, (scrollY - 50) * 0.12) : 0)
                    .rotationEffect(.degrees(scrollY > 50 ? (scrollY - 50) * 1.5 : 0))
            }
        }
        .padding(20)
    }
    
    private var closeButton: some View {
        Button {
            restoreMatchedHeroEffects()
            withAnimation(.closeCard) { show = false }
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.1), in: Circle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(isCompact ? (isLandscape ? 40 : 30) : 40 )
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .onChanged { value in
                guard value.translation.height > 0 else { return }
                guard value.startLocation.y > 50 else { return }

                if value.startLocation.y < 200 {
                    withAnimation(.closeCard) {
                        viewState = value.translation
                    }
                }
                
                if viewState.height > 110 {
                    closeAction()
                }
            }
            .onEnded { value in
                if viewState.height > 100 {
                    closeAction()
                } else {
                    withAnimation(.closeCard) {
                        viewState = .zero
                    }
                }
            }
    }

    // MARK: - Logic Methods
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func handleOnAppear() {
        /*
        guard self.playlist.playlist != nil else {
            print("播放列表为 nil，无法获取歌曲。")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                showAlert(message: NSLocalizedString("AlertPlaylistNotFound", comment: ""))
            }
            return
        }
        */
        
        fadeIn()
        player.currentPlaylist = playlist
        
        Task {
            let amFavoriteID = UserDefaults.standard.string(forKey: "player.amFavoritePlaylist")
            
            let currentID = playlist.playlist?.id.rawValue
            
            if let tracks = player.tracksPlaylistDict[playlist.playlistID], !tracks.isEmpty, currentID != amFavoriteID {
                player.nowPlayingTracks = tracks
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        gridAnimation = true
                    }
                }
                await handleInitialPlayback()

            } else {
                await loadPlaylistTracks()
            }
        }
    }
    
    private func loadPlaylistTracks() async {
        do {
            player.nowPlayingPlaylist = playlist
            
            let tracks: [Track]
            
            if let playlistObj = playlist.playlist {
                // 在后台线程拉取详情
                let detailedPlaylist = try await playlistObj.with([.tracks])
                tracks = Array(detailedPlaylist.tracks ?? [])
                print("PlistView 加载用户歌曲")
            } else {
                tracks = try await fetchTracksFromAMPlaylistID(from: playlist.playlistID)
                print("PlistView 加载DTunes歌曲 ", playlist.playlistID)
            }
            
            // 关键：一次性同步到主线程，避免多次 MainActor.run
            await MainActor.run {
                player.tracksPlaylistDict[playlist.playlistID] = tracks
            }
            player.nowPlayingTracks = tracks
            
            try await playerManager.setQueue(tracks: tracks)

            if playlist.playlist != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation {
                        gridAnimation = true
                    }
                }
                try await Task.sleep(nanoseconds: 1200_000_000)//延迟播放这样和DTunes的播放一致
            } else {
                withAnimation {
                    gridAnimation = true
                }
            }
            await playerManager.playPause()
        } catch {
            print("Load error: \(error)")
        }
    }
     
    
    private func handleInitialPlayback() async {
        if playlist.playlistID != player.nowPlayingPlaylist?.playlistID {
            try? await playerManager.setQueue(tracks: player.nowPlayingTracks)
            await playerManager.playPause()
            player.nowPlayingPlaylist = playlist
        }
    }
    
    private func handleScrollPreferenceChange(value: CGFloat, size: CGSize) {
        
        dispatchScrollLogic(currentOffset: value)
        
        if initialOffset == nil { initialOffset = value }
        
        let diff = value - (initialOffset ?? 0)
        scrollY = diff > 0 ? diff : 0

        let threshold = isCompact
            ? (isLandscape ? size.height * 0.3 : size.height * 0.15)
            : (isLandscape ? size.height * 0.2 : size.height * 0.15)


        guard  !isCompact || !isLandscape else { return }

        // Trigger Refresh logic
        if scrollY >= threshold && !hasTriggeredRefresh {
            hasTriggeredRefresh = true
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred(intensity: 0.9)
        }
        
        if scrollY == 0 && hasTriggeredRefresh {
            hasTriggeredRefresh = false
            gridAnimation = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                if let tracks = player.tracksPlaylistDict[playlist.playlistID] {
                    gridAnimation = true
                    player.nowPlayingTracks = tracks.shuffled()
                    Task {
                        try? await playerManager.setQueue(tracks: player.nowPlayingTracks)
                        await playerManager.playPause()
                    }
                }
            }
        }
        
        if scrollY == 0 { hasTriggeredRefresh = false }
    }
    
    private func dispatchScrollLogic(currentOffset: CGFloat) {
        if startOffset == nil { startOffset = currentOffset }
        
        let totalDragDistance = currentOffset - (startOffset ?? currentOffset)
        
        withAnimation(.easeOut(duration: 0.25)) {
            if totalDragDistance < -200 {
                hasScrolled = true
            } else if totalDragDistance > 200 {
                hasScrolled = false
            }
            
            if currentOffset > -10 {
                hasScrolled = false
            }
        }
        
        let delta = currentOffset - lastOffset
        if (delta > 0 && totalDragDistance < 0) || (delta < 0 && totalDragDistance > 0) {
            startOffset = currentOffset
        }
        lastOffset = currentOffset
    }
    
    private func closeAction() {
        withAnimation { viewState = .zero }
        restoreMatchedHeroEffects()
        withAnimation(.closeCard.delay(0.1)) { show = false }
    }

    private func restoreMatchedHeroEffects() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            useMatchedHeroEffects = true
        }
    }
    
    private func fadeIn() {
        withAnimation(.easeInOut.delay(0.1)) { appear[0] = true }
        withAnimation(.easeInOut.delay(0.8)) { appear[1] = true }
        withAnimation(.easeInOut.delay(0.5)) { appear[2] = true }
    }
    
    private func fadeOut() {
        withAnimation(.easeInOut) { appear[0] = false }
        withAnimation(.easeInOut.delay(0.4)) { appear[1] = false }
        withAnimation(.easeInOut.delay(0.5)) { appear[2] = false }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    PlaylistView(
        playlist: loadPlaylists().first!,
        isAnimating: true,
        namespace: namespace,
        show: .constant(true),
        hasScrolled: .constant(false),
        showClock: .constant(false)
    )
    .environmentObject(PlayerStore(purchaseManager: PurchaseManager()))
    .environmentObject(PlayerManager())

}
