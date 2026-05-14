//
//  widgets.swift
//  widgets
//
//  Created by OllyWang on 7/31/25.
//

import WidgetKit
import SwiftUI
import AppIntents
import ClockRotationEffect

// MARK: - Constants

struct Constants {
    static let appGroupID = "group.com.gogoapp.dtunes.widgets"
    static let widgetLaunchedKey = "widgetApplLaunched"
    static let songNameKey = "widgetAppSongName"
    static let songArtistKey = "widgetAppArtistName"

    static let isPlayingKey = "widgetAppIsPlaying"
    static let isProKey = "widgetAppIsPro"
    static let isLikedKey = "widgetAppIsFavorite"

    static let songImageKey = "widgetAppSongImage"
    
    static let placeholderImageName = "AlbumCover"
    static let vinylBackgroundImageName = "VinylBackground"
    static let mediumBackgroundImageName = "Medium"
    static let largeBackgroundImageName = "Large"
    static let upgradeBackgroundImageName = "upgradeBackground"
    static let crownImageName = "gopro_crown"
    
    static let defaultRotationAngle: Angle = .degrees(17)
    static let smallWidgetRotationAngle: Angle = .degrees(17)
    static let mediumWidgetRotationAngle: Angle = .degrees(-23)
    static let largeWidgetRotationAngle: Angle = .degrees(28)
    
    static let smallWidgetDuration: TimeInterval = 38
    static let mediumWidgetDuration: TimeInterval = 32
    static let largeWidgetDuration: TimeInterval = 28
    
    static let smallCoverSize: CGFloat = 100
    static let mediumCoverSize: CGFloat = 130
    static let largeCoverSize: CGFloat = 110
    
    static let smallVinylSize: CGFloat = 170
    static let mediumVinylSize: CGFloat = 280
    static let largeVinylSize: CGFloat = 220
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry   // ✅ 指定类型

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀", isPreview: context.isPreview)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), emoji: "😀", isPreview: context.isPreview)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        for hourOffset in 0..<5 {
            if let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) {
                entries.append(SimpleEntry(date: entryDate, emoji: "😀", isPreview: context.isPreview))
            }
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
    let isPreview: Bool
}

// MARK: - Widget Configuration

struct WidgetVinyl: Widget {
    let kind: String = "widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
                .modifyForiOSVersion()
        }
        .configurationDisplayName(NSLocalizedString("Play_NowPlaying", comment: ""))
        .description(NSLocalizedString("Widget_CoolViny", comment: ""))
    }
}

private extension View {
    @ViewBuilder
    func modifyForiOSVersion() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(.fill.tertiary, for: .widget)
        } else {
            self.padding().background()
        }
    }
}

// MARK: - Main Widget View

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    private var widgetData: WidgetData {
        WidgetData.loadFromUserDefaults()
    }
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(data: widgetData, entry: entry)
            case .systemMedium:
                MediumWidgetView(data: widgetData, entry: entry)
            case .systemLarge:
                LargeWidgetView(data: widgetData, entry: entry)
            case .systemExtraLarge:
                ExtraLargeWidgetView(data: widgetData, entry: entry)
            default:
                Text("Unsupported widget size")
            }
        }
    }
}

// MARK: - Widget Data Model

struct WidgetData {
    let isAppLaunched: Bool
    let songName: String
    let artistName: String
    let songImage: Data?
    let isPlaying: Bool
    let isPro: Bool
    let isLided: Bool
    static func loadFromUserDefaults() -> WidgetData {
        let userDefaults = UserDefaults(suiteName: Constants.appGroupID)
        
        return WidgetData(
            isAppLaunched: userDefaults?.bool(forKey: Constants.widgetLaunchedKey) ?? false,
            songName: userDefaults?.string(forKey: Constants.songNameKey) ?? NSLocalizedString("Play_NowPlaying", comment: ""),
            artistName: userDefaults?.string(forKey: Constants.songArtistKey) ?? "Kelly",
            songImage: userDefaults?.data(forKey: Constants.songImageKey) ?? UIImage(named: Constants.placeholderImageName)?.pngData(),
            isPlaying: userDefaults?.bool(forKey: Constants.isPlayingKey) ?? false,
            isPro: userDefaults?.bool(forKey: Constants.isProKey) ?? false,
            isLided: userDefaults?.bool(forKey: Constants.isLikedKey) ?? false

        )
    }
}

