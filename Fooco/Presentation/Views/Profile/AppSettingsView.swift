// MARK: - AppSettingsView.swift
//
// Sub-pantalla de configuración de la aplicación.
//
// Ajustes actuales:
//   • Sistema de unidades — métrico (kg/cm) o imperial (lb/ft)
//   • Apariencia — seguir el sistema, claro u oscuro
//
// Los valores se persisten en UserDefaults vía @AppStorage.
// No necesitan SwiftData ni el repositorio de perfil.

import SwiftUI

// MARK: - AppSettingsView

struct AppSettingsView: View {

    // MARK: - Persistencia simple en UserDefaults

    @AppStorage("settings.unitSystem") private var unitSystem = UnitSystem.metric.rawValue
    @AppStorage("settings.appearance") private var appearance = AppAppearance.system.rawValue

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.lg) {

                // MARK: Sección — Unidades
                ProfileSection(title: "settings.section.units") {
                    unitSystemPicker
                }

                // MARK: Sección — Apariencia
                ProfileSection(title: "settings.section.appearance") {
                    appearancePicker
                }

                // MARK: Sección — Acerca de
                ProfileSection(title: "settings.section.about") {
                    aboutRow(
                        icon: "fork.knife.circle.fill",
                        label: "settings.about.app_name",
                        value: "Fooco"
                    )

                    Divider().padding(.leading, 56)

                    aboutRow(
                        icon: "number.circle.fill",
                        label: "settings.about.version",
                        value: appVersion
                    )
                }

                Spacer(minLength: AppConstants.Spacing.xxxl)
            }
            .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
            .padding(.top, AppConstants.Spacing.md)
        }
        .background(AppColors.background)
        .navigationTitle(Text("profile.menu.settings"))
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(selectedColorScheme)
    }

    // MARK: - Subvistas

    private var unitSystemPicker: some View {
        HStack {
            Text("settings.units.label")
                .font(.system(size: AppConstants.FontSize.callout))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Menu {
                ForEach(UnitSystem.allCases, id: \.self) { system in
                    Button(system.displayName) { unitSystem = system.rawValue }
                }
            } label: {
                HStack(spacing: AppConstants.Spacing.xs) {
                    Text(UnitSystem(rawValue: unitSystem)?.displayName ?? "")
                        .font(.system(size: AppConstants.FontSize.callout))
                        .foregroundStyle(AppColors.textSecondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: AppConstants.FontSize.caption, weight: .semibold))
                        .foregroundStyle(AppColors.textDisabled)
                }
            }
        }
        .padding(.horizontal, AppConstants.Spacing.md)
        .padding(.vertical, AppConstants.Spacing.smMd)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColors.separator)
                .frame(height: 1)
                .padding(.horizontal, AppConstants.Spacing.md)
        }
    }

    private var appearancePicker: some View {
        HStack {
            Text("settings.appearance.label")
                .font(.system(size: AppConstants.FontSize.callout))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Menu {
                ForEach(AppAppearance.allCases, id: \.self) { option in
                    Button(option.displayName) { appearance = option.rawValue }
                }
            } label: {
                HStack(spacing: AppConstants.Spacing.xs) {
                    Text(AppAppearance(rawValue: appearance)?.displayName ?? "")
                        .font(.system(size: AppConstants.FontSize.callout))
                        .foregroundStyle(AppColors.textSecondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: AppConstants.FontSize.caption, weight: .semibold))
                        .foregroundStyle(AppColors.textDisabled)
                }
            }
        }
        .padding(.horizontal, AppConstants.Spacing.md)
        .padding(.vertical, AppConstants.Spacing.smMd)
    }

    private func aboutRow(icon: String, label: LocalizedStringKey, value: String) -> some View {
        HStack(spacing: AppConstants.Spacing.smMd) {
            Image(systemName: icon)
                .font(.system(size: AppConstants.FontSize.callout))
                .foregroundStyle(AppColors.primary)
                .frame(width: 24)

            Text(label)
                .font(.system(size: AppConstants.FontSize.callout))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: AppConstants.FontSize.callout))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.horizontal, AppConstants.Spacing.md)
        .padding(.vertical, AppConstants.Spacing.smMd)
    }

    // MARK: - Computed

    private var selectedColorScheme: ColorScheme? {
        switch AppAppearance(rawValue: appearance) {
        case .light:  return .light
        case .dark:   return .dark
        default:      return nil
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? version : "\(version) (\(build))"
    }
}

// MARK: - UnitSystem

enum UnitSystem: String, CaseIterable {
    case metric   = "metric"
    case imperial = "imperial"

    var displayName: String {
        switch self {
        case .metric:   return localized("settings.units.metric")
        case .imperial: return localized("settings.units.imperial")
        }
    }
}

// MARK: - AppAppearance

enum AppAppearance: String, CaseIterable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    var displayName: String {
        switch self {
        case .system: return localized("settings.appearance.system")
        case .light:  return localized("settings.appearance.light")
        case .dark:   return localized("settings.appearance.dark")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AppSettingsView()
    }
}
