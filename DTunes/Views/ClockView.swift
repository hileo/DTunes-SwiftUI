//
//  ClockView.swift
//  DTunes
//
//  Created by OllyWang on 1/15/26.
//

import SwiftUI
//import UIKit
import MusicKit
import Combine

struct ClockView: View {
    @Binding var showClock: Bool
    
    var playlist: PlaylistDT
    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isCompact) var isCompact
    @Environment(\.isPad) var isPad

    @EnvironmentObject var player: PlayerStore
    @EnvironmentObject var playerManager: PlayerManager

    @State private var isPlaying: Bool = false
    @State private var isLiked: Bool = false
    @State private var isShowSheet = false
    @State private var isShowPop = false
    @State private var isShowColorThemeButton = true
    
    @State private var forwardTrigger = false // 用来触发动画的状态位
    @State private var backwardTrigger = false // 用来触发动画的状态位

    @State private var fontSize: CGFloat = 26
    @State private var fontWeight: Font.Weight = .thin
    @State private var fontColor: Color = .white
    
    @State private var dragOffset: CGFloat = 0
    @State private var showMenu = false
    @State private var landscapeToggle = false
    
    @State private var showPremiumButton = false
    
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    let buttonHeight = 44.0
    let buttonCorner = 22.0
    
    var safeAreaSpace: CGFloat {
        isLandscape ? 0 : 44
    }
    
    var safeAreaSpaceBottom: CGFloat {
        isLandscape ? 0 : 14
    }
    
    var colorPrimaryPlaylist: Color {
        if let playlist = player.currentPlaylist {
            return  Color(hex: playlist.waveColor)
        } else {
            return .red
        }
    }
    
    var colorSecondaryPlaylist: Color {
        if let playlist = player.currentPlaylist {
            return  Color(hex: playlist.backColor)
        } else {
            return .cyan
        }
    }
    
    var colorPrimaryArtwork: Color {
        playerManager.primaryColor
    }
    
    var colorSecondaryArtwork: Color {
        playerManager.secondaryColor
    }

//    var colorPrimaryArtwork: Color {
//        if let artwork = playerManager.nowPlayingTrack?.artwork,
//           let cgColor = artwork.backgroundColor {
//            return Color(cgColor)
//        } else {
//            return colorPrimaryDefault//.brown
//        }
//    }
    
