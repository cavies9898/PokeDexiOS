import SwiftUI

struct GradientHeader<Content: View>: View {
    var gradient: LinearGradient
    var bottomRadius: CGFloat = 60
    var padding: EdgeInsets = EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .padding(padding)
            .background(
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 0,
                        bottomLeading: bottomRadius,
                        bottomTrailing: bottomRadius,
                        topTrailing: 0
                    ),
                    style: .continuous
                )
                .fill(gradient)
                .ignoresSafeArea(edges: .top)
            )
    }
}

struct GradientCardHeader<Content: View>: View {
    var gradient: LinearGradient = LinearGradient(
        colors: [ThemeColors.skyBlue, ThemeColors.appBlue],
        startPoint: .leading,
        endPoint: .trailing
    )
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(gradient)
            )
            .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
    }
}
