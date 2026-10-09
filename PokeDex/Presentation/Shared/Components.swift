import SwiftUI

struct StatBar: View {
    let label: String
    let value: Int
    let color: Color
    var maxValue: Int = StatPalette.maxStat

    @State private var animatedValue: Double = 0

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x555555))
                Spacer()
                Text("\(value)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(ThemeColors.ink)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ThemeColors.statTrack)
                    Capsule()
                        .fill(color)
                        .frame(width: max(0, min(1, animatedValue / Double(maxValue))) * proxy.size.width)
                }
            }
            .frame(height: 10)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7)) {
                animatedValue = Double(value)
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.easeInOut(duration: 0.7)) {
                animatedValue = Double(newValue)
            }
        }
    }
}

struct TypeChipView: View {
    let type: String
    var showBorder: Bool = false
    var textColor: Color = .white
    var backgroundColor: Color?
    var borderColor: Color?

    var body: some View {
        Text(type)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor ?? TypeColors.color(for: type))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor ?? .clear, lineWidth: showBorder ? 1 : 0)
            )
    }
}

struct SegmentedBar: View {
    let segments: [(weight: Int, color: Color)]
    var height: CGFloat = 12

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                if segment.weight > 0 {
                    segment.color
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                }
            }
        }
        .frame(height: height)
        .clipShape(Capsule())
    }
}

struct SpriteImageView: View {
    let url: String?
    var size: CGFloat

    var body: some View {
        AsyncImage(url: url.flatMap(URL.init)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            default:
                ProgressView()
                    .controlSize(.small)
            }
        }
        .frame(width: size, height: size)
    }
}
