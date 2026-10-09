import SwiftUI

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let mainColor: Color
    var trailingText: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(mainColor.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(mainColor)
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ThemeColors.ink)
                Spacer()
                if let trailingText {
                    AccentPill(text: trailingText, color: mainColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            Rectangle()
                .fill(ThemeColors.divider)
                .frame(height: 1)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            content()
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

struct AccentPill: View {
    let text: String
    let color: Color
    var fontSize: CGFloat = 12

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .heavy))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.12)))
    }
}

struct GroupLabel: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(color)
    }
}
