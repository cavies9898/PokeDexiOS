import Foundation

struct Categories: Sendable {
    let type: [String]
    let generation: [String]
    let region: [String]
    let habitat: [String]
    let color: [String]
    let shape: [String]

    init(
        type: [String] = [],
        generation: [String] = [],
        region: [String] = [],
        habitat: [String] = [],
        color: [String] = [],
        shape: [String] = []
    ) {
        self.type = type
        self.generation = generation
        self.region = region
        self.habitat = habitat
        self.color = color
        self.shape = shape
    }
}
