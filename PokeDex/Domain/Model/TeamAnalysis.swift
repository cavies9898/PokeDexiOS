import Foundation

struct TypeCount: Hashable, Sendable {
    let name: String
    let count: Int
}

struct TeamAnalysis: Sendable {
    let memberCount: Int
    let averageScore: Int
    let scoreRatio: Double
    let physicalCount: Int
    let specialCount: Int
    let fastCount: Int
    let mediumCount: Int
    let slowCount: Int
    let typeCounts: [TypeCount]
    let defensiveCount: Int
    let strengths: [String]
    let weaknesses: [String]

    init(
        memberCount: Int = 0,
        averageScore: Int = 0,
        scoreRatio: Double = 0.0,
        physicalCount: Int = 0,
        specialCount: Int = 0,
        fastCount: Int = 0,
        mediumCount: Int = 0,
        slowCount: Int = 0,
        typeCounts: [TypeCount] = [],
        defensiveCount: Int = 0,
        strengths: [String] = [],
        weaknesses: [String] = []
    ) {
        self.memberCount = memberCount
        self.averageScore = averageScore
        self.scoreRatio = scoreRatio
        self.physicalCount = physicalCount
        self.specialCount = specialCount
        self.fastCount = fastCount
        self.mediumCount = mediumCount
        self.slowCount = slowCount
        self.typeCounts = typeCounts
        self.defensiveCount = defensiveCount
        self.strengths = strengths
        self.weaknesses = weaknesses
    }
}
