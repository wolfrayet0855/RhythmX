//  PredictionBannerView.swift

import SwiftUI

struct PredictionBannerView: View {
    let daysUntil: Int

    private var message: String {
        switch daysUntil {
        case 0:  return "Cycle anticipated to start today."
        case 1:  return "Cycle anticipated to start tomorrow."
        default: return "Cycle anticipated to start in \(daysUntil) days."
        }
    }

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Event.EventType.menstrual.phaseColor)
                .frame(width: 4)

            Image(systemName: "calendar.badge.clock")
                .foregroundColor(Event.EventType.menstrual.phaseColor)

            Text(message)
                .font(DS.Font.label)
                .foregroundColor(DS.Color.primaryText)

            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(DS.Color.cardBackground)
        .cornerRadius(DS.Radius.card)
        .padding(.horizontal, DS.Spacing.md)
        .padding(.top, DS.Spacing.sm)
    }
}

#Preview {
    VStack {
        PredictionBannerView(daysUntil: 0)
        PredictionBannerView(daysUntil: 1)
        PredictionBannerView(daysUntil: 3)
    }
    .padding()
}
