//
//  TimePeriod.swift
//  DTunes
//
//  Created by OllyWang on 2/26/26.
//

import SwiftUI

enum TimePeriod {
    case midnight, morning, afternoon, evening, night, unknown
    
    static func current(date: Date = Date()) -> TimePeriod {
        let hour = Calendar.current.component(.hour, from: date)
        
        switch hour {
        case 0..<5:   return .midnight
        case 5..<12:  return .morning
        case 12..<18: return .afternoon
        case 18..<21: return .evening
        case 21..<24: return .night
        default:      return .unknown
        }
    }
}

extension TimePeriod {
    var titleKey: String {
        switch self {
        case .midnight:  return "Lan_MidnightGoSleep"
        case .morning:   return "Lan_GoodMorning"
        case .afternoon: return "Lan_GoodAfternoon"
        case .evening:   return "Lan_GoodEvening"
        case .night:     return "Lan_GoodNight"
        case .unknown:   return "Lan_HelloDear"
        }
    }
}

extension TimePeriod {
    func playlist(from playlists: [PlaylistDT]) -> PlaylistDT {
        switch self {
        case .midnight:  return playlists[4]
        case .morning:   return playlists[0]
        case .afternoon: return playlists[1]
        case .evening:   return playlists[2]
        case .night:     return playlists[3]
        case .unknown:   return playlists[5]
        }
    }
}
