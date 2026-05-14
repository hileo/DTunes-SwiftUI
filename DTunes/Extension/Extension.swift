//
//  Extension.swift
//  DTunes
//
//  Created by OllyWang on 11/13/25.
//
import Foundation
import SwiftUI
import Photos

extension Image{
    func CircelImage(width:CGFloat) -> some View{
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .mask(Circle())
            .frame(width: width,height: width)
    }
}

extension Text {
    func PlaylistLargeTitle() -> some View {
        self
            .fontWeight(.light)
            .font(.system(size: 50))
    }
    
    func PlaylistSubTitle() -> some View {
        self
            .fontWeight(.regular)
            .font(.system(size: 14))
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String? {
           let uiColor = UIColor(self)
           
           var r: CGFloat = 0
           var g: CGFloat = 0
           var b: CGFloat = 0
           var a: CGFloat = 0
           
           guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
               return nil
           }

           let red = Int(r * 255)
           let green = Int(g * 255)
           let blue = Int(b * 255)

           return String(format: "%02X%02X%02X", red, green, blue)
       }
}

extension View {
    @ViewBuilder
    func applyGlassEffect(shape: some Shape) -> some View {
        if #available(iOS 26.0, *) {
//            self.glassEffect(.regular.interactive())
            self.glassEffect(.regular.tint(.black.opacity(0.2)).interactive())
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
    }
    
    @ViewBuilder
    func applyGlassEffectInClockView(shape: some Shape) -> some View {
        if #available(iOS 26.0, *) {
//            self.glassEffect(.regular.interactive())
            self.glassEffect(.regular.tint(.black.opacity(0.2)).interactive())
        } else {
            self.background(.black.opacity(0.5), in: shape)
        }
    }
    
    @ViewBuilder
    func applyGlassEffectInHomeView(shape: some Shape) -> some View {
        if #available(iOS 26.0, *) {
//            self.glassEffect(.regular.interactive())
            self.glassEffect(.regular.tint(.black.opacity(0.2)).interactive())
        } else {
            self.background(.black.opacity(0.5), in: shape)
        }
    }
    
}

extension View {
    
    func imageLiked(image: Image, show: Bool, isLiked: Bool, animate: Bool) -> some View{
        image
            .font(.system(size: 22))
            .fontWeight(.regular)
            .frame(width: 54, height: 54)
            .tint(isLiked ? .red : .white)
            .scaleEffect(show ? 1 : 0)
            .opacity(show ? 1 : 0)
            .animation(animate ? Animation.interpolatingSpring(stiffness: 200, damping: 15) : .none, value: show)
    }
}


struct RotationControl {
    static func setOrientation(to orientation: UIInterfaceOrientationMask) {
        // 获取当前的 Window Scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation)
            
            // 告诉系统请求更新旋转方向
            windowScene.requestGeometryUpdate(geometryPreferences) { error in
                print("旋转失败: \(error.localizedDescription)")
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    
    let style: UIBlurEffect.Style
    
    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<BlurView>) {
        
    }
}


struct BlurView2: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(
            effect: UIBlurEffect(style: style)
        )
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        //do nothing
    }
}

struct FlipPlayingImage: View {
    let image: Image
    @Binding var isPlaying: Bool
    @State private var rotation: Double = 0
    
    // 使用 iOS 17 的 Task 自动管理
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .cornerRadius(6)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.6
            )
            // iOS 17 新的 onChange 语法
            .onChange(of: isPlaying, initial: true) { oldValue, newValue in
                if newValue {
                    startFlip()
                }
            }
    }

    // 使用更现代的异步处理
    @MainActor
    private func startFlip() {
        Task {
            while isPlaying {
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotation += 180
                }
                // 总等待时间 = 动画 0.6s + 停顿 3.0s
                try? await Task.sleep(for: .seconds(5.6))
            }
        }
    }
}

