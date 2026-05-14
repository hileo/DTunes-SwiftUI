//
//  Setting.swift
//  DTunes
//
//  Created by OllyWang on 1/6/26.
//

import SwiftUI
import ConfettiSwiftUI

struct SettingsView: View {
    @EnvironmentObject var player: PlayerStore
    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var musicAuth: MusicAuthViewModel

    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isCompact) var isCompact
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.isPad) var isPad
    
    @State private var animate = false
    @State private var showSheet = false
    @State private var showIconSheet = false
 
    let bannerStart = "EB144C"
    let bannerEnd = "1B8EED"
    let listBackground = "111111"
    
    
    var isPermission: Bool {
        musicAuth.alertType != .needPermission
    }

    var body: some View {
        ZStack{
            content
//                    .modifier(AdaptiveHeaderModifier())
            
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
        }
    }
    
    var content:some View{
        List() {
            
            Section() {
                ZStack(alignment: .trailing){
                    HStack{
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 40, height: 90)
                            .padding(.leading, 10)
                        
                        VStack(alignment: .leading, spacing: 8){
                            Text(purchaseManager.isPro ? "Pay_HasPremium" : "Setting_Premium")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(purchaseManager.isPro ? "Pay_HasPremiumTip" : "Setting_PremiumTip")
                                .font(.footnote)
                        }
                        .foregroundStyle(.white)
                        .padding(10)
                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .font(.headline)
//                            .fontWeight(.bold)
//                            .foregroundStyle(.white.opacity(0.4))
//                            .padding(.trailing,5)
                    }
                }
                
            }
            .background(fluid) // 应用到整个 Section 的每一行
            .onTapGesture {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playerManager.paywallShow = true
                }
            }
           
            SettingsSection(title: "Setting_Account") {
                SettingsRowRestore(title: "Setting_Restore", icon: "IconRestore", isPurchasing: $purchaseManager.isPurchasing) {
                    print("恢复购买")
                    Task {
                        await purchaseManager.restore()
                    }
                }
            }
            
            SettingsSection(title: "Setting_Music") {
                SettingsToggleRow(
                    title: "Setting_AutoPlay",
                    icon: "IconAutoplay",
                    isOn: $player.autoplay
                )
                
                SettingsRow(
                    title: "Apple Music",
                    icon: "IconAppleMusic",
                    trailingText: musicAuth.isAuthorized ? "Setting_AppleMusic_Connected" : "Setting_AppleMusic_UnConnected"
                ) {
                    print("Apple Music")
                    openAppSettings()
                }
                
                SettingsRowSleepTimer(
                    title: "Setting_Sleep",
                    icon: "IconSleep"
                ) {
                    print("定时关闭")
                    showSheet = true
                }
                .sheet(isPresented: $showSheet) {
                    SleepTimerPickerView()
                        .presentationDetents([.height(420)])
                        .presentationDragIndicator(.hidden)
                        .ignoresSafeArea()
                }
            }
            
            SettingsSection(title: "Setting_Appearance") {
                SettingsRow(title: "Setting_Change", icon: "IconChange") {
                    print("切换图标")
                    showIconSheet = true
                }
                .sheet(isPresented: $showIconSheet) {
                    IconSelectionView()
                        .presentationDetents([.height(320)])
                        .presentationDragIndicator(.hidden)
                        .ignoresSafeArea()
                }
                SettingsRow(title: "Setting_Lan", icon: "IconLanguge") {
                    openAppSettings()
                }
            }
            
            SettingsSection(title: "Setting_Support") {
                SettingsRow(title: "Setting_Rate", icon: "IconRate") {
                    openReview()
                }
                
                SettingsShareLink(title: "Setting_Share", icon: "IconShare")
               
                SettingsRow(title: "Setting_Ver", icon: "IconVersion") {
                    openAppStore()
                }
            }
            
            SettingsSection(title: "Setting_Support") {
                SettingsRow(title: "Setting_Terms", icon: "IconTerms") {
                    openTerms()
                }
                SettingsRow(title: "Setting_Privacy", icon: "IconPrivacy") {
                    openPrivacy()
                }
            }
            
        }
        .padding(.trailing, isPad ? 40 : 0)
        .padding(.leading, isPad ? 40 : 0)

        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .background(Color(hex: listBackground))
        .overlay(alignment: .top){
            if purchaseManager.isPro{
                ConfettiCannon(trigger: $purchaseManager.counter, num: 66, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
                    .padding(.top, 80)
            }
        }
        
    }
    
    var fluid:some View{
        ZStack {
            Color.black
//            Circle()
//                .fill(Color(hex: bannerStart))//hex: "EB144C")
//                .frame(width: 2000, height: 400)
//                .offset(x: animate ? (isiPad ? -500 : -100) : 50, y: animate ? 100 : -100)
//                .blur(radius: 80)
            
            Circle()
                .fill(Color(hex: bannerEnd))//Color.blue
                .frame(width: 2000, height: 300)
                .offset(x: animate ? (isCompact ? 100 : 650) : -80, y: animate ? 150 : -100)
                .blur(radius: 90)
            StarryBackground()
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
        .ignoresSafeArea()
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openAppStore() {
        let urlString = "itms-apps://itunes.apple.com/app/id\(player.appID)"
        
        guard let url = URL(string: urlString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTerms() {
        guard let url = URL(string: "https://sites.google.com/view/dtunes/home/terms") else { return }
        openURL(url)
    }
    
    private func openPrivacy() {
        guard let url = URL(string: "https://sites.google.com/view/dtunes/home/privacy") else { return }
        openURL(url)
    }

    private func openReview() {
        let urlString = "itms-apps://itunes.apple.com/app/id\(player.appID)?action=write-review"
        
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}


struct SettingsShareLink: View {
    let title: LocalizedStringKey
    let icon: String
    @EnvironmentObject var player: PlayerStore

    var body: some View {
        ShareLink(
            item: URL(string: "https://apps.apple.com/app/id\(player.appID)")!,
            message: Text("Share_Tip")
        ) {
            HStack {
                Label {
                    Text(title)
                } icon: {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

struct SettingsRowSleepTimer: View {
    @EnvironmentObject var player: PlayerStore
    let title: LocalizedStringKey
    let icon: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Label {
                    Text(title)
                } icon: {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
                Spacer()
                
                Text( player.sleeptimerManager.isTimerActive
                      ? LocalizedStringKey(formatTimeString(seconds: player.sleeptimerManager.timeRemaining))
                      : "SleepTimeOff")
                    .foregroundStyle(.gray)
                    .font(.body)
                    .fontWeight(.regular)
                    .contentTransition(.numericText())
                    .monospacedDigit()

            }
            .padding(.vertical, 6)
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

struct SettingsRow: View {
    let title: LocalizedStringKey
    let icon: String
    var trailingText: LocalizedStringKey? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Label {
                    Text(title)
                } icon: {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
                Spacer()
                
                if let trailingText {
                    Text(trailingText)
                        .foregroundStyle(.gray)
                        .font(.body)
                        .fontWeight(.regular)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

struct SettingsRowRestore: View {
    let title: LocalizedStringKey
    let icon: String
    @Binding var isPurchasing: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Label {
                    Text(title)
                } icon: {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
                Spacer()
                
                if isPurchasing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let title: LocalizedStringKey
    let icon: String
    @Binding var isOn: Bool
    @EnvironmentObject var player: PlayerStore

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                Label {
                    Text(title)
                } icon: {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .onChange(of: isOn) {
            player.autoplay = isOn
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: LocalizedStringKey
    let sectionBackground = "1B1B1B"
    @ViewBuilder let content: Content
    
    var body: some View {
        Section(
            header: Text(title)
                .foregroundStyle(.gray)
        ) {
            content
        }
        .foregroundStyle(.white)
//        .font(.body)
        .fontWeight(.medium)
        .listRowBackground(Color(hex: sectionBackground))
        .listRowSeparatorTint(Color(hex: "2B2B2B"))
    }
}

#Preview {
    SettingsView()
        .environmentObject(PlayerStore(purchaseManager: PurchaseManager()))
    //        .preferredColorScheme(.dark)
}

struct AdaptiveHeaderModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss
    
    func body(content: Content) -> some View {
        ZStack {
            if #available(iOS 26.0, *) {
                // 新版本：使用系统导航栏
                content
                    .navigationTitle("Setting")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: SettingItem.self) { item in
                        DetailView(item: item)
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                dismiss() // 点击后关闭当前页面
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white) // 使用次级颜色，看起来更柔和
                                    .font(.body) // 控制图标大小
                                    .frame(width: 36, height: 36)
                            }
                        }
                    }
            } else {
                // 旧版本：使用叠加的自定义按钮
                content
                    .safeAreaInset(edge: .top) {
                        Color.clear
                            .frame(height: 30)
                    }
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                        .font(.body)
                        .frame(width: 36, height: 36)
                }
                .applyGlassEffect(shape: Circle())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(20)
                .ignoresSafeArea()
            }
        }
    }
}
