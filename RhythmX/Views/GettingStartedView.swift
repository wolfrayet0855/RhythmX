//  GettingStartedView.swift

import SwiftUI

struct GettingStartedView: View {
    @AppStorage("didFinishOnboarding") var didFinishOnboarding = false
    @Environment(\.dismiss) private var dismiss

    private let steps: [(String, String)] = [
        ("Generate Cycle Events",
         "In Manage, tap 'Generate Cycle Events' to populate your calendar with phase events for your chosen cycle length."),
        ("Add Tags",
         "Use the List tab to add tags (e.g., Dietary, Mood). Tap the + button to attach a tag to a date."),
        ("Check Calendar",
         "In the Calendar tab, see your phases and events. Tap a date to view or edit tags."),
        ("Archive Data",
         "Each month in Manage, archive your previous data and generate new events. Use the Archive Data view to explore trends."),
        ("Learn More",
         "In Manage, open 'Menstrual Phases Info' for details on each phase.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: DS.Spacing.sm) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Color.accentColor)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.0)
                                .font(DS.Font.label.weight(.semibold))
                                .foregroundColor(DS.Color.primaryText)
                            Text(step.1)
                                .font(DS.Font.caption)
                                .foregroundColor(DS.Color.secondaryText)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.vertical, DS.Spacing.sm)
                    .background(DS.Color.cardBackground)
                    .cornerRadius(DS.Radius.card)
                }
            }
            .padding(DS.Spacing.md)
        }
        .background(DS.Color.pageBackground.ignoresSafeArea())
        .navigationTitle("Getting Started")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    didFinishOnboarding = true
                    dismiss()
                }
                .font(DS.Font.label.weight(.semibold))
            }
        }
    }
}

#Preview {
    NavigationStack {
        GettingStartedView()
    }
}
