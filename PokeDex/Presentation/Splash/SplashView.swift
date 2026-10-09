import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var spin = false
    @State private var bounce = false

    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()

            VStack(spacing: 16) {
                PokeballShape()
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(spin ? 360 : 0))
                    .scaleEffect(bounce ? 1.08 : 0.92)

                Text("PokéDex")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                Text("¡Atrápalos a todos!")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                bounce = true
            }
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                spin = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                onFinished()
            }
        }
    }
}

struct PokeballShape: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: 150, height: 150)
                .mask(
                    VStack(spacing: 0) {
                        Color.black.frame(height: 75)
                        Color.clear.frame(height: 75)
                    }
                )
            Circle()
                .fill(Color.white)
                .frame(width: 150, height: 150)
                .mask(
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 75)
                        Color.black.frame(height: 75)
                    }
                )
            Rectangle()
                .fill(Color.black)
                .frame(height: 12)
            Circle()
                .fill(Color.white)
                .frame(width: 56, height: 56)
                .overlay(Circle().stroke(Color.black, lineWidth: 8))
            Circle()
                .fill(Color.white)
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(Color.black, lineWidth: 6))
        }
        .clipShape(Circle())
    }
}
