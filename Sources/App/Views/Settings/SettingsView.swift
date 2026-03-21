import SwiftUI

#if ENABLE_SPARKLE
struct SettingsView: View {
    @Environment(\.sparkleUpdater) private var sparkleUpdater
    @State private var settings = AppSettings.shared

    var body: some View {
        UpdatesSettingsView(sparkleUpdater: sparkleUpdater, settings: settings)
            .frame(width: 450, height: 320)
    }
}

// MARK: - Updates Settings View

struct UpdatesSettingsView: View {
    let sparkleUpdater: SparkleUpdater?
    @Bindable var settings: AppSettings

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(DS.Colors.accent)

                Text("Updates")
                    .font(DS.Typography.sidebarHeader)
                    .foregroundStyle(DS.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .overlay(alignment: .bottom) {
                Divider().overlay(DS.Colors.border)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Software Update section
                    settingsSection("Software Update") {
                        if sparkleUpdater?.isAvailable == true {
                            // Check for Updates
                            HStack {
                                Button {
                                    sparkleUpdater?.checkForUpdates()
                                } label: {
                                    HStack(spacing: 6) {
                                        if sparkleUpdater?.isCheckingForUpdates == true {
                                            ProgressView()
                                                .scaleEffect(0.6)
                                                .frame(width: 14, height: 14)
                                        } else {
                                            Image(systemName: "arrow.clockwise")
                                                .font(.system(size: 11))
                                        }

                                        Text(sparkleUpdater?.isCheckingForUpdates == true ? "Checking..." : "Check for Updates")
                                            .font(DS.Typography.body)
                                    }
                                    .foregroundStyle(DS.Colors.textPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(DS.Colors.bgInput)
                                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DS.Radius.sm)
                                            .stroke(DS.Colors.border, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(sparkleUpdater?.canCheckForUpdates != true || sparkleUpdater?.isCheckingForUpdates == true)

                                Spacer()

                                TagChip.version(appVersion)
                            }

                            // Last check
                            if let lastCheck = sparkleUpdater?.lastUpdateCheckDate {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 9))
                                    Text("Last checked: \(lastCheck.formatted(date: .abbreviated, time: .shortened))")
                                        .font(DS.Typography.caption)
                                }
                                .foregroundStyle(DS.Colors.textMuted)
                            }

                            // Update available
                            if sparkleUpdater?.isUpdateAvailable == true,
                               let version = sparkleUpdater?.availableVersion {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(DS.Colors.green)

                                    Text("Version \(version) is available")
                                        .font(DS.Typography.body)
                                        .foregroundStyle(DS.Colors.textPrimary)

                                    Spacer()

                                    Button {
                                        sparkleUpdater?.checkForUpdates()
                                    } label: {
                                        Text("Update Now")
                                            .font(DS.Typography.body)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 6)
                                            .background(DS.Colors.green)
                                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(12)
                                .background(Color(hex: 0x22C55E).opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "hammer.fill")
                                    .font(.system(size: 11))
                                Text("Updates unavailable in debug builds")
                                    .font(DS.Typography.body)
                            }
                            .foregroundStyle(DS.Colors.textMuted)
                        }
                    }

                    // Preferences section
                    settingsSection("Preferences") {
                        // Auto check toggle
                        settingsToggle(
                            isOn: Binding(
                                get: { sparkleUpdater?.automaticallyChecksForUpdates ?? true },
                                set: { sparkleUpdater?.automaticallyChecksForUpdates = $0 }
                            ),
                            title: "Check for updates automatically",
                            isDisabled: sparkleUpdater?.isAvailable != true
                        )

                        Divider().overlay(DS.Colors.border)

                        // Beta toggle
                        settingsToggle(
                            isOn: $settings.receiveBetaUpdates,
                            title: "Include beta versions",
                            subtitle: "Get early access to new features",
                            isDisabled: sparkleUpdater?.isAvailable != true
                        )
                    }
                }
                .padding(24)
            }
        }
        .background(DS.Colors.bgPrimary)
        .preferredColorScheme(.dark)
    }

    // MARK: - Components

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(DS.Typography.sectionTitle)
                .tracking(0.5)
                .foregroundStyle(DS.Colors.textMuted)

            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(DS.Colors.border, lineWidth: 1)
            )
        }
    }

    private func settingsToggle(
        isOn: Binding<Bool>,
        title: String,
        subtitle: String? = nil,
        isDisabled: Bool = false
    ) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DS.Typography.body)
                    .foregroundStyle(DS.Colors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(DS.Typography.caption)
                        .foregroundStyle(DS.Colors.textMuted)
                }
            }
        }
        .toggleStyle(.switch)
        .tint(DS.Colors.accent)
        .disabled(isDisabled)
    }

    // MARK: - App Info

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
#endif
