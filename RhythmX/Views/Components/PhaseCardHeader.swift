//  PhaseCardHeader.swift

import SwiftUI

struct PhaseCardHeader: View {
    let phase: Event.EventType
    let startDate: Date
    let endDate: Date

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(phase.phaseColor)
                .frame(width: 4, height: 36)

            PhaseNumberBadge(phase: phase)

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(phase.displayName)
                    .font(DS.Font.sectionHeader)
                    .foregroundColor(DS.Color.primaryText)

                Text(
                    startDate.formatted(date: .abbreviated, time: .omitted)
                    + " – "
                    + endDate.formatted(date: .abbreviated, time: .omitted)
                )
                .font(DS.Font.caption)
                .foregroundColor(DS.Color.secondaryText)
            }

            Spacer()
        }
        .padding(.vertical, DS.Spacing.xs)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(phase.displayName), \(startDate.formatted(date: .abbreviated, time: .omitted)) to \(endDate.formatted(date: .abbreviated, time: .omitted))")
    }
}

#Preview {
    List {
        Section {
            Text("Event row")
        } header: {
            PhaseCardHeader(
                phase: .menstrual,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 5)
            )
        }
    }
}
