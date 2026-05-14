import SwiftUI

import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var blinkSpeed: Double
    var phaseOffset: Double
    var blurRadius: CGFloat // 新增：每个粒子特有的模糊程度
}

struct StarryBackground: View {
    @State private var particles: [Particle] = (0..<230).map { _ in createParticle() }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                
                for particle in particles {
                    let elapsed = now * particle.speed
                    let yPos = (particle.y - CGFloat(elapsed)).truncatingRemainder(dividingBy: size.height)
                    let finalY = yPos < 0 ? yPos + size.height : yPos
                    
                    let blink = sin(now * particle.blinkSpeed + particle.phaseOffset)
                    let dynamicOpacity = (blink + 1) / 2 * particle.opacity
                    
                    // --- 关键修改：使用 drawLayer 隔离滤镜 ---
                    context.drawLayer { localContext in
                        let rect = CGRect(x: particle.x * size.width, y: finalY, width: particle.size, height: particle.size)
                        
                        // 设置当前粒子的专属模糊度
                        if particle.blurRadius > 0 {
                            localContext.addFilter(.blur(radius: particle.blurRadius))
                        }
                        
                        localContext.opacity = dynamicOpacity
                        localContext.fill(Path(ellipseIn: rect), with: .color(.white))
                    }
                }
            }
        }
//        .background(.black)
        .ignoresSafeArea()
    }
    
    static func createParticle() -> Particle {
        Particle(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1000),
            size: CGFloat.random(in: 1...2), // 星星小一点更精致
            speed: CGFloat.random(in: 6...40),
            opacity: Double.random(in: 0.4...1.0),
            // --- 随机闪烁参数 ---
            blinkSpeed: Double.random(in: 1.0...4.0),
            phaseOffset: Double.random(in: 0...Double.pi * 2),
            blurRadius: CGFloat.random(in: 0...1.5)
        )
    }
}

#Preview {
    StarryBackground()
}
