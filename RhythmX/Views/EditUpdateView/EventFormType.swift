//
//  EventFormType.swift
//

import SwiftUI

enum EventFormType: Identifiable, View {
    // case new    <-- REMOVED
    case update(Event)

    var id: String {
        switch self {
        case .update:
            return "update"
        }
    }

    var body: some View {
        switch self {
        case .update(let e):
            EventFormView(viewModel: EventFormViewModel(e))
        }
    }
}
