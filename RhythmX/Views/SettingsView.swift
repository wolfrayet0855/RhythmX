//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var archivedDataStore: ArchivedDataStore
    @State private var notificationsDenied = false

    var body: some View {
        NavigationStack {
            Form {
                phaseColorsSection
                notificationsSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Phase Colors
    private var phaseColorsSection: some View {
        Section(header: Text("Phase Colors")) {
            phaseColorRow(phase: .menstrual,  label: "Menstrual",  hex: $appSettings.phaseColor1)
            phaseColorRow(phase: .follicular, label: "Follicular", hex: $appSettings.phaseColor2)
            phaseColorRow(phase: .ovulation,  label: "Ovulation",  hex: $appSettings.phaseColor3)
            phaseColorRow(phase: .luteal,     label: "Luteal",     hex: $appSettings.phaseColor4)

            Button("Reset to Defaults") {
                appSettings.resetToDefaults()
            }
            .font(DS.Font.caption)
            .foregroundColor(.accentColor)
        }
    }

    private func phaseColorRow(
        phase: Event.EventType,
        label: String,
        hex: Binding<String>
    ) -> some View {
        HStack(spacing: DS.Spacing.md) {
            PhaseNumberBadge(phase: phase)

            Text(label)
                .font(DS.Font.label)
                .foregroundColor(DS.Color.primaryText)

            Spacer()

            ColorPicker(
                "",
                selection: Binding(
                    get: { Color(hex: hex.wrappedValue) ?? phase.defaultPhaseColor },
                    set: { hex.wrappedValue = $0.hexString }
                ),
                supportsOpacity: false
            )
            .labelsHidden()
        }
    }

    // MARK: - Notifications
    @ViewBuilder
    private var notificationsSection: some View {
        Section(header: Text("Notifications")) {
            Toggle("Cycle Reminders", isOn: $appSettings.notificationsEnabled)
                .onChange(of: appSettings.notificationsEnabled) { _, enabled in
                    handleNotificationToggle(enabled: enabled)
                }

            if appSettings.notificationsEnabled {
                Toggle("Day before", isOn: $appSettings.notifyDayBefore)
                    .font(DS.Font.label)
                    .onChange(of: appSettings.notifyDayBefore) { _, _ in reschedule() }

                Toggle("Day of", isOn: $appSettings.notifyDayOf)
                    .font(DS.Font.label)
                    .onChange(of: appSettings.notifyDayOf) { _, _ in reschedule() }

                if notificationsDenied {
                    Label("Notifications are disabled. Enable them in iOS Settings.", systemImage: "exclamationmark.triangle")
                        .font(DS.Font.caption)
                        .foregroundColor(.orange)
                }
            }
        }
    }

    // MARK: - About
    private var aboutSection: some View {
        Section(header: Text("About")) {
            NavigationLink("Getting Started") {
                GettingStartedView()
            }

            HStack {
                Text("Version")
                    .font(DS.Font.label)
                    .foregroundColor(DS.Color.primaryText)
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                    .font(DS.Font.caption)
                    .foregroundColor(DS.Color.secondaryText)
            }

            Text("All data stays on your device.")
                .font(DS.Font.caption)
                .foregroundColor(DS.Color.secondaryText)
        }
    }

    // MARK: - Notification helpers
    private func handleNotificationToggle(enabled: Bool) {
        if enabled {
            NotificationScheduler.requestPermissionIfNeeded { granted in
                if granted {
                    notificationsDenied = false
                    reschedule()
                } else {
                    notificationsDenied = true
                    appSettings.notificationsEnabled = false
                }
            }
        } else {
            NotificationScheduler.cancelAllCycleReminders()
        }
    }

    private func reschedule() {
        guard appSettings.notificationsEnabled,
              let predicted = CyclePredictionService.predictedStartDate(from: archivedDataStore.archivedBlocks)
        else { return }
        NotificationScheduler.scheduleCycleReminders(
            for: predicted,
            dayBefore: appSettings.notifyDayBefore,
            dayOf: appSettings.notifyDayOf
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
        .environmentObject(ArchivedDataStore())
}
