//
//  PlayerManager.swift
//  DTunes
//
//  Created by OllyWang on 1/17/26.
//

import SwiftUI
import MusicKit
import Combine
import MediaPlayer
import Observation
import SwiftyJSON
import WidgetKit

@MainActor
final class PlayerManager: ObservableObject {
    @Published var AMToken: String = ""
    @Published var AMUserToken: String = ""
    @Published var isPlaying: Bool = false
    @Published var isLiked: Bool = false
    @Published var animateLiked = false
    @Published var paywallShow = false

    @Published var artist = ""
    @Published var song = ""
    @Published var layout = ""
    @Published var colorSecondary:Color = .clear
    @Published var colorPrimary:Color = .clear
    @Published var clockThemeColorStyle : ClockThemeColorStyle = .artworkColor
    @Published var clockLayout : ClockLayoutStyle = .layoutTime
    @Published var clockFont : ClockFontStyle = .colorFont1
    @Published var clockArtworkGrid : ClockArtworkGridStyle = .two
    @Published var selectedSort : SortType = .playlistType

    let player = ApplicationMusicPlayer.shared

    @Published var tracks: [Track] = []

    @Published var nowPlayingTrack: Song?
    
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var primaryColor: Color = colorPrimaryDefault
    @Published var secondaryColor: Color = colorSecondaryDefault

    private let suiteName = "group.com.gogoapp.dtunes.widgets"
    
    init() {
        observePlaybackState()
        observeNotifications()
    }
    
    func getAMToken() {
        Task {
            do {
                // 获取开发人员 Token
                let token = try await DefaultMusicTokenProvider().developerToken(options: .ignoreCache)
                // 获取用户 Token
                let userToken = try await MusicUserTokenProvider().userToken(for: token, options: .ignoreCache)
                
                // 在主线程更新 UI 相关的属性
                await MainActor.run {
                    self.AMToken = token
                    self.AMUserToken = userToken
                    print("Tokens 更新成功")
                }
            } catch {
                print("获取 Token 失败: \(error)")
            }
        }
    }
    
    func observePlaybackState() {
        player.state.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                // 稍作延迟以获取更新后的状态，或者直接读取 currentEntry
                self.isPlaying = (self.player.state.playbackStatus == .playing)
                
                // 状态改变时自动更新锁屏信息
                self.updateNowPlayingInfo()
            }
            .store(in: &cancellables)
        
        // 2. 核心修复：监听当前播放条目 (currentEntry) 的变化
//          player.queue.objectWillChange
//              .receive(on: RunLoop.main)
//              .sink { [weak self] _ in
//                  guard let self = self else { return }
//                  // 在 objectWillChange 触发后，稍等一瞬获取新值，或直接在 sink 中赋值
//                  self.updateNowPlayingInfo()
//                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                      self.isFavoriteSong()
//                  }
//              }
//              .store(in: &cancellables)
        