//    var colorSecondaryArtwork: Color {
//        if let artwork = playerManager.nowPlayingTrack?.artwork,
//           let cgColor = artwork.primaryTextColor {
//            return Color(cgColor)
//        } else {
//            return colorSecondaryDefault//.green
//        }
//    }
    
    
    var colorPrimary: Color {
        switch playerManager.clockThemeColorStyle {
        case .playlistColor:
            return colorPrimaryPlaylist
        case .artworkColor:
            return colorPrimaryArtwork
        default:
            return .black
        }
    }
    
    var colorSecondary: Color {
        switch playerManager.clockThemeColorStyle {
        case .playlistColor:
            return colorSecondaryPlaylist
        case .artworkColor:
            return colorSecondaryArtwork
        default:
            return Color(hex: "2E2E2E")
        }
    }
    
    var colorTimeText: Color {
        switch playerManager.clockThemeColorStyle {
        case .playlistColor:
            return .white
        case .artworkColor:
            return colorPrimaryArtwork
        default:
            return .white
        }
    }
    
    // 自动更新的时间定时器
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 时间格式化器
    private var hourMinuteFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private var hourFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter
    }
    
    private var minuteFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }
    
    private var secondsFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter
    }
    
    private var amPmFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }
    
    private var weekFormatter: DateFormatter {
        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "zh_CN") // 设置为中文周几
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "zh_CN") // 设置为中文周几
        formatter.dateFormat = "EEE MMM d"
        return formatter
    }
    
    
    @State private var lastInteractionTime = Date()
    @State private var originalBrightness: CGFloat = UIScreen.main.brightness
    @State private var isDimmed = false
    
    @State private var isDismissing = false

    let idleTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let cornerRadius: CGFloat = 15

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                colorSecondary
                layoutView(for: geometry)
                    .id(playerManager.clockLayout) // 👈 用 clockLayout 作为 identity
                    .transition(.opacity)          // 👈 淡入淡出（可换其他）
                    .animation(
                        .easeInOut(duration: 0.4),
                        value: playerManager.clockLayout // 👈 监听这个值变化
                    )
                ZStack(alignment: .bottom){
                    premiumBnt
                }
                ZStack {
                    if showMenu {
                        ZStack {
                            BlurView2(style: .systemMaterialDark).opacity(0.9)
                                .onTapGesture {
                                    showMenu = false
                                }
                            headButton
                            playButton
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showMenu)
                
               
                footButton(geo: geometry)
            }
            .mask {
                RoundedRectangle(cornerRadius: isCompact ? 36 : 18, style: .continuous)
            }
            .geometryGroup()
            .offset(y: dragOffset > 0 ? dragOffset : 0)
            .onTapGesture {
                if !isShowPop{
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMenu = true
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard !isDismissing else { return }
                        if value.startLocation.y > 80 {
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height * 0.8
                            }
                        }
                    }
                    .onEnded { value in
                        guard !isDismissing else { return }
                        
                        let shouldDismiss =
                            value.translation.height > geometry.size.height * 0.25 ||
                            value.velocity.height > 500
                        
                        if shouldDismiss {
                            isDismissing = true
                            withAnimation(.easeOut(duration: 0.2)) {
                                dragOffset = geometry.size.height
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                dismiss()
                            }
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
            .onReceive(timer) { input in
                withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                    currentTime = input
                }
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .task {
                playerManager.updateThemeColor(from: playerManager.nowPlayingTrack)
            }
            .onChange(of: playerManager.nowPlayingTrack) { _, newValue in
                withAnimation() {
                    playerManager.updateThemeColor(from: newValue)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func head(geo: GeometryProxy) -> some View {
        let minSide = min(geo.size.width, geo.size.height)
        let fontSize = minSide * (isCompact ? 0.08 : 0.045)
        
        HStack(alignment: .top){
            Group{
                if(playerManager.clockFont == .colorFont1 || playerManager.clockFont == .colorFont2){
                    Text(amPmFormatter.string(from: currentTime))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Text(secondsFormatter.string(from: currentTime))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .contentTransition(.numericText(countsDown: false))
                        .onAppear {
                            showPremiumButton = false
                        }
                }else if(playerManager.clockFont == .colorFont3){
                    Text(weekFormatter.string(from: currentTime))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            withAnimation(.easeIn(duration: 0.25).delay(1.2)) {
                                showPremiumButton = true
                            }
                        }
                }else if(playerManager.clockFont == .colorFont4){
                    Text(dateFormatter.string(from: currentTime))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            withAnimation(.easeIn(duration: 0.25).delay(1.2)) {
                                showPremiumButton = true
                            }
                        }
                }
            }
            .font(playerManager.clockFont.fontDate(size: fontSize))
            .monospacedDigit()
//            .font(.system(size: fontSize, weight: fontWeight))
            .foregroundStyle(colorTimeText)
        }
        .padding(.top, isLandscape ? 25 + safeAreaSpace : 20 + safeAreaSpace)
        .padding(.horizontal,50)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    @ViewBuilder
    var premiumBnt:some View{
        if !player.appIsPro && showPremiumButton {
            PremiumButtonBig() {
                playerManager.paywallShow = true
            }
            // 使用 transition 组合位移和透明度
            .transition(
                .asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 10)),
                    removal: .opacity
                )
            )
        }
    }
    
    var headButton:some View{
        HStack {
            Spacer()
            
            if !isPad{
                Button(){
                    landscapeToggle = isLandscape
                    landscapeToggle.toggle()
                    if landscapeToggle {
                        // 强制横屏
                        RotationControl.setOrientation(to: .landscape)
                    } else {
                        // 恢复竖屏
                        RotationControl.setOrientation(to: .portrait)
                    }
                } label: {
                    Image(isLandscape ? "ClockPortrait" : "ClockLandscape")
                        .resizable()
                        .frame(width: buttonHeight, height: buttonHeight)
                }
                .applyGlassEffectInClockView(shape: Circle())
            }
            
            Button(){
                dismiss()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 22))
                    .fontWeight(.regular)
                    .frame(width: buttonHeight, height: buttonHeight)
                    .foregroundStyle(Color.white)
            }
            .applyGlassEffectInClockView(shape: Circle())
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 25)
        .padding(.top, isLandscape ? 20 + safeAreaSpace : 10 + safeAreaSpace)
    }
    
    var playButton:some View{
        VStack{
            VStack{
                VStack{
                    Group{
                        Text(playerManager.nowPlayingTrack?.title ?? NSLocalizedString("Play_NowPlaying", comment: "Now Playing fallback"))
                        Text(playerManager.nowPlayingTrack?.artistName ?? "")
                            .font(.footnote)
                    }
                    .lineLimit(1)
                    .truncationMode(.middle)
                    
                    Group {
                        if let artwork = playerManager.nowPlayingTrack?.artwork {
                            ArtworkImage(artwork, width: 100, height: 100)
                                .frame(width: 100, height: 100)
                                .cornerRadius(playerManager.isPlaying ? 10 : 8)
                                .scaleEffect(playerManager.isPlaying ? 1.0 : 0.9)
                        } else {
                            Color.gray.opacity(0.2)
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                        }
                    }
                }
                .id(playerManager.nowPlayingTrack?.id ?? "placeholder")
            }
            .padding(.bottom, 20)
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.35), value: playerManager.nowPlayingTrack?.id)
            
            HStack(spacing:isLandscape ? 60 : 45){
                Button {
                    playerManager.isLiked = false
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        backwardTrigger.toggle()
                    }
                    Task {
                        await playerManager.previous()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            playerManager.isFavoriteSong()
                        }
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                        .id(backwardTrigger)
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                        .frame(width: 55, height: 55)

                }
                
                Button {
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
                    .font(.system(size: 42))
                    .foregroundStyle(.white)
                    .transition(.scale(scale: 0.0).combined(with: .opacity))
                    .frame(width: 55, height: 55)

                }
                
                Button {
                    playerManager.isLiked = false
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        forwardTrigger.toggle()
                    }
                    Task {
                        await playerManager.next()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            playerManager.isFavoriteSong()
                        }
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                        .id(forwardTrigger)
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                        .frame(width: 55, height: 55)

                }
            }
        }
        .offset(y:isLandscape ? -50 : 0)
    }
    
    
    private func footButton(geo: GeometryProxy) -> some View{
        VStack(spacing: 0){
            Spacer()
            HStack {
                HStack {
                    if playerManager.clockLayout == .layoutArtWall{
                        artworkLayoutButton
//                            .transition(.opacity.combined(with: .scale))
                    }else if(playerManager.clockLayout == .layoutCapsuleRotation || playerManager.clockLayout == .layoutCapsuleHorizontal){
                        /*
                        Button {//下载壁纸
                            switch playerManager.clockLayout {
                            case .layoutCapsuleRotation:
                                saveCurrentScreenView(view: ClockCapsuleRotation(exportMode: true).environmentObject(playerManager)
                                    .environment(\.isLandscape, isLandscape), geometry: geo)

                            case .layoutCapsuleHorizontal:
                                saveCurrentScreenView(view: ClockCapsuleHorizontal(exportMode: true).environmentObject(playerManager)
                                    .environment(\.isLandscape, isLandscape), geometry: geo)

                            default:
                                break
                            }
                        }  label: {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 22))
                                .fontWeight(.regular)
                                .frame(width: buttonHeight, height: buttonHeight)
                                .foregroundStyle(Color.white)
                        }
                        .applyGlassEffectInClockView(shape: Circle())
                        */
                    }else{
                        colorThemeButton
//                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: isShowColorThemeButton)
                
                Spacer()
                
                Button(){
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
                .frame(width: buttonHeight, height: buttonHeight)
                .applyGlassEffectInClockView(shape: Circle())
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMenu = false
                    }
                    isShowSheet.toggle()
                }  label: {
                    Image(systemName: "circle.grid.cross.down.filled")
                        .font(.system(size: 22))
                        .fontWeight(.regular)
                        .frame(width: buttonHeight, height: buttonHeight)
                        .foregroundStyle(Color.white)
                }
                .applyGlassEffectInClockView(shape: Circle())
                .sheet(isPresented: $isShowSheet, onDismiss: didDismiss) {
                    ZStack {
                        ViewThatFits(in: .horizontal) {
                            // 横屏：一排 4 个
                            HStack(spacing: 30) {
                                ClockLayout(selectedLayout: $playerManager.clockLayout, isShow: $isShowSheet)
                            }
                            // 竖屏：2 × 2
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 2),
                                    GridItem(.flexible(), spacing: 2),
                                    GridItem(.flexible(), spacing: 2)
                                ],
                                spacing: 30
                            ) {
                                ClockLayout(selectedLayout: $playerManager.clockLayout, isShow: $isShowSheet)
                            }
                        }
                        .padding(.top, isPad ? (isLandscape ? 0 : 20) : (isLandscape ? 0 : 80))

                        Button {
                            isShowSheet.toggle()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.white)
                                .font(.body)
                                .frame(width: 44, height: 44)
                        }
                        .applyGlassEffect(shape: Circle())
                        .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .topTrailing)
                        .padding(20)
                    }
                    .presentationDetents([.height(isPad ? 420 : 390)])
                }
                
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 30 + safeAreaSpaceBottom)
        }
    }
    
    @ViewBuilder
    var popview: some View {
        switch playerManager.clockLayout {

        case .layoutTime:
            VStack(alignment: .leading, spacing: 15) {
                ScrollView {
                    ClockFontPicker(selectedFont: $playerManager.clockFont)
                        .frame(height: 50)

                    ClockThemeColor(
                        selectedColor: $playerManager.clockThemeColorStyle,
                        colorPrimaryPlaylist: colorPrimaryPlaylist,
                        colorSecondaryPlaylist: colorSecondaryPlaylist,
                        colorPrimaryArtwork: colorPrimaryArtwork,
                        colorSecondaryArtwork: colorSecondaryArtwork
                    )
                    .frame(height: 50)
                    .padding(.leading, 15)
                }
            }
            .padding(20)
            .frame(width: 360)
            .presentationCompactAdaptation(.popover)

        case .layoutNone, .layoutCover:
            VStack(alignment: .leading, spacing: 15) {
                ScrollView {
                    ClockThemeColor(
                        selectedColor: $playerManager.clockThemeColorStyle,
                        colorPrimaryPlaylist: colorPrimaryPlaylist,
                        colorSecondaryPlaylist: colorSecondaryPlaylist,
                        colorPrimaryArtwork: colorPrimaryArtwork,
                        colorSecondaryArtwork: colorSecondaryArtwork
                    )
                    .frame(height: 50)
                    .padding(.leading, 15)
                }
            }
            .padding(20)
            .frame(width: 260)
            .presentationCompactAdaptation(.popover)

        case .layoutArtWall:
            VStack{}
        case .layoutCapsuleHorizontal:
            VStack{}
        case .layoutCapsuleRotation:
            VStack{}
        }
    }
    
    var colorThemeButton: some View{
        ClockThemeColorButton(
            isSelected: .constant(true),
            topColor: colorPrimary,
            bottomColor: colorSecondary,
            defaultStrokeColor: .black.opacity(0.7),
            selectedStrokeColor: .white,
            size: 30
        ) {
            isShowPop = true
            showMenu = false
        }
        .popover(isPresented: $isShowPop) {
           popview
        }
    }

    // MARK: - Artwall layout options

    

    var artworkLayoutButton: some View{
        VStack{
            if #available(iOS 26.0, *) {
                Menu {
                    Picker("排序方式", selection: $playerManager.clockArtworkGrid) {
                        ForEach(ClockArtworkGridStyle.allCases) { option in
                            Label(option.name, systemImage: option.imageName)
                                .tag(option)
                        }
                    }
                } label: {
                    Image(systemName: playerManager.clockArtworkGrid.imageName)
                        .font(.system(size: 22))
                        .fontWeight(.regular)
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.white)
                        .applyGlassEffectInClockView(shape: Circle())
                }
                .onChange(of: playerManager.clockArtworkGrid) { _, _ in
                    feedbackGenerator.prepare()
                    feedbackGenerator.impactOccurred(intensity: 0.9)
                    showMenu = false
                }
            }else{
                Button{
                    showMenu = false
                }label: {
                    Menu {
                        Picker("排序方式", selection: $playerManager.clockArtworkGrid) {
                            ForEach(ClockArtworkGridStyle.allCases) { option in
                                Label(option.name, systemImage: option.imageName)
                                    .tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: playerManager.clockArtworkGrid.imageName)
                            .font(.system(size: 22))
                            .fontWeight(.regular)
                            .frame(width: 48, height: 48)
                            .foregroundStyle(Color.white)
                            .applyGlassEffectInClockView(shape: Circle())
                    }
                    .onChange(of: playerManager.clockArtworkGrid) { oldValue, newValue in
                        feedbackGenerator.prepare()
                        feedbackGenerator.impactOccurred(intensity: 0.9)
                        showMenu = false
                    }
                }
            }
        }
    }
    
    func didDismiss() {
        // Handle the dismissing action.
    }
    
    private func dismiss() {
        withAnimation(.closeClock){
            showClock = false
        }
    }
    
    private func contentTime(geometry: GeometryProxy, fontSize: CGFloat) -> some View {
        Group {
            if isLandscape {
                // 横屏左右排布
                HStack(spacing: 50) {
                    Text(hourFormatter.string(from: currentTime))
                        .contentTransition(.numericText(countsDown: false))

                    Text(minuteFormatter.string(from: currentTime))
                        .contentTransition(.numericText(countsDown: false))

                }
            } else {
                // 竖屏上下排布
                VStack(spacing: -geometry.size.height * 0.06) {
                    Text(hourFormatter.string(from: currentTime))
                        .contentTransition(.numericText(countsDown: false))

                    Text(minuteFormatter.string(from: currentTime))
                        .contentTransition(.numericText(countsDown: false))

                }
            }
        }
        .monospacedDigit()
        .font(playerManager.clockFont.font(fontSize: fontSize))
        .monospacedDigitIf(playerManager.clockFont.usesMonospacedDigit)
        .foregroundStyle(colorTimeText)
        // ⭐️ 关键
        .id(playerManager.clockFont)
        .transition(
            .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                removal: .opacity.combined(with: .scale(scale: 1.05))
            )
        )
