//
//  Playlist.swift
//  DTunes
//
//  Created by OllyWang on 12/16/25.
//

import SwiftUI
import MusicKit

struct PlaylistDT: Identifiable, Codable {
    let id = UUID()
    let title: String
    let subtitle: String
    let playlistID: String
    let playlistTag: String
    var backColor: String
    var waveColor: String
    var playlist: Playlist? = nil   // 运行时赋值
    var isLocked: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case title, subtitle, playlistID, playlistTag, backColor, waveColor
    }
}

struct PlaylistResponse: Codable {
    let playlists: [PlaylistDT]

    enum CodingKeys: String, CodingKey {
        case playlists = "Playlists"
    }
}


func loadPlaylists() -> [PlaylistDT] {
//    let jsonName = String("PlaylistJsonLan/\(NSLocalizedString("PlaylistJson", comment: ""))")

    guard let url = Bundle.main.url(forResource: NSLocalizedString("PlaylistJson", comment: ""), withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let result = try? JSONDecoder().decode(PlaylistResponse.self, from: data)
    else {
        return []
    }

    return result.playlists
}

