import SwiftUI

struct TeamRadarChart: View {
    let averages: [Int]
    var height: CGFloat = 260

    private var maxValue: Int {
        let rawMax = averages.max() ?? 0
        return max(150, ((rawMax + 49) / 50) * 50)
    }

    private var steps: Int {
        maxValue / 50
    }

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let labelRadius = min(size.width * 0.45, size.height * 0.42)
            let radius = labelRadius * 0.80
            let angle = Double.pi * 2 / 6

            let gridColor = ThemeColors.ink.opacity(0.12)

            for ring in 1...max(steps, 1) {
                let ringRadius = radius * CGFloat(ring) / CGFloat(max(steps, 1))
                var path = Path()
                for index in 0..<6 {
                    let vertex = point(center: center, radius: ringRadius, index: index, angle: angle)
                    if index == 0 {
                        path.move(to: vertex)
                    } else {
                        path.addLine(to: vertex)
                    }
                }
                path.closeSubpath()
                context.stroke(path, with: .color(gridColor), lineWidth: 1.4)
            }

            for index in 0..<6 {
                let vertex = point(center: center, radius: radius, index: index, angle: angle)
                var spoke = Path()
                spoke.move(to: center)
                spoke.addLine(to: vertex)
                context.stroke(spoke, with: .color(gridColor), lineWidth: 1.2)
            }

            var dataPath = Path()
            for index in 0..<averages.count {
                let fraction = Double(averages[index]) / Double(maxValue)
                let vertex = point(
                    center: center,
                    radius: radius * CGFloat(min(fraction, 1.0)),
                    index: index,
                    angle: angle
                )
                if index == 0 {
                    dataPath.move(to: vertex)
                } else {
                    dataPath.addLine(to: vertex)
                }
            }
            dataPath.closeSubpath()
            context.fill(dataPath, with: .color(ThemeColors.appBlue.opacity(0.28)))
            context.stroke(dataPath, with: .color(ThemeColors.appBlue), lineWidth: 3)

            for ring in 1...max(steps, 1) {
                let ringRadius = radius * CGFloat(ring) / CGFloat(max(steps, 1))
                let text = Text("\(ring * 50)")
                    .font(.system(size: 10))
                    .foregroundColor(ThemeColors.labelGray)
                context.draw(
                    text,
                    at: CGPoint(x: center.x + 7, y: center.y - ringRadius + 7),
                    anchor: .topLeading
                )
            }

            for index in 0..<StatPalette.radarLabels.count {
                let labelPoint = point(center: center, radius: labelRadius, index: index, angle: angle)
                let label = Text(StatPalette.radarLabels[index])
                    .font(.system(size: 11))
                    .foregroundColor(ThemeColors.labelGray)
                context.draw(label, at: CGPoint(x: labelPoint.x, y: labelPoint.y + 9), anchor: .center)
            }
        }
        .frame(height: height)
    }

    private func point(center: CGPoint, radius: CGFloat, index: Int, angle: Double) -> CGPoint {
        let vertexAngle = angle * Double(index) - Double.pi / 2
        return CGPoint(
            x: center.x + radius * cos(vertexAngle),
            y: center.y + radius * sin(vertexAngle)
        )
    }
}
