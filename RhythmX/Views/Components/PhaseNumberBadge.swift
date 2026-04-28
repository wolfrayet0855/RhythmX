//  PhaseNumberBadge.swift

import SwiftUI

struct PhaseNumberBadge: View {
    let phase: Event.EventType

    var body: some View {
        Text("\(phase.phaseNumber)")
            .font(DS.Font.label.weight(.bold))
            .foregroundColor(.white)
            .minimumScaleFactor(0.7)
            .frame(width: DS.Spacing.lg, height: DS.Spacing.lg)
            .background(phase.phaseColor)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: DS.Spacing.sm) {
        ForEach(Event.EventType.allCases, id: \.self) { phase in
            PhaseNumberBadge(phase: phase)
        }
    }
    .padding()
}
