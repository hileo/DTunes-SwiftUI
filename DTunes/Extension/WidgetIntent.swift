//
//  WidgetIntent.swift
//  Widget1
//
//  Created by OllyWang on 7/30/25.
//

import Foundation
import WidgetKit
import SwiftUI
import AppIntents
import MusicKit

struct PlayPauseIntent: AppIntent, AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Play/Pause Music"
    static var description = IntentDescription("Toggle playback")

    func perform() async throws -> some IntentResult {
        let player = ApplicationMusicPlayer.shared
        
        if player.state.playbackStatus == .playing {
            player.pause()
        } else {
            try await player.play()
        }
        
        return .result()
    }
}
struct NextTrackIntent: AppIntent,AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Next Track"
    static var description = IntentDescription("Skips to the next track")
    
    func perform() async throws -> some IntentResult {
        print("Next Track")
        try await ApplicationMusicPlayer.shared.skipToNextEntry()
        return .result()
    }
}

struct PreviousTrackIntent: AppIntent,AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Previous Track"
    static var description = IntentDescription("Goes to the previous track")
    
    func perform() async throws -> some IntentResult {
        print("Previous Track")
        try await ApplicationMusicPlayer.shared.skipToPreviousEntry()
        return .result()
    }
}

struct FavoriteTrackIntent: AppIntent,AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Favorite Track"
    static var description = IntentDescription("Favorite track")
    
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: Notification.Name("FavoriteTrackNotification"), object: nil)
        print("Favorite Track")
        return .result()
    }
}


struct OpenPurchaseIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Purchase"

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
