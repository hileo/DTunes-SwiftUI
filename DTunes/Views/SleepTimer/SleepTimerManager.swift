//
//  SleepTimerManager.swift
//  DTunes
//
//  Created by OllyWang on 3/31/26.
//

import SwiftUI
import Combine
import MusicKit

class SleepTimerManager: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var isTimerActive: Bool = false
    
    private var cancellable: AnyCancellable?
    
    // 设置倒计时（秒）
    func startTimer(minutes: Int) {
        timeRemaining = minutes * 60
        isTimerActive = true
        
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    withAnimation(.smooth(duration: 0.25)) {
                        self.timeRemaining -= 1
                    }
                } else {
                    self.stopMusicAndApp()
                }
            }
    }
    
    func cancelTimer() {
        isTimerActive = false
        cancellable?.cancel()
    }
    
    private func stopMusicAndApp() {
        isTimerActive = false
        cancellable?.cancel()
        ApplicationMusicPlayer.shared.stop()
        print("倒计时结束，停止播放")
    }
}