// MARK: - Shared Components

struct VinylView: View {
    let imageData: Data?
    let backgroundImageName: String
    let vinylSize: CGFloat
    let coverSize: CGFloat
    let rotationAngle: Angle
    let isPlaying: Bool
    let duration: TimeInterval
    
    var body: some View {
        ZStack {
            // Vinyl background
            Image(backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: vinylSize, height: vinylSize)
                .clipShape(Circle())
            
            // Album cover
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .rotationEffect(rotationAngle)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: coverSize, height: coverSize)
                    .clipShape(Circle())
            }
        }
        .applyRotationEffect(isPlaying: isPlaying, duration: duration)
    }
}

extension View {
    @ViewBuilder
    func applyRotationEffect(isPlaying: Bool, duration: TimeInterval) -> some View {
        if isPlaying {
            self.modifier(ClockRotationModifier(
                period: ClockRotationPeriod.custom(duration),
                timezone: TimeZone.current,
                anchor: .center
            ))
            .animation(.linear(duration: 1), value: UUID())
        } else {
            self
        }
    }
}

struct BlurredBackground: View {
    let imageData: Data?
    let scale: CGFloat
    let blurRadius: CGFloat
    
    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: blurRadius)
                .scaleEffect(scale)
        }
    }
}

struct UpgradeProView: View {
    let widgetFamily: WidgetFamily
    
    private var crownSize: (width: CGFloat, height: CGFloat) {
        switch widgetFamily {
        case .systemSmall: return (75, 75)
        case .systemMedium: return (90, 90)
        case .systemLarge: return (100, 100)
        case .systemExtraLarge: return (140, 140)
        default: return (90, 90)
        }
    }
    
