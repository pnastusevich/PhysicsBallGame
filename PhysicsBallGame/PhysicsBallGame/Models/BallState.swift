import Foundation
import SwiftUI

struct BallState: Equatable {
    var position: CGPoint
    var velocity: CGVector
    var maxHeight: CGFloat
    var bounceCount: Int
    
    init(position: CGPoint = CGPoint(x: 0, y: 0), velocity: CGVector = .zero) {
        self.position = position
        self.velocity = velocity
        self.maxHeight = position.y
        self.bounceCount = 0
    }
    
    mutating func reset(to position: CGPoint) {
        self.position = position
        self.velocity = .zero
        self.maxHeight = position.y
        self.bounceCount = 0
    }
    
    static func == (lhs: BallState, rhs: BallState) -> Bool {
        lhs.position == rhs.position &&
        lhs.velocity == rhs.velocity &&
        lhs.maxHeight == rhs.maxHeight &&
        lhs.bounceCount == rhs.bounceCount
    }
}

