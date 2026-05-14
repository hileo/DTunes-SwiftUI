//
//  DTunesApp.swift
//  DTunes
//
//  Created by OllyWang on 11/13/25.
//

import SwiftUI

@main
struct DTunesApp: App {
    @StateObject private var musicAuth = MusicAuthViewModel()
    @StateObject private var playerStore = PlayerStore(purchaseManager: PurchaseManager())
    @StateObject private var playerManager = PlayerManager()
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject var router = AppRouter(playerManager: PlayerManager())

    var body: some Scene {
        WindowGroup {
//            ClockView(playlist: loadPlaylists().first!)
//            AppleMusic(playlistID: "pl.u-oZyllEgTR112vD")
            //            TestLoading()

            ContentView()
                .statusBarHidden(true)
                .preferredColorScheme(.dark)
                .environmentObject(musicAuth)
                .environmentObject(playerStore)
                .environmentObject(playerManager)
                .environmentObject(purchaseManager)
                .observeOrientation()
                .onOpenURL { url in
                    router.handle(url: url)
                }
        }
    }
}
