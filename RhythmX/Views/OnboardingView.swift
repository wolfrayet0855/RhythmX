//  OnboardingView.swift
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var myEvents: EventStore
    @AppStorage("didFinishOnboarding") var didFinishOnboarding = false
    @AppStorage("selectedTab") var selectedTab = 0

    // Toggling this to true will push GettingStartedView onto this NavStack
    @State private var navigateToGetStarted = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to Rhythm(x)!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)

                Text("Generate cycle events, track tags, and learn about phases.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // High energy note about data privacy
                Text("Your privacy rocks – we NEVER collect your data! Let's keep your rhythm free and safe!")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Image(systemName: "circlebadge.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .padding(.bottom, 24)

                // "Continue" goes to GettingStartedView (back button is not hidden)
                Button("Continue") {
                    navigateToGetStarted = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
            }
            .padding()
    
            // A "Skip" or "Done" approach in the top-right, if user doesn't want to see steps
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        // Let user skip everything, set onboarding done,
                        // and jump them to the Settings tab if you like
                        selectedTab = 2
                        didFinishOnboarding = true
                    }
                }
            }
            // Push to GettingStartedView
            .navigationDestination(isPresented: $navigateToGetStarted) {
                GettingStartedView()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(EventStore())
    }
}
