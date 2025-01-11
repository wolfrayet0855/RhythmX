import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("didFinishOnboarding") var didFinishOnboarding = false

    var body: some View {
        // A simple multi-step or single-step onboarding
        TabView {
            // Page 1
            VStack(spacing: 20) {
                Text("Welcome to Rhythm!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)

                Text("Generate cycle events, track daily tags, and learn about phases.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Image(systemName: "circlebadge.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)

                Button("Get Started") {
                    didFinishOnboarding = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
            }
            .padding()

            // Optional: Page 2, 3, etc. if you want a multi-page onboarding
            // ...
        }
        .tabViewStyle(.page)
    }
}
