//
//  ClockArtworkWall.swift
//  DTunes
//
//  Created by OllyWang on 1/21/26.
//

import SwiftUI
import MusicKit
import Combine

struct ClockArtworkWall: View {
    var playlist: PlaylistDT
    var time: String
    @Binding var selected: ClockArtworkGridStyle
    
    var count: Int {
        selected.value
    }
    
    @Environment(\.isLandscape) private var isLandscape
    @Environment(\.isCompact) var isCompact

    @State private var girdAnimation = false
    @EnvironmentObject var player: PlayerStore

    @State private var showTime = false
    @State private var flippingIndex: Int? = nil
    @State private var timer: Timer? = nil
    
    @State var recentRandomIndices: [Int] = [] // 存储最近5次随机索引
    @State var availableIndices: [Int] = []
    
    private var hourMinuteFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private var secondsFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter
    }
    
    private func getDisplayedItems(for geometry: GeometryProxy) -> [Track] {
        let minSide = min(geometry.size.width, geometry.size.height)
        let cellSize = CGFloat(minSide / CGFloat(count))
        let maxSize = max(geometry.size.width, geometry.size.height)
        let cellCount = Int(ceil(maxSize / cellSize)) * count
        return Array(player.nowPlayingTracks.prefix(min(cellCount, player.nowPlayingTracks.count)))
    }
    
    private func getAvailableItems(for geometry: GeometryProxy) -> [Track] {
        let minSide = min(geometry.size.width, geometry.size.height)
        let cellSize = CGFloat(minSide / CGFloat(count))
        let maxSize = max(geometry.size.width, geometry.size.height)
        let cellCount = Int(ceil(maxSize / cellSize)) * count
        return Array(player.nowPlayingTracks.dropFirst(min(cellCount, player.nowPlayingTracks.count)))
    }

    var body: some View {
        GeometryReader { geometry in
            
            let count = selected.value // 2 或 3
            // 在横屏时，count 表示“行数”；竖屏时，count 表示“列数”
            let minSide = min(geometry.size.width, geometry.size.height)
            let cellSize = CGFloat(minSide / CGFloat(count))
            let display = getDisplayedItems(for: geometry)
            var fontSize: CGFloat {
                if #available(iOS 26.0, *) {
                    return minSide * (
                        isCompact
                        ? (isLandscape ? 0.8 : 0.5)
                        : (isLandscape ? 0.6 : 0.4)//ipad
                    )
                } else {
                    return minSide * (
                        isCompact
                        ? (isLandscape ? 0.55 : 0.3)
                        : (isLandscape ? 0.4 : 0.3)//ipad
                    )
                }
            }
            ZStack{
                VStack{
                    content(geometry: geometry, cellSize: cellSize, count: count, displayedItems:display)
                }
                .animation(
                    .easeInOut(duration: 0.4),
                    value: selected
                )
                .frame(width:geometry.size.width, height: geometry.size.height)
                .background(.black)
                
                VStack{
                    if #available(iOS 26.0, *) {
                        GlassEffectText(
                            text: time,
                            font: .systemFont(ofSize: fontSize, weight: .bold, width: .compressed),
                            isClear: true,
                            glassTint: .white.opacity(0.6)
                        )
                    } else {
                        Text(time)
                            .foregroundStyle(.ultraThinMaterial)
                            .multilineTextAlignment(.center)
                            .font(.system(size: fontSize, weight: .bold,design: .rounded))
                            .monospacedDigit()
                        // 阴影（等价于 layer.shadowXXX）
                            .shadow(color: .black.opacity(0.5),
                                    radius: 15,
                                    x: 0,
                                    y: 8)
                            .contentTransition(.numericText(countsDown: false))
                            .environment(\.colorScheme, .light)
                    }
                }
                .opacity(showTime ? 1 : 0)
                .onAppear {
                    showTime = false
                    withAnimation(.easeInOut(duration: 0.35).delay(0.6)) {
                        showTime = true
                    }
                }
            }
        }
        
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func content(geometry: GeometryProxy, cellSize: CGFloat, count: Int, displayedItems: [Track]) -> some View {
        Group {
            if isLandscape {
                // 横屏：行数固定为 count
                LazyHGrid(rows: gridLayout(count: count, size: cellSize), spacing: 0) {
                    gridCells(displayedItems: displayedItems, cellSize: cellSize, geometry: geometry)
                }
            } else {
                // 竖屏：列数固定为 count
                LazyVGrid(columns: gridLayout(count: count, size: cellSize), spacing: 0) {
                    gridCells(displayedItems: displayedItems, cellSize: cellSize, geometry: geometry)
                }
            }
        }
        .id(selected)
        .transition(.opacity)
        .scrollDisabled(true)
        .disabled(true)
        .onAppear {
            startTimer(for: geometry)
            withAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    girdAnimation = true
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: - Helper Views & Logic

    @ViewBuilder
    private func gridCells(displayedItems: [Track], cellSize: CGFloat, geometry: GeometryProxy) -> some View {
        ForEach(Array(displayedItems.enumerated()), id: \.offset) { index, track in
            GridArtworkClock(
                track: track,
                size: cellSize,
                isFlipping: flippingIndex == index,
                nextTrack: player.nowPlayingTracks.randomElement()
            )
            .offset(y: girdAnimation ? 0 : 13)
            .opacity(girdAnimation ? 1 : 0)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.9).delay(Double(index) * 0.04),
                value: girdAnimation
            )
        }
    }

    private func gridLayout(count: Int, size: CGFloat) -> [GridItem] {
        Array(repeating: GridItem(.fixed(size), spacing: 0), count: count)
    }

    private func startTimer(for geometry: GeometryProxy) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let currentCount = getDisplayedItems(for: geometry).count
            guard currentCount > 0 else { return }
            
            // 计算可用索引，避免重复
            let available = Array(0..<currentCount).filter { !recentRandomIndices.contains($0) }
            let randomIndex = available.randomElement() ?? Int.random(in: 0..<currentCount)
            flippingIndex = randomIndex
            
            // 记录索引并限制容量
            recentRandomIndices.append(randomIndex)
            if recentRandomIndices.count > 5 {
                recentRandomIndices.removeFirst()
            }
            
            // 重置翻转状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                flippingIndex = nil
            }
        }
    }
}

