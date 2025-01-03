//
//  PhasesFactsView.swift
//  Rhythm
//
//  Created by user on 1/3/25.
//
import SwiftUI

struct PhaseFact: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let detail: String
}

struct PhasesFacts {
    static let all: [PhaseFact] = [
        PhaseFact(
            name: "Menstrual",
            icon: "❶",
            detail: """
            The menstrual phase starts on the first day of bleeding. Hormone levels are low, and the uterine lining is shed.
            """
        ),
        PhaseFact(
            name: "Follicular",
            icon: "❷",
            detail: """
            During the follicular phase, the pituitary gland releases FSH, stimulating follicles in the ovaries to mature.
            Estrogen levels rise, preparing the uterus lining for a potential pregnancy.
            """
        ),
        PhaseFact(
            name: "Ovulation",
            icon: "❸",
            detail: """
            Ovulation typically occurs mid-cycle when a surge in LH (Luteinizing Hormone) causes a mature egg to release
            from the ovary. This is the most fertile time of the cycle.
            """
        ),
        PhaseFact(
            name: "Luteal",
            icon: "❹",
            detail: """
            After ovulation, the luteal phase begins. The corpus luteum forms and secretes progesterone,
            thickening the uterine lining. If the egg isn't fertilized, hormone levels drop.
            """
        ),
        PhaseFact(
            name: "Introspection",
            icon: "☪︎",
            detail: """
            This is sometimes used as a reflective or “inward” phase, focusing on self-care. 
            Though not always part of standard medical definitions, many find it helpful as a time to rest and reflect.
            """
        )
    ]
}

struct PhasesFactsView: View {
    var body: some View {
        NavigationStack {
            List(PhasesFacts.all) { fact in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(fact.icon)
                            .font(.title2)
                            .padding(.trailing, 4)
                        Text(fact.name)
                            .font(.headline)
                    }
                    Text(fact.detail)
                        .font(.body)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Menstrual Phases")
        }
    }
}

struct PhasesFactsView_Previews: PreviewProvider {
    static var previews: some View {
        PhasesFactsView()
    }
}


