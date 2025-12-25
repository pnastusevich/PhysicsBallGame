import Foundation
import SwiftUI

struct PhysicsEngine {
    let config: PhysicsConfig
    
    private let pixelsPerMeter: CGFloat = 150.0
    
    func updateBall(
        position: CGPoint,
        velocity: CGVector,
        floorY: CGFloat,
        deltaTime: TimeInterval,
        leftBound: CGFloat? = nil,
        rightBound: CGFloat? = nil,
        ballRadius: CGFloat = 15.0
    ) -> (position: CGPoint, velocity: CGVector) {
        var newPosition = position
        var newVelocity = velocity
        
        let clampedDeltaTime = min(deltaTime, 0.1)
        
        let gravityPxPerS2 = CGFloat(config.gravity) * pixelsPerMeter
        
        newVelocity.dy += gravityPxPerS2 * CGFloat(clampedDeltaTime)
        
        newPosition.x += newVelocity.dx * CGFloat(clampedDeltaTime)
        newPosition.y += newVelocity.dy * CGFloat(clampedDeltaTime)
        
        if let left = leftBound {
            if newPosition.x - ballRadius < left {
                newPosition.x = left + ballRadius
                
                newVelocity.dx = -newVelocity.dx * CGFloat(config.elasticity)
                
                let massEnergyLoss = 1.0 - (config.mass * 0.02)
                newVelocity.dx *= max(0.5, massEnergyLoss)
                
                let wallFriction = 0.95
                newVelocity.dy *= CGFloat(wallFriction)
                
                if abs(newVelocity.dx) < 0.5 {
                    newVelocity.dx = 0
                }
                
                if abs(newVelocity.dy) < 0.1 && abs(newVelocity.dx) < 0.5 {
                    newVelocity.dy = 0
                }
            }
        }
        
        if let right = rightBound {
            if newPosition.x + ballRadius > right {
                newPosition.x = right - ballRadius
                
                newVelocity.dx = -newVelocity.dx * CGFloat(config.elasticity)
                
                let massEnergyLoss = 1.0 - (config.mass * 0.02)
                newVelocity.dx *= max(0.5, massEnergyLoss)
                
                let wallFriction = 0.95
                newVelocity.dy *= CGFloat(wallFriction)
                
                if abs(newVelocity.dx) < 0.5 {
                    newVelocity.dx = 0
                }
                
                if abs(newVelocity.dy) < 0.1 && abs(newVelocity.dx) < 0.5 {
                    newVelocity.dy = 0
                }
            }
        }
        
        if newPosition.y + ballRadius >= floorY {
            newPosition.y = floorY - ballRadius
            
            newVelocity.dy = -newVelocity.dy * CGFloat(config.elasticity)
            
            let massEnergyLoss = 1.0 - (config.mass * 0.02)
            newVelocity.dy *= max(0.5, massEnergyLoss)
            
            if abs(newVelocity.dy) < 1.0 {
                newVelocity.dy = 0
            }
        }
        
        return (newPosition, newVelocity)
    }
    
    func calculateMaxHeight(currentHeight: CGFloat, maxHeight: CGFloat) -> CGFloat {
        return max(currentHeight, maxHeight)
    }
}

