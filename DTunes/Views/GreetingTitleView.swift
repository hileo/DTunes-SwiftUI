//
//  GreetingTitleView.swift
//  DTunes
//
//  Created by OllyWang on 2/26/26.
//

import SwiftUI

struct GreetingTitleView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 5)) { context in
            let period = TimePeriod.current(date: context.date)
            
            Text(NSLocalizedString(period.titleKey, comment: ""))
                .PlaylistLargeTitle()
                .foregroundStyle(.white)
        }
    }
}
                                                                                                   
struct UserTitleView: View {
    var body: some View {
        Text(NSLocalizedString("Lan_HelloDear", comment: ""))
            .PlaylistLargeTitle()
            .foregroundStyle(.white)
    }
}

#Preview {
    GreetingTitleView().background(.black)
}
