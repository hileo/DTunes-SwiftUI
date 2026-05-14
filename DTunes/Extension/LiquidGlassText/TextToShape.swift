//
//  TextToShape.swift
//  kelly
//
//  Created by OllyWang on 2/11/26.
//

import SwiftUI

@available(iOS 26.0, *)
struct GlassEffectText: View {
    var text: String
    var font: UIFont
    var fallbackColor: Color = .primary
    var isClear: Bool = true
    var glassTint: Color = .clear
    
    var body: some View {
        let textShape = TextToShape(value: text, font: font)
        
        Text(text)
            .font(Font(font))
            .monospacedDigit()
            .preferredColorScheme(.light)
            .opacity(0)
            .glassEffect((isClear ? Glass.clear : Glass.regular).tint(glassTint), in: textShape)
            .shadow(color: .black.opacity(0.4),
                    radius: 12,
                    x: 6,
                    y: 8)
     }
}

// Text-To-Shape
struct TextToShape: Shape {
    var value: String
    var font: UIFont
    
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        font.drawGlyphs(value) { position, glyphPath in
            // Call to main actor-isolated instance method
            let transform = CGAffineTransform(translationX: position.x, y: position.y)
                .scaledBy(x: 1, y: -1)
            let newPath = Path(glyphPath).applying(transform)
            // Adding it to the main Path
            path.addPath(newPath)
        }
        
        // Centering to the current bounds
        let bounds = path.boundingRect
        let offsetX = rect.midX - bounds.midX
        let offsetY = rect.midY - bounds.midY
        let centerTransform = CGAffineTransform(translationX: offsetX, y: offsetY)

        return path.applying(centerTransform)
    }
}

extension UIFont {
    nonisolated
    var ctFont: CTFont {
        let descriptor = self.fontDescriptor
        return CTFontCreateWithFontDescriptor(descriptor, 0, nil)
    }
    nonisolated
    // Converting Font into a NSAttributedString with the given value
    func toNSAttributedString(_ value: String) -> NSAttributedString {
        return NSAttributedString(string: value, attributes: [.font: self])
    }
    
    // Calculating TextSize for the given font
    func toSize(_ value: String) -> CGSize {
        return NSString(string: value).size(withAttributes: [.font: self])
    }
    
    nonisolated
    // Return's Each Individual Glyph Path from the given text using the current font (Can be used to Draw Text as Path)
    func drawGlyphs(_ value: String, draw: @escaping (_ position: CGPoint, _ glyphPath: CGPath) -> ()) {
        let ctFont = self.ctFont
        let attributedString = self.toNSAttributedString(value)
        // Extracting Lines & Runs from the Attributed String using CoreText APIs
        let lines = CTLineCreateWithAttributedString(attributedString)
        let runs = CTLineGetGlyphRuns(lines)
        
        for runIndex in 0..<CFArrayGetCount(runs) {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, runIndex), to: CTRun.self)
            let runCount = CTRunGetGlyphCount(run)
            
            // Iterating Run and drawing Each Glyph
            for index in 0..<runCount {
                let range = CFRangeMake(index, 1)
                var glyph = CGGlyph()
                var position = CGPoint()
                
                // Extracting Values
                CTRunGetGlyphs(run, range, &glyph)
                CTRunGetPositions(run, range, &position)
                
                if let glyphPath = CTFontCreatePathForGlyph(ctFont, glyph, nil) {
                    // Passing to draw!
                    draw(position, glyphPath)
                }
            }
        }
    }
    
}

#Preview {
    ZStack {
        Rectangle()
            .foregroundStyle(.clear)
            .overlay {
                Image("DefaultIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                if #available(iOS 26.0, *) {
                    GlassEffectText(text: "12:41", font: .systemFont(ofSize: 200, weight: .bold, width: .compressed), glassTint: .black.opacity(0.4))
                } else {
                    // Fallback on earlier versions
                }
                
//                GlassEffectText(text: "09:41", font: .monospacedDigitSystemFont(ofSize: 120, weight: .bold), glassTint: .white.opacity(0.2))
            }
    }
}