//        .animation(.spring(), value: playerManager.clockFont)
    }
    
    @ViewBuilder
    private func layoutView(for geometry: GeometryProxy) -> some View {
        let minSide = min(geometry.size.width, geometry.size.height)
        let artworkSize = minSide * (isCompact ? 0.82 : 0.55)
        
        switch playerManager.clockLayout {
        case .layoutTime:
//            let fontSizeTime = isLandscape ? geometry.size.width * 0.25 : geometry.size.width * 0.53
            
            let fontSizeTime = isCompact
                ? (isLandscape ? geometry.size.width * 0.25 : geometry.size.width * 0.53)
                : (isLandscape ? geometry.size.width * 0.32 : geometry.size.width * 0.38)
            
            head(geo: geometry)
            ZStack {
                contentTime(geometry: geometry, fontSize: fontSizeTime)
                WaveView(
                    color: colorPrimary,
                    isActive: .constant(true),
                    isAnimating: .constant(true)
                )
                .offset(y: isLandscape ? 0 : 30)
            }
            .onAppear {
                isShowColorThemeButton = true
                if playerManager.clockFont == .colorFont3 || playerManager.clockFont == .colorFont4 {
                    withAnimation(.easeIn(duration: 0.25).delay(1.2)) {
                        showPremiumButton = true
                    }
                }else{
                    showPremiumButton = false
                }
            }
        case .layoutNone:
            ZStack {
                WaveView(
                    color: colorPrimary,
                    isActive: .constant(true),
                    isAnimating: .constant(true)
                )
                .offset(y: isLandscape ? 0 : 30)
            }
            .onAppear {
                isShowColorThemeButton = true
                showPremiumButton = false
            }
        case .layoutCover:
            ZStack {
                VStack{
                    if let artwork = playerManager.nowPlayingTrack?.artwork {
                        ArtworkImage(artwork, width: artworkSize, height: artworkSize)
                            .id(playerManager.nowPlayingTrack?.id ?? "placeholder")
                    } else {
                        Image("")
                            .resizable()
                            .frame(width: artworkSize, height: artworkSize)
                            .background(.white.opacity(0.2))
                    }
                }
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.35), value: playerManager.nowPlayingTrack?.id)
                
                WaveView(
                    color: colorPrimary,
                    isActive: .constant(true),
                    isAnimating: .constant(true)
                )
                .offset(y: isLandscape ? 0 : 30)
            }
            .onAppear {
                isShowColorThemeButton = true
                withAnimation(.easeIn(duration: 0.25).delay(1.2)) {
                    showPremiumButton = true
                }
            }
            
        case .layoutArtWall:
            ClockArtworkWall(playlist: loadPlaylists().first!, time: hourMinuteFormatter.string(from: currentTime), selected: $playerManager.clockArtworkGrid)
                .onAppear {
                    isShowColorThemeButton = false
                    withAnimation(.easeIn(duration: 0.25).delay(1.2)) {
                        showPremiumButton = true
                    }
                }
            
        case .layoutCapsuleHorizontal:
            ClockCapsuleHorizontal()
                .onAppear {
                    withAnimation(.easeIn(duration: 0.25).delay(1.2)) {
                        showPremiumButton = true
                    }
                }
            
        case .layoutCapsuleRotation:
            ClockCapsuleRotation()
                .onAppear {
                    withAnimation(.easeIn(duration: 0.25).delay(1.2)) {
                        showPremiumButton = true
                    }
                }
        }
    }
}

#Preview {
    ClockView(showClock: .constant(false), playlist: loadPlaylists().first!)
        .observeOrientation()
        .preferredColorScheme(.dark)
        .environmentObject(PlayerManager())
        .environmentObject(PlayerStore(purchaseManager: PurchaseManager()))
}
