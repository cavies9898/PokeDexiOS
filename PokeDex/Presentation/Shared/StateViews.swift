import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Descargando datos, por favor espera...")
                .font(.system(size: 14))
                .foregroundColor(ThemeColors.labelGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeColors.screenBackground)
    }
}

struct ErrorContentView: View {
    let message: String
    var onRetry: (() -> Void)?
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            if onRetry != nil || onBack != nil {
                HStack(spacing: 12) {
                    if let onRetry {
                        Button("Reintentar", action: onRetry)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(ThemeColors.appBlue)
                    }
                    if let onBack {
                        Button("Volver", action: onBack)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(ThemeColors.labelGray)
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeColors.screenBackground)
    }
}

struct EmptyStateCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(iconColor)
            }
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(ThemeColors.ink)
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(ThemeColors.labelGray)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}
