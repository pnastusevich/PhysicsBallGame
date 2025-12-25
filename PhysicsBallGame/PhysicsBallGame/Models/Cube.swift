import Foundation
import SwiftUI

struct Cube: Identifiable {
    let id: UUID
    var position: CGPoint
    let width: CGFloat
    let height: CGFloat
    var velocity: CGFloat
    
    init(id: UUID = UUID(), position: CGPoint, width: CGFloat, height: CGFloat, velocity: CGFloat = 100.0) {
        self.id = id
        self.position = position
        self.width = width
        self.height = height
        self.velocity = velocity
    }
}

