import Foundation

struct TeamCoverage: Sendable {
    let memberCount: Int
    let rows: [TypeCoverageRow]

    init(memberCount: Int = 0, rows: [TypeCoverageRow] = []) {
        self.memberCount = memberCount
        self.rows = rows
    }

    var resistedCount: Int { rows.filter { $0.score > 0 }.count }
    var weakCount: Int { rows.filter { $0.score < 0 }.count }
    var globalScore: Int { rows.reduce(0) { $0 + $1.score } }
    var isEmpty: Bool { memberCount == 0 || rows.isEmpty }
}

struct TypeCoverageRow: Hashable, Sendable {
    let type: String
    let resistant: Int
    let weak: Int
    let neutral: Int

    var score: Int { resistant - weak }
}
