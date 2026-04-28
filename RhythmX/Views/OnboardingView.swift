//  OnboardingView.swift

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var myEvents: EventStore
    @AppStorage("didFinishOnboarding") var didFinishOnboarding = false
    @AppStorage("selectedTab") var selectedTab = 0

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer()

            Image(systemName: "circle.hexagongrid.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 72)
                .foregroundColor(.accentColor)

            Text("Rhythm(x)")
                .font(DS.Font.displayTitle)
                .foregroundColor(DS.Color.primaryText)

            Text("Track your cycle phases, add personal notes, and spot patterns in your health over time.")
                .font(DS.Font.body)
                .foregroundColor(DS.Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Spacing.xl)

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                featureRow(icon: "calendar.badge.plus", text: "Auto-generate phase events")
                featureRow(icon: "tag",                  text: "Add custom tags to any day")
                featureRow(icon: "chart.bar",            text: "Archive and review past cycles")
            }
            .padding(.horizontal, DS.Spacing.xl)

            Spacer()

            VStack(spacing: DS.Spacing.sm) {
                PrimaryButton(title: "Get Started") {
                    didFinishOnboarding = true
                    selectedTab = 2
                }

                SecondaryButton(title: "Skip") {
                    didFinishOnboarding = true
                    selectedTab = 2
                }
            }
            .padding(.horizontal, DS.Spacing.md)

            Text("Your data never leaves your device.")
                .font(DS.Font.micro)
                .foregroundColor(DS.Color.tertiaryText)
                .padding(.bottom, DS.Spacing.md)
        }
        .background(DS.Color.pageBackground.ignoresSafeArea())
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: DS.Spacing.lg)
            Text(text)
                .font(DS.Font.label)
                .foregroundColor(DS.Color.primaryText)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(EventStore())
}
