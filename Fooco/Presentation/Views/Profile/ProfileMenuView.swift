// MARK: - ProfileMenuView.swift
//
// Hub principal del tab Perfil.
//
// Actúa como menú de navegación hacia sub-pantallas:
//   • Datos personales  → PersonalInfoView
//   • Condiciones de salud → HealthConditionsView
//   • Configuración de la app → AppSettingsView
//
// El ProfileViewModel se crea aquí y se pasa hacia abajo.
// Una sola instancia garantiza que los cambios en una sub-pantalla
// (p.ej. editar peso) se reflejan cuando se vuelve al menú.

import SwiftUI

// MARK: - ProfileMenuView

struct ProfileMenuView: View {

    // MARK: - ViewModel

    @State private var viewModel: ProfileViewModel

    // MARK: - Init

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.lg) {

                // MARK: Header de usuario
                profileHeader

                // MARK: Sección — Mi información
                menuSection(title: "profile.menu.section.info") {
                    ProfileMenuItem(
                        icon: "person.fill",
                        iconColor: AppColors.primary,
                        title: "profile.menu.personal",
                        subtitle: personalSubtitle
                    ) {
                        PersonalInfoView(viewModel: viewModel)
                    }

                    Divider().padding(.leading, 56)

                    ProfileMenuItem(
                        icon: "heart.text.clipboard.fill",
                        iconColor: AppColors.error,
                        title: "profile.menu.health",
                        subtitle: healthSubtitle
                    ) {
                        HealthConditionsView(viewModel: viewModel)
                    }
                }

                // MARK: Sección — App
                menuSection(title: "profile.menu.section.app") {
                    ProfileMenuItem(
                        icon: "gearshape.fill",
                        iconColor: AppColors.textSecondary,
                        title: "profile.menu.settings",
                        subtitle: nil
                    ) {
                        AppSettingsView()
                    }
                }

                Spacer(minLength: AppConstants.Spacing.xxxl)
            }
            .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
            .padding(.top, AppConstants.Spacing.sm)
        }
        .background(AppColors.background)
        .navigationTitle(Text("tab.profile"))
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }

    // MARK: - Subvistas

    private var profileHeader: some View {
        HStack(spacing: AppConstants.Spacing.md) {

            // Avatar placeholder
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 64, height: 64)

                Text(avatarInitials)
                    .font(.system(size: AppConstants.FontSize.title3, weight: .bold))
                    .foregroundStyle(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                Text(displayName)
                    .font(.system(size: AppConstants.FontSize.title3, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                if !viewModel.isLoading {
                    Text(profileStatusText)
                        .font(.system(size: AppConstants.FontSize.footnote))
                        .foregroundStyle(viewModel.estimatedCalories != nil ? AppColors.secondary : AppColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(AppConstants.Spacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.Radius.card)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func menuSection(title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.smMd) {
            Text(title)
                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            VStack(spacing: 0) {
                content()
            }
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Radius.card)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }

    // MARK: - Computed helpers

    private var displayName: String {
        viewModel.name.isEmpty
            ? localized("profile.menu.anonymous")
            : viewModel.name
    }

    private var avatarInitials: String {
        let name = viewModel.name.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var profileStatusText: String {
        if let kcal = viewModel.estimatedCalories {
            return localized("profile.menu.status.complete", args: kcal)
        }
        return localized("profile.menu.status.incomplete")
    }

    private var personalSubtitle: String? {
        guard !viewModel.weightKg.isEmpty || !viewModel.heightCm.isEmpty else { return nil }
        var parts: [String] = []
        if !viewModel.weightKg.isEmpty  { parts.append("\(viewModel.weightKg) kg") }
        if !viewModel.heightCm.isEmpty  { parts.append("\(viewModel.heightCm) cm") }
        return parts.joined(separator: " · ")
    }

    private var healthSubtitle: String? {
        let count = viewModel.selectedConditions.count
        guard count > 0 else { return nil }
        return count == 1
            ? viewModel.selectedConditions.first?.displayName
            : localized("profile.menu.health.count", args: count)
    }
}

// MARK: - ProfileMenuItem

private struct ProfileMenuItem<Destination: View>: View {

    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    let subtitle: String?
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: AppConstants.Spacing.smMd) {

                // Ícono con fondo de color
                ZStack {
                    RoundedRectangle(cornerRadius: AppConstants.Radius.sm)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: AppConstants.FontSize.callout, weight: .semibold))
                        .foregroundStyle(iconColor)
                }

                // Texto
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: AppConstants.FontSize.callout))
                        .foregroundStyle(AppColors.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: AppConstants.FontSize.caption, weight: .semibold))
                    .foregroundStyle(AppColors.textDisabled)
            }
            .padding(.horizontal, AppConstants.Spacing.md)
            .padding(.vertical, AppConstants.Spacing.smMd)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileMenuView(
            viewModel: ProfileViewModel(
                getProfileUseCase: PreviewGetProfileUseCase(),
                saveProfileUseCase: PreviewSaveProfileUseCase()
            )
        )
    }
}

private struct PreviewGetProfileUseCase: GetUserProfileUseCaseProtocol {
    func execute() async throws -> UserProfile? { nil }
}
private struct PreviewSaveProfileUseCase: SaveUserProfileUseCaseProtocol {
    func execute(_ profile: UserProfile) async throws {}
}
