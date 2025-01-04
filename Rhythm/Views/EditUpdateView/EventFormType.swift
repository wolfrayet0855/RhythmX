//
//  EventFormType.swift
//

import SwiftUI

enum EventFormType: Identifiable, View {
    // case new    <-- REMOVED
    case update(Event)

    var id: String {
        switch self {
        // case .new:     return "new"
        case .update:     return "update"
        }
    }

    var body: some View {
        switch self {
        // case .new:
        //    EventFormView(viewModel: EventFormViewModel())
        case .update(let e):
            EventFormView(viewModel: EventFormViewModel(e))
        }
    }
}
