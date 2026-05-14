//
//  SleepTimePickerView.swift
//  DTunes
//
//  Created by OllyWang on 3/29/26.
//

import SwiftUI
import Combine

struct SleepTimerPickerView: View {
    @EnvironmentObject var player: PlayerStore
    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isPad) var isPad
    @Environment(\.dismiss) var dismiss

    @State private var selectedTime: Int = 10 // 初始选中的分钟数
    @State private var timeRemaining: Int = 0  // 剩余秒数
    
    // 定时器发布者
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                if !player.sleeptimerManager.isTimerActive {
                    timePickerView

                } else {
                    timerActiveView
                }
            }
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .font(.body)
                    .frame(width: 44, height: 44)
            }
            .applyGlassEffect(shape: Circle())
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .topTrailing)
            .padding(20)
            .padding(.top, isPad ? 0 : (isLandscape ? 20 : 0))
            .padding(.trailing, isPad ? 0 : (isLandscape ? 50 : 0))

        }
    }
    
    // MARK: - 组件：时间选择
    private var timePickerView: some View {
        VStack(spacing: 40) {
            VStack {
                let columns = Array(repeating: GridItem(.flexible()), count: 3)
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach([10, 20, 30, 45, 60, 90], id: \.self) { mins in
                        TimerButton(minutes: mins, isSelected: selectedTime == mins) {
                            selectedTime = mins
                        }
                    }
                }
                .padding(25)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        Color(hex:"3C3C3C").opacity(0.3),
                        lineWidth: 2
                    )
            )
            
            Button(action: startTimer) {
                Text("SleepTimeStart")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
        }
        .padding(20)
        .padding(.top,40)
    }
    
    // MARK: - 组件：倒计时运行
    private var timerActiveView: some View {
        VStack(spacing: 40) {
            // 时间显示区域
            
            VStack {
                Text(formatTimeString(seconds: player.sleeptimerManager.timeRemaining))
                    .font(.system(size: 70, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        Color(hex:"3C3C3C").opacity(0.3),
                        lineWidth: 2
                    )
            )
            
            // 停止按钮
            Button(action: stopTimer) {
                Text("SleepTimeEnd")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.red.opacity(0.8))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
        }
        .padding(20)
        .padding(.top,40)
       
    }
    
    // MARK: - 辅助方法
    private func startTimer() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            player.sleeptimerManager.startTimer(minutes: selectedTime)
        }
    }
    
    private func stopTimer() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            player.sleeptimerManager.cancelTimer()
        }
    }   
}

struct TimerButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(minutes)").font(.system(size: 28, weight: .semibold))
                Text("SleepTimeMin").font(.system(size: 14)).opacity(0.6)
            }
            .frame(maxWidth: .infinity).frame(height: 85)
            .background(isSelected ? Color.white : Color.clear)
            .foregroundColor(isSelected ? .black : .white)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SleepTimerPickerView()
        .preferredColorScheme(.dark)
}
