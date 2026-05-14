//
//  SortMenuView.swift
//  DTunes
//
//  Created by OllyWang on 3/20/26.
//

import SwiftUI

enum SortType: String, CaseIterable {
    case name
    case dateAdded
    case lastModifiedDate
    case playlistType
    
    // 返回本地化的显示名称
    var localizedName: String {
        switch self {
        case .name:
            return NSLocalizedString("UserPlaylistSortByTitle", comment: "Sort by name")
        case .dateAdded:
            return NSLocalizedString("UserPlaylistSortByDateAdded", comment: "Sort by date added")
        case .lastModifiedDate:
            return NSLocalizedString("UserPlaylistSortByLastModified", comment: "Sort by last modified date")
        case .playlistType:
            return NSLocalizedString("UserPlaylistSortByPlaylistType", comment: "Sort by playlist type")
        }
    }
}

struct SortMenuView: View {
    @EnvironmentObject var player: PlayerStore
    @Environment(\.openURL) var openURL

    var body: some View {
        Menu {
            Section {
                Button(action: {
                    if let url = URL(string: "music://") {
                        openURL(url)
                    }
                }) {
                    Label("Apple Music", image: "UIMenuAppleMusicApp")
                }
            }
            Section {
                Picker("排序选项", selection: $player.sortType) {
                    ForEach(SortType.allCases, id: \.self) { option in
                        Text(option.localizedName).tag(option)
                    }
                }
                .onChange(of: player.sortType) { _, newValue in
                    handleSortChange(newValue)
                }
            }
        } label: {
            Image("AppleMusicApp")
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .applyGlassEffect(shape: Circle())
        }
    }
    
    private func handleSortChange(_ type: SortType) {
        print("选中了：\(type)")
        player.sortType = type
        Task {
            do {
                let playlists = try await fetchUserPlaylists(selectedSort: type)
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        player.userPlaylists = playlists
                    }
                }
            } catch {
                print("排序加载失败: \(error)")
            }
        }
    }
}

#Preview {
    SortMenuView()
}
