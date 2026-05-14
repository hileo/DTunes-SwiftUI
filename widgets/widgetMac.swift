//
//  widgetMac.swift
//  widgetsExtension
//
//  Created by OllyWang on 8/7/25.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Widget 编辑
struct MacProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MacSimpleEntry {
        MacSimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), isPreview: context.isPreview)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MacSimpleEntry {
        MacSimpleEntry(date: Date(), configuration: configuration, isPreview: context.isPreview)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MacSimpleEntry> {
        var entries: [MacSimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = MacSimpleEntry(date: entryDate, configuration: configuration, isPreview: context.isPreview)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct MacSimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let isPreview: Bool
}


struct WidgetMac: Widget {
    let kind: String = "Widget Mac"
  
       var body: some WidgetConfiguration {
           AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: MacProvider()) { entry in
//           StaticConfiguration(kind: kind, provider: MacProvider()) { entry in
               WidgetMacEntryView(entry: entry)
//                   .containerBackground(for: .widget) {
//                               // 用 Color.clear 让系统自动处理背景，或者你可以用你自己的背景
//                               Color.gray
//                           }
            }
           .configurationDisplayName(NSLocalizedString("WidgetDisplayName_classicMac", comment: ""))
           .description(NSLocalizedString("WidgetDescription_classicMac", comment: ""))
           .supportedFamilies([.systemSmall, .systemLarge])
       }
}


// MARK: - Widget Entry View (处理不同尺寸的视图选择)
struct WidgetMacEntryView: View {
    let entry: MacSimpleEntry
    
    private var widgetData: WidgetData {
        WidgetData.loadFromUserDefaults()

    }
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetMacView(entry: entry, data: widgetData)
            case .systemLarge:
                LargeWidgetMacView(entry: entry, data: widgetData)
            default:
                Text("Unsupported widget size")
            }
        }
    }
}

struct NoHighlightScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0) // 按下时缩小
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SmallWidgetMacView: View {
    @Environment(\.colorScheme) var colorScheme
    let entry: MacSimpleEntry // 确保 SimpleEntry 包含 date
    let data: WidgetData
    var body: some View {
        ZStack {
            VStack(spacing: 3) { // 垂直排列两行
                HStack(spacing: 3) { // 第一行两个按钮
                    Button(intent: PlayPauseIntent()) {
                        Image(data.isPlaying ? "classicMacKeyPause" : "classicMacKeyPlay")
                            .resizable()
                            .frame(width: 63, height: 63)
                    }
                    .frame(width: 63, height: 63)
                    .buttonStyle(NoHighlightScaleButtonStyle())
                    Button(intent: FavoriteTrackIntent()) {
                        Image(data.isLided ? "classicMacKeyLiked" : "classicMacKeyUnlike")
                            .resizable()
                            .frame(width: 63, height: 63)
                    }
                    .frame(width: 63, height: 63)
                    .buttonStyle(NoHighlightScaleButtonStyle())
                }
                HStack(spacing: 3) { // 第二行两个按钮
                    Button(intent: PreviousTrackIntent()) {
                        Image("classicMacKeyPrevious")
                            .resizable()
                            .frame(width: 63, height: 63)
                    }
                    .frame(width: 63, height: 63)
                    .buttonStyle(NoHighlightScaleButtonStyle())
                    Button(intent: NextTrackIntent()) {
                        Image("classicMacKeyNext")
                            .resizable()
                            .frame(width: 63, height: 63)
                    }
                    .frame(width: 63, height: 63)
                    .buttonStyle(NoHighlightScaleButtonStyle())
                }
            }
            .blur(radius: !data.isPro ? (!entry.isPreview ? 1.0 : 0) : 0)
            
            if !entry.isPreview {
                       proOverlay
                           .frame(maxWidth: .infinity, maxHeight: .infinity)
                           .ignoresSafeArea()
                   }
        }.containerBackground(for: .widget) { // 明确指定 widget 类型
            ZStack {
                switch entry.configuration.colorScheme {
                case .system:
                    if colorScheme == .dark {
                        Image("classicMacKeyBackgroundDark")
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("classicMacKeyBackgroundLight")
                            .resizable()
                            .scaledToFill()
                    }
                    
                case .light:
                    Image("classicMacKeyBackgroundLight")
                        .resizable()
                        .scaledToFill()
                    
                case .dark:
                    Image("classicMacKeyBackgroundDark")
                        .resizable()
                        .scaledToFill()
                }
            }
            .blur(radius: !data.isPro ? (!entry.isPreview ? 1.0 : 0) : 0)
        }
        
    }
    
    @ViewBuilder
    private var proOverlay: some View {
        if !data.isPro {
            UpgradeProView(widgetFamily: .systemSmall)
        }
    }

    // 日期格式化函数
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 例如：14:30
        return formatter.string(from: date)
    }
}

