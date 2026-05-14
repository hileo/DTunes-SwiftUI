//
//  PlayerStore.swift
//  DTunes
//
//  Created by OllyWang on 1/5/26.
//

import SwiftUI
import Combine
import MusicKit

final class PlayerStore: ObservableObject {

    @Published var isLoading = false

    // 自动播放偏好（仅用于下次启动）
    @AppStorage("player.autoplay") var autoplay: Bool = true
    @AppStorage("player.sorttype") var sortType: SortType = .playlistType
    @AppStorage("player.appicon") var selectedIcon: String = "ICON1"
    @AppStorage("player.appID") var appID: String = "6742987464"
    @AppStorage("player.appIsPro") var appIsPro: Bool = false
    @AppStorage("player.shownGuide") var shownGuide: Bool = true
    
    @Published private(set) var playlists: [PlaylistDT] = []
    @Published private(set) var allowPlaylistsIndex = [0, 1]

    //当前波浪动画列表
    @Published var currentPlaylist: PlaylistDT?
    //当前正在播放的歌曲
    @Published var nowPlayingTracks: [Track] = []

    //当前正在播放的列表
    @Published var nowPlayingPlaylist: PlaylistDT?

    @Published var tracksPlaylistDict: [String: [Track]] = [:]
    
    @Published var userPlaylists: [PlaylistDT] = []

    @Published var sleeptimerManager = SleepTimerManager()
    private var cancellables = Set<AnyCancellable>()
    
    private let purchaseManager: PurchaseManager
    
    init(purchaseManager: PurchaseManager) {
        self.purchaseManager = purchaseManager
        playlists = loadPlaylists()
        
        if autoplay {
            if appIsPro {
                currentPlaylist = TimePeriod.current().playlist(from: playlists)
            } else {
                currentPlaylist = playlists.first
            }
        } else {
            currentPlaylist = nil
        }
        // 当 timerManager 发出变更信号时，让 PlayerStore 也发出变更信号
        sleeptimerManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
