//  ListViewRow.swift

import SwiftUI

struct ListViewRow: View {
    let event: Event

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            PhaseNumberBadge(phase: event.eventType)

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(event.eventType.displayName)
                    .font(DS.Font.label.weight(.semibold))
                    .foregroundColor(DS.Color.primaryText)

                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(DS.Font.caption)
                    .foregroundColor(DS.Color.secondaryText)

                if !event.tags.isEmpty {
                    Text("Tags: \(event.tags)")
                        .font(DS.Font.caption)
                        .foregroundColor(.accentColor)
                }
            }

            Spacer()
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}
