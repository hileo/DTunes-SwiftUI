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
    @Published private(set) var loadingTrackPlaylistIDs: Set<String> = []
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

    @MainActor
    func tracks(for playlist: PlaylistDT) async throws -> [Track] {
        let id = playlist.playlistID

        if let cachedTracks = tracksPlaylistDict[id] {
            return cachedTracks
        }

        while loadingTrackPlaylistIDs.contains(id) {
            try await Task.sleep(nanoseconds: 100_000_000)

            if let cachedTracks = tracksPlaylistDict[id] {
                return cachedTracks
            }
        }

        loadingTrackPlaylistIDs.insert(id)

        do {
            let tracks: [Track]
            if let playlistObj = playlist.playlist {
                let detailedPlaylist = try await playlistObj.with([.tracks])
                tracks = Array(detailedPlaylist.tracks ?? [])
            } else {
                tracks = try await fetchTracksFromAMPlaylistID(from: id)
            }

            tracksPlaylistDict[id] = tracks
            loadingTrackPlaylistIDs.remove(id)
            return tracks
        } catch {
            loadingTrackPlaylistIDs.remove(id)
            throw error
        }
    }

    @MainActor
    func refreshTracks(for playlist: PlaylistDT) async throws -> [Track] {
        let id = playlist.playlistID

        while loadingTrackPlaylistIDs.contains(id) {
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        loadingTrackPlaylistIDs.insert(id)

        do {
            let tracks: [Track]
            if let playlistObj = playlist.playlist {
                let detailedPlaylist = try await playlistObj.with([.tracks])
                tracks = Array(detailedPlaylist.tracks ?? [])
            } else {
                tracks = try await fetchTracksFromAMPlaylistID(from: id)
            }

            tracksPlaylistDict[id] = tracks
            loadingTrackPlaylistIDs.remove(id)
            return tracks
        } catch {
            loadingTrackPlaylistIDs.remove(id)
            throw error
        }
    }

    func isLoadingTracks(for playlistID: String) -> Bool {
        loadingTrackPlaylistIDs.contains(playlistID)
    }
}
