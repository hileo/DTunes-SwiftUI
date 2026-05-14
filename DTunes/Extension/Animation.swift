//
//  Animations.swift
//  DTunes
//
//  Created by OllyWang on 12/29/25.
//

import SwiftUI

extension Animation {
    static let openCard = Animation.spring(response: 0.4, dampingFraction: 1.0)//0.8
    static let closeCard = Animation.spring(response: 0.35, dampingFraction: 1.0)//0.8
    
    
    static let openClock = Animation.spring(response: 0.35, dampingFraction: 1.0)//0.8
    static let closeClock = Animation.spring(response: 0.3, dampingFraction: 1.0)//0.8
}
