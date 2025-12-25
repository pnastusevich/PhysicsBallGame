import Foundation

struct Experiment: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let gravity: Double
    let elasticity: Double
    let mass: Double
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        gravity: Double,
        elasticity: Double,
        mass: Double
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.gravity = gravity
        self.elasticity = elasticity
        self.mass = mass
    }
    
    static let moonGravity = Experiment(
        name: "Moon Gravity",
        description: "Low gravity environment like the moon",
        gravity: 1.6,
        elasticity: 0.7,
        mass: 1.0
    )
    
    static let marsGravity = Experiment(
        name: "Mars Gravity",
        description: "Red planet with moderate gravity",
        gravity: 3.7,
        elasticity: 0.7,
        mass: 1.0
    )
    
    static let venusGravity = Experiment(
        name: "Venus Gravity",
        description: "Similar to Earth but with extreme atmosphere",
        gravity: 8.9,
        elasticity: 0.7,
        mass: 1.0
    )
    
    static let jupiterGravity = Experiment(
        name: "Jupiter Gravity",
        description: "Gas giant with very strong gravity",
        gravity: 24.8,
        elasticity: 0.7,
        mass: 1.0
    )
    
    static let sunGravity = Experiment(
        name: "Sun Gravity",
        description: "Extreme gravity of our star",
        gravity: 274.0,
        elasticity: 0.7,
        mass: 1.0
    )
    
    static let mercuryGravity = Experiment(
        name: "Mercury Gravity",
        description: "Smallest planet, weak gravity",
        gravity: 3.7,
        elasticity: 0.7,
        mass: 1.0
    )
    
    static let saturnGravity = Experiment(
        name: "Saturn Gravity",
        description: "Ringed planet with strong gravity",
        gravity: 10.4,
        elasticity: 0.7,
        mass: 1.0
    )
    
    static let earthGravity = Experiment(
        name: "Earth Gravity",
        description: "Standard Earth gravity",
        gravity: 9.8,
        elasticity: 0.7,
        mass: 1.0
    )
    
    static let rubberBall = Experiment(
        name: "Rubber Ball",
        description: "Highly elastic rubber material",
        gravity: 9.8,
        elasticity: 0.9,
        mass: 0.3
    )
    
    static let plasticBall = Experiment(
        name: "Plastic Ball",
        description: "Lightweight plastic with moderate bounce",
        gravity: 9.8,
        elasticity: 0.6,
        mass: 0.2
    )
    
    static let metalBall = Experiment(
        name: "Metal Ball",
        description: "Heavy metal with low elasticity",
        gravity: 9.8,
        elasticity: 0.2,
        mass: 8.0
    )
    
    static let glassBall = Experiment(
        name: "Glass Ball",
        description: "Fragile glass with high elasticity but heavy",
        gravity: 9.8,
        elasticity: 0.85,
        mass: 2.5
    )
    
    static let woodBall = Experiment(
        name: "Wood Ball",
        description: "Natural wood with low bounce",
        gravity: 9.8,
        elasticity: 0.4,
        mass: 0.8
    )
    
    static let foamBall = Experiment(
        name: "Foam Ball",
        description: "Ultra-light foam with minimal bounce",
        gravity: 9.8,
        elasticity: 0.3,
        mass: 0.1
    )
    
    static let steelBall = Experiment(
        name: "Steel Ball",
        description: "Dense steel with very low elasticity",
        gravity: 9.8,
        elasticity: 0.15,
        mass: 10.0
    )
    
    static let superBall = Experiment(
        name: "Super Ball",
        description: "Highly elastic ball with high bounce",
        gravity: 9.8,
        elasticity: 0.95,
        mass: 0.5
    )
    
    static let heavyBall = Experiment(
        name: "Heavy Ball",
        description: "Heavy ball with low elasticity",
        gravity: 9.8,
        elasticity: 0.3,
        mass: 5.0
    )
    
    static let allExperiments: [Experiment] = [
        // Planetary gravities
        moonGravity,
        marsGravity,
        venusGravity,
        jupiterGravity,
        sunGravity,
        mercuryGravity,
        saturnGravity,
        earthGravity,
        // Material types
        rubberBall,
        plasticBall,
        metalBall,
        glassBall,
        woodBall,
        foamBall,
        steelBall,
        superBall,
        heavyBall
    ]
}

