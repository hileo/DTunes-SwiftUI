//
//  ClockView.swift
//  DTunes
//
//  Created by OllyWang on 3/23/26.
//

import SwiftUI
import StoreKit
import ConfettiSwiftUI

struct PaywallView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var purchaseManager: PurchaseManager

    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isCompact) var isCompact
    @Environment(\.isPad) var isPad
    @Environment(\.openURL) private var openURL

    @State private var selectedOption: PurchaseOption = .lifetime
    @State private var isBreathing = false
    @State private var showCloseButton = false
    @State private var appear = [false, false, false, false, false, false]
    @State private var continueText = NSLocalizedString("Pay_Continue", comment: "")
    @State var counter4:Int = 0

    var safeAreaSpace: CGFloat {
        isLandscape ? 0 : 44
    }
    
    var safeAreaSpaceBottom: CGFloat {
        isLandscape ? 0 : 14
    }
    
    enum PurchaseOption {
        case yearly, lifetime
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                if !isLandscape || isPad {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // 顶部 Logo 与 标题
                        premiumTitle
                            .appearAnimation(appear[0])
                        Spacer()
                        
                        if purchaseManager.isPro {
                            premiumUnlock
                                .overlay{
                                    ConfettiCannon(trigger: $purchaseManager.counter, num: 66, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
                                }
                            Spacer()
                        }

                        // 功能列表
                       premiumFeatures
                            .appearAnimation(appear[1])
                        Spacer()
                        
                        if !purchaseManager.isPro {
                            purchaseButtons
                        }
                    }
                } else {
                    HStack(spacing: 0) {
                        VStack(spacing: 20) {
                            Spacer()
                            // 顶部 Logo 与 标题
                            premiumTitle
                                .appearAnimation(appear[0])
                            // 功能列表
                           premiumFeatures
                                .appearAnimation(appear[1])
                        }
                        
                        VStack(spacing: 20) {
                            if purchaseManager.isPro {
                                Spacer()
                                premiumUnlock
                                    .overlay{
                                        ConfettiCannon(trigger: $purchaseManager.counter, num: 66, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
                                    }
                                Spacer()
                            } else {
                                Spacer()
                                purchaseButtons
                                Spacer()
                            }
                        }
                    }
                }
                
                
                // 底部
                Spacer()
                bottomLink
                    .appearAnimation(appear[5])
            }
            
            if purchaseManager.isPurchasing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ProgressView()
                    .scaleEffect(1.4)
                    .tint(.white)
            }
            
            buttonClose
        }
        .background{
            Color.black
                .ignoresSafeArea()
            
            Circle()
                .fill(Color(hex: "1B8EED"))
                .blur(radius: 90)
                .frame(width: 700, height: 600)
                .opacity(isBreathing ? 0.8 : 1.0)
                .scaleEffect(isBreathing ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 4.0)
                        .repeatForever(autoreverses: true),
                    value: isBreathing
                )
                .offset(y: isBreathing ? 600 :350)
            
            StarryBackground()
        }
        .onAppear {
            isBreathing = true
            for i in appear.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    appear[i] = true
                }
            }
        }
        .animation(.easeInOut, value: purchaseManager.isPurchasing)
        
    }
    
    @ViewBuilder
    var purchaseButtons:some View{
        
         // 付费选项卡片
         VStack(spacing: 16) {
             // Yearly 选项
             if let yearly = purchaseManager.product(for: ProductID.yearly.rawValue) {
                 SubscriptionCard(
                     title: NSLocalizedString("Pay_Yearly", comment: ""),
                     price: yearly.displayPrice,
                     subtitle: NSLocalizedString("Pay_YearlyTip", comment: ""),
                     isSelected: selectedOption == .yearly
                 ){
                     selectedOption = .yearly
                     withAnimation(){
                         continueText = NSLocalizedString("Pay_FreeTrial", comment: "")
                     }
                     Task {
                         await purchaseManager.purchase(yearly)
                     }
                 }
                 .disabled(purchaseManager.isPurchasing)
                 .appearAnimation(appear[2])
             }
             
             
             // Lifetime 选项
             if let lifetime = purchaseManager.product(for: ProductID.lifetimeV2.rawValue) {
                 SubscriptionCard(
                     title: NSLocalizedString("Pay_Lifetime", comment: ""),
                     price: lifetime.displayPrice,
                     subtitle: NSLocalizedString("Pay_LifetimeTip", comment: ""),
                     isSelected: selectedOption == .lifetime
                 ){
                     selectedOption = .lifetime
                     withAnimation(){
                         continueText = "继续"
                     }
                     Task {
                         await purchaseManager.purchase(lifetime)
                     }
                 }
                 .appearAnimation(appear[3])
                 .disabled(purchaseManager.isPurchasing)
             }
         }
         .padding(.horizontal, 24)
         
         continueButton
             .appearAnimation(appear[4])
    }
    
    var premiumTitle:some View{
        VStack(spacing: 12) {
            HStack{
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 10)
                
                VStack(spacing: 4) {
                    Text("Pay_DTunes")
                    Text(purchaseManager.isPro ? "Pay_HasPremium" : "Pay_Premium")

                }
                .font(.system(size: 33, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            }
            .offset(x:-20)
        }
        .padding(.top, isPad ? 5 : 20)
    }
    
    var premiumFeatures:some View{
        VStack(alignment: .leading, spacing: isPad ? 5 : 20) {
            FeatureRow(icon: "play.square.stack", text: NSLocalizedString("Pay_AllPlaylists", comment: ""))
            FeatureRow(icon: "clock.badge", text: NSLocalizedString("Pay_ClockTheme", comment: ""))
            FeatureRow(icon: "square.grid.2x2", text: NSLocalizedString("Pay_Widgets", comment: ""))
            FeatureRow(icon: "xmark.seal", text: NSLocalizedString("Pay_AdFree", comment: ""))
            FeatureRow(icon: "wand.and.rays.inverse", text: NSLocalizedString("Pay_Future", comment: ""))
        }
        .padding(.horizontal, 40)
    }
    
    var premiumUnlock:some View{
        HStack{
            Image(systemName: "laurel.leading")
                .font(.system(size: 60))
            Text("Pay_HasUnlockAll")
                .font(.system(size: 22))
                .multilineTextAlignment(.center)
            Image(systemName: "laurel.trailing")
                .font(.system(size: 60))
        }
        .foregroundStyle(.white)
    }
    
    var continueButton:some View{
        Button(action: {
            if selectedOption == .yearly {
                if let yearly = purchaseManager.product(for: ProductID.yearly.rawValue) {
                    Task {
                        await purchaseManager.purchase(yearly)
                    }
                }
            }

            if selectedOption == .lifetime {
                if let lifetime = purchaseManager.product(for: ProductID.lifetimeV2.rawValue) {
                    Task {
                        await purchaseManager.purchase(lifetime)
                    }
                }
            }
        }) {
            Text(continueText)
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Color.white)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 24)
        .disabled(purchaseManager.isPurchasing)
    }
    
    var  bottomLink:some View{
        VStack{
            Text("Pay_SubscriptionTip")
                .font(.caption2)
                .foregroundColor(Color(hex: "54A9EF"))
                .padding(.horizontal,30)
                .padding(.top, 20)
            
            HStack(spacing: 20) {
                Button("Setting_Restore") {
                    Task {
                        await purchaseManager.restore()
                    }
                }
                Button("Setting_Terms") {
                    openTerms()
                }
                Button("Setting_Privacy") {
                    openPrivacy()
                }
            }
            .font(.caption2)
            .foregroundColor(Color(hex: "98D0FF"))
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
        
    }
    
    var buttonClose: some View {
        Button {
            playerManager.paywallShow = false
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(.white)
                .font(.body)
                .frame(width: 44, height: 44)
        }
        .applyGlassEffect(shape: Circle())
        .opacity(showCloseButton ? 1 : 0)
        .animation(.easeIn(duration: 0.5), value: showCloseButton)
        
        .onAppear {
            if !purchaseManager.isPro {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCloseButton = true
                }
            } else {
                showCloseButton = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(20)
        .padding(.top, isPad ? 0 : (isLandscape ? 20 : 40))
        .padding(.trailing, isPad ? 0 : (isLandscape ? 50 : 0))
        .ignoresSafeArea()
    }
    
    private func openTerms() {
        guard let url = URL(string: "https://sites.google.com/view/dtunes/home/terms") else { return }
        openURL(url)
    }
    
    private func openPrivacy() {
        guard let url = URL(string: "https://sites.google.com/view/dtunes/home/privacy") else { return }
        openURL(url)
    }
}

// MARK: - 子视图组件

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 30)
            Text(text)
                .font(.system(size: 16, weight: .medium))
        }
        .foregroundColor(.white)
    }
}

struct SubscriptionCard: View {
    let title: String
    let price: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.bold())
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(price)
                    .font(.title3)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isSelected
                    ? AnyShapeStyle(Color.yellow.opacity(0.8))
                    : AnyShapeStyle(Color.gray.opacity(0.3)),
                    lineWidth: isSelected ? 3 : 2
                )
        )
        .foregroundColor(.white)
    }
}


#Preview {
    PaywallView()
}
