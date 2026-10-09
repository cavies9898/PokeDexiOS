import SwiftUI

struct RootView: View {
    let environment: AppEnvironment
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        Group {
            switch coordinator.stage {
            case .splash:
                SplashView {
                    coordinator.startMain()
                }
                .transition(.opacity)
            case .main:
                MainTabView(environment: environment, coordinator: coordinator)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.stage == .main)
    }
}

extension AppCoordinator.Stage: Equatable {}

struct BootstrapView: View {
    @State private var environment: AppEnvironment?
    @State private var coordinator: AppCoordinator?
    @State private var bootstrapError: String?
    @State private var darkMode = false

    var body: some View {
        Group {
            if let environment, let coordinator {
                RootView(environment: environment, coordinator: coordinator)
                    .preferredColorScheme(darkMode ? .dark : .light)
                    .task {
                        let stream = await environment.observeDarkMode()
                        for await enabled in stream {
                            darkMode = enabled
                        }
                    }
            } else if let bootstrapError {
                VStack(spacing: 12) {
                    Text("Error al iniciar la aplicación")
                        .font(.system(size: 16, weight: .bold))
                    Text(bootstrapError)
                        .font(.system(size: 13))
                        .foregroundColor(ThemeColors.labelGray)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
            } else {
                Color.red.ignoresSafeArea()
            }
        }
        .task {
            guard environment == nil else { return }
            do {
                let environment = try AppEnvironment()
                self.environment = environment
                let coordinator = environment.makeCoordinator()
                self.coordinator = coordinator
            } catch {
                bootstrapError = error.localizedDescription
            }
        }
    }
}
