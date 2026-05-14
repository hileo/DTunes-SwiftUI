//
//  IconSelectionView.swift
//  DTunes
//
//  Created by OllyWang on 3/30/26.
//

import SwiftUI

struct IconSelectionView: View {
    @EnvironmentObject var player: PlayerStore
    @Environment(\.isLandscape) var isLandscape
    @Environment(\.isPad) var isPad
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            HStack(spacing: 40) {
                IconButton(
                    imageName: "ICON1",
                    tag: "ICON1",
                    currentSelection: $player.selectedIcon
                ){
                    player.selectedIcon = "ICON1"
                    changeAppIcon(to: "ICON1")
                }
                IconButton(
                    imageName: "ICON2",
                    tag: "ICON2",
                    currentSelection: $player.selectedIcon
                ){
                    player.selectedIcon = "ICON2"
                    changeAppIcon(to: "ICON2")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
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
//            .padding(.top, isPad ? 0 : (isLandscape ? 20 : 0))
            .padding(.trailing, isPad ? 0 : (isLandscape ? 50 : 0))
        }
    }
    
    func changeAppIcon(to name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("不支持切换图标")
            return
        }

        UIApplication.shared.setAlternateIconName(name) { error in
            if let error = error {
                print("切换失败: \(error.localizedDescription)")
            } else {
                print("切换成功",name ?? "11")
            }
        }
    }
}

struct IconButton: View {
    let imageName: String
    let tag: String
    @Binding var currentSelection: String
    var action: () -> Void

    private var isSelected: Bool {
        currentSelection == tag
    }
    
    private let iconSize: CGFloat = 100
    private let cornerRadius: CGFloat = 22
    private let gap: CGFloat = 5
    
    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .scaleEffect(isSelected ? 1.0 : 0.96)
            
                .overlay {
                    let strokeWidth: CGFloat = isSelected ? 3 : 2
                    let insetAmount = -(gap + strokeWidth / 2)
                    
                    RoundedRectangle(cornerRadius: cornerRadius + gap/2, style: .continuous)
                        .inset(by: insetAmount)
                        .stroke(
                            isSelected ? Color.yellow : Color.gray.opacity(0.5),
                            lineWidth: strokeWidth
                        )
                    
                        .frame(width: iconSize, height: iconSize)
                        .scaleEffect(isSelected ? 1.0 : 0.96)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
    }
}


#Preview {
    IconSelectionView()
        .environmentObject(PlayerStore(purchaseManager: PurchaseManager()))
}

