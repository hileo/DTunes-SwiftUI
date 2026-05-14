//
//  AppRouter.swift
//  DTunes
//
//  Created by OllyWang on 4/16/26.
//

import SwiftUI
import Combine

final class AppRouter: ObservableObject {

    let playerManager: PlayerManager

    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
    }

    enum Route: Identifiable {
        case purchase

        var id: String {
            switch self {
            case .purchase:
                return "purchase"
            }
        }
    }

    @Published var route: Route?

    func handle(url: URL) {
        guard url.scheme == "dtunesmusic" else { return }

        switch url.host {
        case "upgradepro":
            NotificationCenter.default.post(name: Notification.Name("GoPremiumNotification"), object: nil)
        default:
            break
        }
    }
}
