//
//  AppleMusic.swift
//  DTunes
//
//  Created by OllyWang on 1/25/26.
//

import SwiftUI
import MusicKit
import Combine


@MainActor
final class MusicAuthViewModel: ObservableObject {
    
    enum AlertType: Identifiable {
        case needPermission
        case needSubscription
        
        var id: Int { hashValue }
    }
    
    @Published var alertType: AlertType?
    @Published var isAuthorized: Bool = false

//    private var hasChecked = false
    
    func checkAuthorization(playerManager: PlayerManager) async {
        
//        guard !hasChecked else { return }
//        hasChecked = true
        
        //授权
        let status = MusicAuthorization.currentStatus
        
        if status != .authorized {
            let newStatus = await MusicAuthorization.request()
            
            guard newStatus == .authorized else {
                alertType = .needPermission
                return
            }
        }
        
        isAuthorized = true

        //订阅
        do {
            let subscription = try await MusicSubscription.current
            
            guard subscription.canPlayCatalogContent else {
                alertType = .needSubscription
                return
            }
            
        } catch {
            alertType = .needSubscription
            return
        }
        
        //成功
        playerManager.getAMToken()
    }
}

enum MyError: Error {
    case unauthorized
    case unknown
    // 你可以根据需要添加更多错误类型
}

func requestMusicAuthorization() async throws {
    let status = await MusicAuthorization.request()
    guard status == .authorized else {
        throw NSError(domain: "MusicAuth", code: -1)
    }
}

func requestMusicAuthorization(playerManager: PlayerManager) async throws {
    let status = MusicAuthorization.currentStatus
    
    if status != .authorized {
        let newStatus = await MusicAuthorization.request()
        guard newStatus == .authorized else {
            throw MyError.unauthorized
        }
    }

    playerManager.getAMToken()
}

func fetchTracksFromAMPlaylistID(from playlistID: String) async throws -> [Track] {
    
    let playlistID = MusicItemID(rawValue: playlistID)

    var request = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: playlistID)
    request.limit = 1
    request.properties = [.tracks]
    
    let response = try await request.response()
    guard let playlist = response.items.first,
          let tracks = playlist.tracks else {
        return []
    }
    
    var allTracks = [Track]()
    var currentBatch: MusicItemCollection<Track>? = tracks
    
    while let batch = currentBatch {
        allTracks.append(contentsOf: batch)
        if batch.hasNextBatch {
            currentBatch = try await batch.nextBatch()
        } else {
            break
        }
    }
    
    return allTracks.shuffled()
}


func fetchUserPlaylists(selectedSort: SortType) async throws -> [PlaylistDT] {
    
    var request = MusicLibraryRequest<Playlist>()
    request.limit = 100
    
    // 如果你需要 tracks，一定要开
    // request.properties = [.tracks]
    
    // ✅ 先尝试用系统排序
    switch selectedSort {
    case .name:
        request.sort(by: \.name, ascending: true)
        
    case .dateAdded:
        request.sort(by: \.libraryAddedDate, ascending: false)
        
    case .lastModifiedDate:
        break
        
    case .playlistType:
        break
    }
    
    let response = try await request.response()
    
    // ✅ 再做本地兜底排序
    let sortedItems: [Playlist]
    
    switch selectedSort {
    case .lastModifiedDate:
        sortedItems = response.items.sorted {
            ($0.lastModifiedDate ?? .distantPast) >
            ($1.lastModifiedDate ?? .distantPast)
        }
        
    default:
        sortedItems = Array(response.items)
    }
    

    // ✅ map 成你的模型
    return sortedItems.map { playlist in
        
        // 获得用户AM的喜爱歌曲列表
        if UserDefaults.standard.string(forKey: "player.amFavoritePlaylist") == nil {
            UserDefaults.standard.set(playlist.id.rawValue,forKey: "player.amFavoritePlaylist")
        } 
        return PlaylistDT(
            title: playlist.name,
            subtitle: playlist.curatorName ?? "Apple Music",
            playlistID: playlist.id.rawValue,
            playlistTag: "0",
            backColor: "53FFC2",
            waveColor: "53FFC2",
            playlist: playlist
        )
       

    }
}


struct AppleMusic: View {
    let playlistID: String
    
    @State private var tracks: [Track] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var completedIDs: Set<MusicItemID> = [] // 记录 ID

    var body: some View {
        ZStack{
            List(tracks, id: \.id) { track in
                HStack(spacing: 12) {
                    // 封面
                    if let artwork = track.artwork {
                        ArtworkImage(artwork, width: 60, height: 60)
                            .cornerRadius(6)
                            .opacity(completedIDs.contains(track.id) ? 1 : 0)
                            .onAppear {
                                if !completedIDs.contains(track.id) {
                                    withAnimation(.easeIn(duration: 0.5)) {
                                        _ = completedIDs.insert(track.id)
                                    }
                                }
                            }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .cornerRadius(6)
                    }

                    // 文本
                    VStack(alignment: .leading) {
                        Text(track.title)
                            .font(.title3)
                            .onAppear{
                                print("track.id ==\(track.id)")
                            }
                        Text(track.artistName)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 0){
                        // 背景色
                        Group{
                            if let color = track.artwork?.backgroundColor {
                                Rectangle()
                                    .fill(Color(UIColor(cgColor: color)))
                                
                            }
                            
                            // 主文字色
                            if let color = track.artwork?.primaryTextColor {
                                Rectangle()
                                    .fill(Color(UIColor(cgColor: color)))
                                
                            }
                            
                            // 次文字色
                            if let color = track.artwork?.secondaryTextColor {
                                Rectangle()
                                    .fill(Color(UIColor(cgColor: color)))
                                
                            }
                        }
                        .frame(width: 20, height: 30)
                        .cornerRadius(2)
                    }
                    .padding(0)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Loading…")
                }
            }
            .task {
//                await loadSongs()
            }
            .navigationTitle("Playlist Songs")

            Button("Shuffle") {
                tracks = tracks.shuffled()
            }
        }
    }

//    private func loadSongs() async {
//        isLoading = true
//        do {
//            tracks = try await fetchTracksFromAMPlaylistID(from: playlistID, playerManager: playerManager)
//        } catch {
//            errorMessage = error.localizedDescription
//            print("Error:", error)
//        }
//        isLoading = false
//    }
}

#Preview {
    AppleMusic(playlistID: "ee")
}
