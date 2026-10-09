import Foundation

let statCount = 6
let maxTeamScore = 600

enum Role: String, CaseIterable, Identifiable, Sendable {
    case tank
    case fast
    case physical
    case special
    case balanced

    var id: String { rawValue }

    var label: String {
        switch self {
        case .tank: "Tanque"
        case .fast: "Veloz"
        case .physical: "Atacante físico"
        case .special: "Atacante especial"
        case .balanced: "Equilibrado"
        }
    }
}

struct StatLeader: Sendable {
    let value: Int
    let pokemon: Pokemon
}

struct RoleGroup: Sendable {
    let role: Role
    let members: [Pokemon]
}

struct TeamStatsSummary: Sendable {
    let memberCount: Int
    let averageTotal: Int
    let averages: [Int]
    let leaders: [StatLeader]
    let ranking: [Pokemon]
    let roles: [RoleGroup]

    init(
        memberCount: Int = 0,
        averageTotal: Int = 0,
        averages: [Int] = [],
        leaders: [StatLeader] = [],
        ranking: [Pokemon] = [],
        roles: [RoleGroup] = []
    ) {
        self.memberCount = memberCount
        self.averageTotal = averageTotal
        self.averages = averages
        self.leaders = leaders
        self.ranking = ranking
        self.roles = roles
    }
}