    private var fontSize: CGFloat {
        switch widgetFamily {
        case .systemSmall: return 12
        case .systemMedium: return 16
        case .systemLarge: return 20
        case .systemExtraLarge: return 25
        default: return 16
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .offset(x: -30, y: -40)
                .scaleEffect(2.1, anchor: .zero)
                .opacity(0.7)
            
            VStack {
                if widgetFamily != .systemMedium {
                    Spacer()
                }
                
                Image(systemName: "sparkles")
                    .font(.system(size: fontSize + 40))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: crownSize.width, height: crownSize.height)

//                Image(Constants.crownImageName)
//                    .resizable()
//                    .frame(width: crownSize.width, height: crownSize.height)
                
                Text(NSLocalizedString("Widget_UpgradeToPremium", comment: ""))
                    .foregroundColor(.white)
                    .font(.system(size: fontSize))
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                
                if widgetFamily != .systemMedium {
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .widgetURL(URL(string: "dtunesmusic://upgradepro"))
    }
}

struct MusicControls: View {
    let isPlaying: Bool
    let widgetFamily: WidgetFamily
    
    private var spacing: CGFloat {
        (widgetFamily == .systemLarge || widgetFamily == .systemExtraLarge) ? 45 : 28
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            // Previous track button
            controlButton(
                imageName: "Previous",
                intent: PreviousTrackIntent()
            )
            
            // Play/Pause button
            Button(intent: PlayPauseIntent()) {
                Image(isPlaying ? "Pause" : "Play")
                    .controlIconStyle(for: widgetFamily)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Next track button
            controlButton(
                imageName: "Next",
                intent: NextTrackIntent()
            )
        }
    }
    
    @ViewBuilder
    private func controlButton(imageName: String, intent: some AppIntent) -> some View {
        Button(intent: intent) {
            Image(imageName)
                .controlIconStyle(for: widgetFamily)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private extension Image {
    func controlIconStyle(for family: WidgetFamily) -> some View {
        let size: CGFloat = {
            switch family {
            case .systemLarge:
                return 32
            case .systemExtraLarge:
                return 40
            default:
                return 28
            }
        }()
        return self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .opacity(1.0)
    }
}

// MARK: - Widget Size Views

struct SmallWidgetView: View {
    let data: WidgetData
    let entry: SimpleEntry
    var body: some View {
        ZStack {
            // Background
            BlurredBackground(
                imageData: data.songImage,
                scale: 1.5,
                blurRadius: 20
            )
            Group{
                // Song name
                songNameView
                
                // Vinyl record
                vinylView
            }
            .blur(radius: !data.isPro ? (!entry.isPreview ? 1.0 : 0) : 0)
        }
        .overlay(
                !entry.isPreview ? proOverlay : nil
            )
    }
    
    private var songNameView: some View {
        VStack(alignment: .trailing) {
            Text(data.songName)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 120, height: 20)
                .offset(y: 55)
        }
    }
    
    private var vinylView: some View {
        HStack {
            ZStack {
                // Shadow
                Rectangle()
                    .frame(width: Constants.smallVinylSize, height: Constants.smallVinylSize)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.5), radius: 4, x: -2, y: 5)
                
                // Vinyl with cover
                VinylView(
                    imageData: data.songImage,
                    backgroundImageName: Constants.vinylBackgroundImageName,
                    vinylSize: Constants.smallVinylSize,
                    coverSize: Constants.smallCoverSize,
                    rotationAngle: Constants.smallWidgetRotationAngle,
                    isPlaying: data.isPlaying,
                    duration: Constants.smallWidgetDuration
                )
            }
            .padding(.top, -120)
        }
    }
    
    @ViewBuilder
    private var proOverlay: some View {
        if !data.isPro {
            UpgradeProView(widgetFamily: .systemSmall)
        }
    }
}

struct MediumWidgetView: View {
    let data: WidgetData
    let entry: SimpleEntry
    var body: some View {
        ZStack {
            // Background
            BlurredBackground(
                imageData: data.songImage,
                scale: 1.3,
                blurRadius: 20
            )
            
            // Content
            Group{
                VStack(alignment: .leading) {
                    songNameView
                    artistNameView
                    if #available(iOS 17.0, *) {
                        MusicControls(
                            isPlaying: data.isPlaying,
                            widgetFamily: .systemMedium
                        )
                        .padding(.top, 40)
                        .padding(.leading, 190)
                        .padding(.trailing,35)
                    }
                }
                
                // Vinyl record
                vinylView
            }
            .blur(radius: !data.isPro ? (!entry.isPreview ? 1.0 : 0) : 0)
        }
//        .overlay(
//            Color.white.opacity(0.6)
//                .blur(radius: 0.5)
//            )
        .overlay(
                !entry.isPreview ? proOverlay : nil
            )
    }
    
    private var songNameView: some View {
        Text(data.songName)
            .font(.system(size: 16))
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(width: 160, height: 20)
            .offset(x: 180, y: 25)
    }
    
    private var artistNameView: some View {
        Text(data.artistName)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .frame(width: 160, height: 20)
            .offset(x: 180, y: 30)
            .opacity(0.8)
    }
    
    private var vinylView: some View {
        HStack {
            Spacer()
            ZStack {
                // Shadow
                Rectangle()
                    .frame(width: Constants.mediumVinylSize, height: Constants.mediumVinylSize)
                    .clipShape(Circle())
                    .foregroundColor(.black.opacity(1.0))
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 3, y: 5)
                
                // Vinyl with cover
                VinylView(
                    imageData: data.songImage,
                    backgroundImageName: Constants.mediumBackgroundImageName,
                    vinylSize: Constants.mediumVinylSize,
                    coverSize: Constants.mediumCoverSize,
                    rotationAngle: Constants.mediumWidgetRotationAngle,
                    isPlaying: data.isPlaying,
                    duration: Constants.mediumWidgetDuration
                )
            }
            Spacer()
        }
        .offset(x: -150, y: -45)
    }
    
    @ViewBuilder
    private var proOverlay: some View {
        if !data.isPro {
            UpgradeProView(widgetFamily: .systemMedium)
        }
    }
}

struct LargeWidgetView: View {
    let data: WidgetData
    let entry: SimpleEntry
    var body: some View {
        ZStack {
            // Background
            BlurredBackground(
                imageData: data.songImage,
                scale: 2.1,
                blurRadius: 30
            )
            .offset(x: -30, y: -40)
            
            Group{
                // Vinyl record
                vinylView
                
                // Song name and controls
                VStack {
                    songNameView
                    artistNameView
                    MusicControls(
                        isPlaying: data.isPlaying,
                        widgetFamily: .systemLarge
                    )
                    .offset(y:115)
                }
            }
            .blur(radius: !data.isPro ? (!entry.isPreview ? 1.0 : 0) : 0)

        }
        .overlay(
                !entry.isPreview ? proOverlay : nil
            )
    }
    