enum ClockArtworkGridStyle: CaseIterable, Identifiable {
    case two
    case three
    
    var id: Self { self }
    
    var name: String {
        switch self {
        case .two: return "2 Rows"
        case .three: return "3 Rows"
        }
    }
    
    var imageName: String {
        switch self {
        case .two: return "square.grid.2x2.fill"
        case .three: return "square.grid.3x3.fill"
        }
    }
    
    var value: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        }
    }
}

#Preview {
    ClockArtworkWall(playlist: loadPlaylists().first!, time: "12:09", selected: .constant(.three))
        .environmentObject(PlayerStore(purchaseManager: PurchaseManager()))
}

struct GridArtworkClock: View {
    var track: Track // 初始 Track
    let size: CGFloat
    
    @State private var frontTrack: Track?
    @State private var backTrack: Track?
    @State private var rotation: Double = 0
    
    var isFlipping: Bool
    var nextTrack: Track? // 外部传入的预加载轨道
    
    // 判断当前哪一面朝向用户
    private var isBackVisible: Bool {
        let normalized = abs(rotation.truncatingRemainder(dividingBy: 360))
        return normalized > 90 && normalized < 270
    }

    var body: some View {
        ZStack {
            // 背面视图
            if let bTrack = backTrack {
                artworkView(for: bTrack)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(isBackVisible ? 1 : 0) // 性能优化：不可见时隐藏
            }
            
            // 正面视图
            if let fTrack = frontTrack {
                artworkView(for: fTrack)
                    .opacity(isBackVisible ? 0 : 1)
            }
        }
        .frame(width: size, height: size)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .onAppear {
            frontTrack = track
        }
        .onChange(of: isFlipping) { _, newValue in
            if newValue, let next = nextTrack {
                prepareAndFlip(with: next)
            }
        }
    }
    
    @ViewBuilder
    private func artworkView(for track: Track) -> some View {
        if let artwork = track.artwork {
            // MusicKit 的 ArtworkImage 自带缓存机制
            // 只要在这里调用，它就会开始异步加载
            ArtworkImage(artwork, width: size, height: size)
                .background(Color.gray.opacity(0.1))
                .clipped()
        } else {
            Color.black
        }
    }

    private func prepareAndFlip(with next: Track) {
        // 1. 翻转前，先给“看不见的那一面”赋值，触发 ArtworkImage 的预加载
        if isBackVisible {
            // 当前是背面，即将翻到正面
            frontTrack = next
        } else {
            // 当前是正面，即将翻到背面
            backTrack = next
        }
        
        // 2. 稍微延迟一点点（例如 50ms）给图片引擎一点点启动时间，然后开始执行动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeInOut(duration: 0.8)) {
                rotation += 180
            }
        }
    }
}