extension Color {
    var luminance: CGFloat {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    var saturation: CGFloat {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return s
    }
}

extension Color {
    // 获取当前颜色的 HSB 组件
    var hsb: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        // 将 SwiftUI Color 转为 UIColor 以提取数值
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b, a)
    }
    
    // 基于原始颜色生成调整过亮度和饱和度的颜色
    func adjust(saturation: CGFloat? = nil, brightness: CGFloat? = nil) -> Color {
        let current = self.hsb
        return Color(
            hue: current.hue,
            saturation: saturation ?? current.saturation,
            brightness: brightness ?? current.brightness,
            opacity: Double(current.alpha)
        )
    }
}

func score(_ color: Color) -> CGFloat {
    let minSaturation: CGFloat = 0.15   // 太灰的不要
    let s = max(color.saturation, minSaturation)
    return color.luminance * 0.45 + s * 0.55
}


func saveCurrentScreenView<V: View>(view: V, geometry: GeometryProxy) {
    let size = geometry.size
    
    let renderer = ImageRenderer(
        content: view
            .frame(width: size.width, height: size.height)
            .ignoresSafeArea()
    )
    
    renderer.scale = UIScreen.main.scale
    
    if let image = renderer.uiImage {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
}


var colorPrimaryDefault: Color {
   return Color(hex: "858585")//FFDA3A
}

var colorSecondaryDefault: Color {
    return Color(hex: "989898")//EB9415
}

func interpolateColor(from start: Color, to end: Color, progress: CGFloat) -> Color {
    
    let t = max(0, min(1, progress))
    
    let s = UIColor(start)
    let e = UIColor(end)
    
    var sr: CGFloat = 0, sg: CGFloat = 0, sb: CGFloat = 0, sa: CGFloat = 0
    var er: CGFloat = 0, eg: CGFloat = 0, eb: CGFloat = 0, ea: CGFloat = 0
    
    s.getRed(&sr, green: &sg, blue: &sb, alpha: &sa)
    e.getRed(&er, green: &eg, blue: &eb, alpha: &ea)
    
    return Color(
        red: sr + (er - sr) * t,
        green: sg + (eg - sg) * t,
        blue: sb + (eb - sb) * t,
        opacity: sa + (ea - sa) * t
    )
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func adaptivePresentation<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad 使用 Sheet
            self.sheet(isPresented: isPresented) {
                content()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        } else {
            // iPhone 使用全屏
            self.fullScreenCover(isPresented: isPresented) {
                content()
            }
        }
    }
}

struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle()) // 确保整个区域都可点击
            .opacity(configuration.isPressed ? 0.5 : 1.0) // 点击时透明度变为 0.5
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // 增加轻微的缩放感（可选）
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct BackButtonModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
        } else {
            if #available(iOS 26, *) {
                content
                // ✅ iOS 26+ → 系统默认
            } else {
                content
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            CustomBackButton()
//                            Button {
//                                dismiss()
//                            } label: {
//                                Image(systemName: "xmark")
//                                    .font(.system(size: 12, weight: .semibold))
//                                    .foregroundStyle(.white)
//                                    .frame(width: 36, height: 36)
//    //                                .background(.ultraThinMaterial)
//    //                                .clipShape(Circle())
//                            }
//                            .clipShape(.circle)
                        }
                    }
            }
        }
    }
}

struct CustomBackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .foregroundStyle(.white)
                .font(.body)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
}

private struct isPadKey: EnvironmentKey {
    static let defaultValue: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

extension EnvironmentValues {
    var isPad: Bool {
        get { self[isPadKey.self] }
        set { self[isPadKey.self] = newValue }
    }
}


extension View {
    func appearAnimation(_ show: Bool) -> some View {
        self
            .opacity(show ? 1 : 0)
            .scaleEffect(show ? 1 : 0.9)
            .offset(y: show ? 0 : 15)
            .animation(.spring(response: 0.8, dampingFraction: 0.8), value: show)
    }
}

func formatTimeString(seconds: Int) -> String {
    let h = seconds / 3600
    let m = (seconds % 3600) / 60
    let s = seconds % 60
    return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
}

struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
