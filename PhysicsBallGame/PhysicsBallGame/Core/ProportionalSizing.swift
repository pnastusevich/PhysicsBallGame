import SwiftUI
import Foundation

struct ProportionalSizing {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    private var baseWidth: CGFloat { 375.0 }
    private var baseHeight: CGFloat { 812.0 }
    
    var widthScale: CGFloat {
        screenWidth / baseWidth
    }
    
    var heightScale: CGFloat {
        screenHeight / baseHeight
    }
    
    var scale: CGFloat {
        min(widthScale, heightScale)
    }
    
    func scaled(_ value: CGFloat) -> CGFloat {
        value * scale
    }
    
    func scaledWidth(_ value: CGFloat) -> CGFloat {
        value * widthScale
    }
    
    func scaledHeight(_ value: CGFloat) -> CGFloat {
        value * heightScale
    }
}