    private var songNameView: some View {
        Text(data.songName)
            .font(.system(size: 16))
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(width: 260, height: 20)
            .offset(y:120)
    }
    
    private var artistNameView: some View {
        Text(data.artistName)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .frame(width: 260, height: 20)
            .offset(y:115)
            .opacity(0.7)
    }
    
    private var vinylView: some View {
        HStack {
            ZStack {
                // Shadow
                Rectangle()
                    .frame(width: Constants.largeVinylSize, height: Constants.largeVinylSize)
                    .clipShape(Circle())
                    .foregroundColor(.black.opacity(1.0))
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 3, y: 5)
                    .offset(x: 100, y: 0)

                // Vinyl with cover
                VinylView(
                    imageData: data.songImage,
                    backgroundImageName: Constants.largeBackgroundImageName,
                    vinylSize: Constants.largeVinylSize,
                    coverSize: Constants.largeCoverSize,
                    rotationAngle: Constants.largeWidgetRotationAngle,
                    isPlaying: data.isPlaying,
                    duration: Constants.largeWidgetDuration
                )
                .offset(x: 100, y: 0)

                ZStack {
                   
                    // Album art
                    if let imageData = data.songImage, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
    //                        .rotationEffect(Angle.degrees(-6.0))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 3, y: 5)
                    }
                        Image("AlbumCoverPlastic") // 使用 Assets.xcassets 中的图片名称
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
                            .clipped()
                }
                .transformEffect(CGAffineTransform(rotationAngle: CGFloat(-9.0 * .pi / 180)))
                .offset(x: -90, y: -45)
                
            }
            Spacer()
        }
        .offset(x: 50, y: -35)
    }
    
    @ViewBuilder
    private var proOverlay: some View {
        if !data.isPro {
            UpgradeProView(widgetFamily: .systemLarge)
        }
    }
}

struct ExtraLargeWidgetView: View {
    let data: WidgetData
    let entry: SimpleEntry

    var body: some View {
        ZStack {
            // Background
            BlurredBackground(
                imageData: data.songImage,
                scale: 2.5,
                blurRadius: 40
            )
            .offset(x: -40, y: -50)

            HStack {
                // Left: Album Art
                albumArtView
                Spacer()
                // Right: Song Info & Controls
                ZStack {
                    vinylView
                        .offset(x: 150, y: -170)
                    VStack(alignment: .center, spacing: 20) {
                        songNameView
                        artistNameView
                        MusicControls(
                            isPlaying: data.isPlaying,
                            widgetFamily: .systemExtraLarge
                        )
                        .padding(.top, 0)
                    }
                    .padding(.top, 110)
                }
            }
            .padding(.horizontal, 25) // 加点左右内边距
            .blur(radius: !data.isPro ? (!entry.isPreview ? 1.0 : 0) : 0)
        }
        .overlay(
            !entry.isPreview ? proOverlay : nil
        )
    }

    private var songNameView: some View {
        Text(data.songName)
            .font(.system(size: 24))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .lineLimit(1)
    }

    private var artistNameView: some View {
        Text(data.artistName)
            .font(.system(size: 20))
            .foregroundColor(.white.opacity(0.8))
            .lineLimit(1)
    }

    private var vinylView: some View {
        ZStack {
            // Shadow
            Rectangle()
                .frame(width: 320, height: 320)
                .clipShape(Circle())
                .foregroundColor(.black.opacity(1.0))
                .shadow(color: .black.opacity(0.5), radius: 6, x: 5, y: 8)

            // Vinyl with cover
            VinylView(
                imageData: data.songImage,
                backgroundImageName: Constants.largeBackgroundImageName,
                vinylSize: 320,
                coverSize: 170,
                rotationAngle: .degrees(28),
                isPlaying: data.isPlaying,
                duration: 25
            )
        }
    }
    
    private var albumArtView: some View {
        ZStack {
            if let imageData = data.songImage, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(color: .black.opacity(0.5), radius: 6, x: 3, y: 6)
            }
        }
    }

    @ViewBuilder
    private var proOverlay: some View {
        if !data.isPro {
            UpgradeProView(widgetFamily: .systemExtraLarge)
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    WidgetVinyl()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀",isPreview: true)
    SimpleEntry(date: .now, emoji: "🤩",isPreview: true)
}