        player.queue.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateNowPlayingInfo()
            }
            .store(in: &cancellables)

        $nowPlayingTrack
            .map { $0?.id.rawValue }
            .sink { [weak self] _ in
                self?.isFavoriteSong()
            }
            .store(in: &cancellables)
    }
    
    func updateThemeColor(from track: Song?) {
        if let artwork = track?.artwork,
           let cgColor = artwork.backgroundColor {
            primaryColor = Color(cgColor)
        } else {
//            primaryColor = colorPrimaryDefault
        }
        
        if let artwork = track?.artwork,
           let cgColor = artwork.primaryTextColor {
            secondaryColor = Color(cgColor)
        } else {
//            secondaryColor = colorSecondaryDefault
        }
    }
    
    func updateNowPlayingInfo() {
        if let item = player.queue.currentEntry?.item {
            switch item {
            case .song(let song):
                nowPlayingTrack = song
            default:
                break
            }
        }
        updateWidget()
    }
    
    func updateWidget() {
        @AppStorage("player.appIsPro") var appIsPro: Bool = false

        guard let song = nowPlayingTrack else { return }
        
        let defaults = UserDefaults(suiteName: suiteName)
        
        defaults?.set(song.title, forKey: "widgetAppSongName")
        defaults?.set(song.artistName, forKey: "widgetAppArtistName")
        defaults?.set(self.isPlaying, forKey: "widgetAppIsPlaying")
        defaults?.set(appIsPro, forKey: "widgetAppIsPro")
        defaults?.set(self.isLiked, forKey: "widgetAppIsFavorite")
        
        if let url = song.artwork?.url(width: 300, height: 300),
           let data = try? Data(contentsOf: url) {
            print("图像 ",data)
            defaults?.set(data, forKey: "widgetAppSongImage")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func updateWidgetIsLiked() {

        let defaults = UserDefaults(suiteName: suiteName)
        defaults?.set(self.isLiked, forKey: "widgetAppIsFavorite")
        WidgetCenter.shared.reloadAllTimelines()

    }

    func setQueue(tracks: [Track]) async throws {
        self.tracks = tracks
        player.queue = ApplicationMusicPlayer.Queue(for: tracks)
        try await player.prepareToPlay()
        self.updateNowPlayingInfo()
    }
    
    func playAtIndex(index: Int) async throws {
        player.queue = ApplicationMusicPlayer.Queue(for: tracks, startingAt: tracks[index])
        try? await player.play()
        self.updateNowPlayingInfo()
    }
    
    func playAtTrack(track: Track) async throws {
        player.queue = ApplicationMusicPlayer.Queue(for: tracks, startingAt: track)
        try? await player.play()
        self.updateNowPlayingInfo()
    }
    
    func playPause() async {
        if player.state.playbackStatus == .playing {
            player.pause()
            isPlaying = false
        } else {
            try? await player.play()
            isPlaying = true
        }
        updateNowPlayingInfo()
    }

    func next() async {
        try? await player.skipToNextEntry()
        updateNowPlayingInfo()
    }

    func previous() async {
        try? await player.skipToPreviousEntry()
        updateNowPlayingInfo()
    }
    
    // MARK: - 获取当前歌曲的收藏状态
    
    // 更新 Widget 状态
    private func updateWidget(isLiked: Bool) {
        self.isLiked = isLiked
    }

    // MARK: - 取消收藏 (DELETE)
    func removeFavoriteSong(){
        guard let url = URL(string: "https://api.music.apple.com/v1/me/ratings/songs/\(nowPlayingTrack?.id.rawValue ?? "0")") else { return }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(AMToken)",
            forHTTPHeaderField: "Authorization")
        request.addValue("\(AMUserToken)",
            forHTTPHeaderField: "Music-User-Token")
        
        print("取消收藏")
       
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("remove favorite error:", error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 204 {
                // 成功移除收藏
                Task { @MainActor in
                    self.updateWidget(isLiked: false)
                }
            } else {
                print("remove favorite failed, status:", httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    func addFavoriteSong() {
        guard let songID = nowPlayingTrack?.id.rawValue else { return }

        var components = URLComponents(string: "https://api.music.apple.com/v1/me/favorites")!
        components.queryItems = [
            URLQueryItem(name: "ids[songs]", value: songID)
        ]

        guard let url = components.url else { return }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.addValue("Bearer \(AMToken)", forHTTPHeaderField: "Authorization")
        request.addValue(AMUserToken, forHTTPHeaderField: "Music-User-Token")

        print("收藏到喜爱歌曲")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("收藏失败:", error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }

            if (200..<300).contains(httpResponse.statusCode) {
                Task { @MainActor in
                    self.updateWidget(isLiked: true)
                    print("执行收藏")
                }
            } else {
                let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                print("收藏失败 statusCode:", httpResponse.statusCode, message)
            }
        }

        task.resume()
    }

    func addFavoriteSong2(){
        guard let url = URL(string: "https://api.music.apple.com/v1/me/ratings/songs/\(nowPlayingTrack?.id.rawValue ?? "0")") else { return }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(AMToken)",
            forHTTPHeaderField: "Authorization")
        request.addValue("\(AMUserToken)",
            forHTTPHeaderField: "Music-User-Token")
        let json: [String: Any] = ["type": "rating",
                                   "attributes": ["value":"1"]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        print("收藏")
        
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let resultData = data else {
                return
            }
            do {
                try JSONSerialization.jsonObject(with: resultData, options: .mutableLeaves)
                Task { @MainActor in
                    self.updateWidget(isLiked: true)
                }
            } catch {
                print(String(describing: error))
            }
        }
        task.resume()
    }
    
    func isFavoriteSong() {
        guard let songID = nowPlayingTrack?.id.rawValue else {
            self.isLiked = false
            updateWidgetIsLiked()
            return
        }

        guard let url = URL(string: "https://api.music.apple.com/v1/me/ratings/songs/\(songID)") else { return }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.addValue("Bearer \(AMToken)", forHTTPHeaderField: "Authorization")
        request.addValue(AMUserToken, forHTTPHeaderField: "Music-User-Token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            let liked: Bool

            if let data = data,
               let json = try? JSON(data: data),
               json["data"].count > 0 {
                liked = json["data"][0]["attributes"]["value"].intValue == 1
            } else {
                liked = false
            }

            DispatchQueue.main.async {
                // 防止旧歌曲的请求回来覆盖新歌曲状态
                guard self.nowPlayingTrack?.id.rawValue == songID else { return }

                self.isLiked = liked
                self.updateWidgetIsLiked()
            }
        }.resume()
    }

    
    private func observeNotifications() {
        NotificationCenter.default.publisher(for: Notification.Name("FavoriteTrackNotification"))
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                
                isLiked = !isLiked
                if isLiked {
                    self.addFavoriteSong()
                } else {
                    self.removeFavoriteSong()
                }
                updateWidget()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: Notification.Name("GoPremiumNotification"))
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.paywallShow = true
                }
            }
            .store(in: &cancellables)
    }
}