struct LargeWidgetMacView: View {
    @Environment(\.colorScheme) var colorScheme
    let entry: MacSimpleEntry // 确保 SimpleEntry 包含 date
    let data: WidgetData
    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 6) {
                // 12x12 image
                Image(data.isPlaying ? "classicMacDiskPlay" : "classicMacDiskPause")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .applyRotationEffect(isPlaying: data.isPlaying, duration: 10)
                
                // Song title text
                Text(data.songName)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 240, height: 14, alignment: .leading)
            }
            .offset(y: 85)
            .blur(radius: !data.isPro ? (!entry.isPreview ? 1.0 : 0) : 0)

            if !entry.isPreview {
                       proOverlay
                           .frame(maxWidth: .infinity, maxHeight: .infinity)
                           .ignoresSafeArea()
                   }
        }
        .containerBackground(for: .widget) { // 明确指定 widget 类型
            ZStack {
                if let imageData = data.songImage, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit() // 填充整个背景
                        .frame(width: 290, height: 290)
                        .offset(y:-5)
                } else {
                    // 备用图像（如果 data.songImage 为空或转换失败）
                    Image("AlbumCover") // 替换为你的默认背景图像名称
                        .resizable()
                        .scaledToFit()
                        .frame(width: 290, height: 290)
                        .offset(y:-5)
                }
                backgroundView
            }
            .blur(radius: !data.isPro ? (!entry.isPreview ? 1.0 : 0) : 0)
        }
        
        
    }
    
    var backgroundView: some View {
        let imageName: String
        switch entry.configuration.colorScheme {
        case .system:
            if colorScheme == .dark {
                imageName = data.isPlaying ? "classicMacOnDark" : "classicMacOffDark"
            } else {
                imageName = data.isPlaying ? "classicMacOnLight" : "classicMacOffLight"
            }
        case .light:
            imageName = data.isPlaying ? "classicMacOnLight" : "classicMacOffLight"
        case .dark:
            imageName = data.isPlaying ? "classicMacOnDark" : "classicMacOffDark"
        }
        return Image(imageName)
            .resizable()
            .scaledToFill()
            .clipped()
    }
    
    @ViewBuilder
    private var proOverlay: some View {
        if !data.isPro {
            UpgradeProView(widgetFamily: .systemLarge)
        }
    }
}

// MARK: - Main Widget View

#Preview(as: .systemSmall) {
    WidgetMac()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀",isPreview: true)
    SimpleEntry(date: .now, emoji: "🤩",isPreview: true)
}


// MARK: - Config Widget

enum WidgetColorScheme: String, AppEnum {
    case system
    case dark
    case light

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("WidgetDisplayName_classicMac_edit_title")
        )
    }

    static var caseDisplayRepresentations: [WidgetColorScheme: DisplayRepresentation] {
        [
            .system: DisplayRepresentation(
                title: LocalizedStringResource("WidgetDisplayName_classicMac_edit_system")
            ),
            .dark: DisplayRepresentation(
                title: LocalizedStringResource("WidgetDisplayName_classicMac_edit_dark")
            ),
            .light: DisplayRepresentation(
                title: LocalizedStringResource("WidgetDisplayName_classicMac_edit_light")
            ),
        ]
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource {
        LocalizedStringResource("WidgetDisplayName_classicMac")
    }

    static var description: IntentDescription {
        IntentDescription(LocalizedStringResource("WidgetDescription_classicMac"))
    }

    @Parameter(
        title: LocalizedStringResource("WidgetDisplayName_classicMac_edit_title"),
        default: .system
    )
    var colorScheme: WidgetColorScheme
}
