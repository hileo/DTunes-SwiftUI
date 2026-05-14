//
//  Setting.swift
//  DTunes
//
//  Created by OllyWang on 1/6/26.
//

import SwiftUI

enum SettingItem: String, Hashable, CaseIterable {
    case profile = "个人资料"
    case notifications = "通知设置"
    case display = "显示与亮度"
    case privacy = "隐私与安全"
    
    var icon: String {
        switch self {
        case .profile: return "person.circle"
        case .notifications: return "bell.badge"
        case .display: return "sun.max"
        case .privacy: return "hand.raised"
        }
    }
}

struct TestSetting: View {
    @EnvironmentObject var player: PlayerStore
    @Environment(\.dismiss) var dismiss
    // 2. 使用 path 管理导航状态（可选，用于编程式导航）
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack{
                
                
                List {
                    
                 
                    
                    Section {
                        Button(action: {
                                // 这里触发跳转逻辑，或者通过隐藏的 NavigationLink 触发
                                print("点击了 Help")
                            }) {
                                HStack {
                                    Label("Help", systemImage: "questionmark.circle")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.orange)
                                }
                                .padding(.vertical, 4) // 适当增加点击区域高度
                            }
                           

                        
                        HStack {
                                Label("Help", systemImage: "questionmark.circle")
                                
                                Spacer()
                                
                                // 这里放置你自定义的右侧图标
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold)) // 加粗一点
                                .foregroundColor(.orange)               // 真正改变颜色
                            }
                            .background(
                                NavigationLink("", destination: Text("Help Content"))
                                    .opacity(0)
                            )
                        
                        NavigationLink(destination: Text("详情页")) {
                            HStack {
                                Text("自定义箭头颜色")
                                Spacer()
                                // 1. 自己写一个箭头
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold)) // 加粗一点
                                    .foregroundColor(.orange)               // 真正改变颜色
                            }
                        }
                        
                        Link(destination: URL(string: "https://designcode.io")!) {
                            HStack {
                                Label("YouTube", systemImage: "tv")
                                    .tint(.primary)
                                Spacer()
                                Image(systemName: "link")
                                    .tint(.secondary)
                            }
                        }
                        
                        // 2. 这里的技巧是：如果你在 HStack 里用了 Spacer，
                        // 系统箭头有时会重叠，所以我们通常会通过这种结构直接覆盖视觉。
//                        .tint(Color.red)
                        .accentColor(.orange)
                        NavigationLink {} label: {
                            HStack {
                                Label("Billing", systemImage: "creditcard")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold)) // 加粗一点
                                    .foregroundColor(.orange)
                                    .background(Color.red)
                            }
                            
                           
                        }
                        
                        NavigationLink {} label: {
                            Label("Help", systemImage: "questionmark.circle")
                        }
                    }
                    .listRowSeparator(.automatic)
                    .listRowBackground(Color(hex: "28282D"))
                    .listRowSeparatorTint(.red.opacity(0.2)) // 将该 Section 的分割线设为红色
                    
                    Section {
                        Toggle(isOn: $player.autoplay) {
                            Label("Lite Mode", systemImage: player.autoplay ? "tortoise" : "hare")
                        }
                    }
                    
                    Section("通用设置") {
                        ForEach(SettingItem.allCases, id: \.self) { item in
                            // 3. NavigationLink 只携带数据 (value)
                            NavigationLink(value: item) {
                                Label(item.rawValue, systemImage: item.icon)
                            }
                        }
                    }
                    
                    Section {
                        Button("退出登录", role: .destructive) {
                            // 处理点击逻辑
                        }
                    }
                }
//                .tint(Color.red)
                .scrollContentBackground(.hidden)
                .background(Color(hex: "17171B"))
                .navigationTitle("设置")
                .navigationBarTitleDisplayMode(.inline)
                // 4. 统一处理跳转目标
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
                        }
                    }
                }
            }
            
        }
    }
}

// 详情页视图
struct DetailView: View {
    let item: SettingItem
    
    var body: some View {
        VStack {
            Image(systemName: item.icon)
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            Text("这是\(item.rawValue)的详细页面")
                .padding()
        }
        .navigationTitle(item.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FadeClickStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle()) // 确保整行可点击
            // 当按下时透明度变 0.8，放开恢复 1.0
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct ListRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle()) // 保证整行可点击
            // 当按下时，颜色变浅或变深（模拟高亮）
            .background(configuration.isPressed ? Color.red.opacity(0.7) : Color.clear)
    }
}


#Preview {
    TestSetting()
        .environmentObject(PlayerStore(purchaseManager: PurchaseManager()))
}
