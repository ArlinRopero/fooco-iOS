// MARK: - PersonalInfoView.swift
//
// Sub-pantalla de datos personales dentro del perfil.
// Cubre: nombre, sexo biológico, año de nacimiento, peso, altura,
//        nivel de actividad y objetivo calórico.

import SwiftUI

// MARK: - PersonalInfoView

struct PersonalInfoView: View {

    // MARK: - ViewModel compartido con ProfileMenuView

    @Bindable var viewModel: ProfileViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.lg) {

                // Banner si el perfil está vacío
                if isProfileEmpty {
                    emptyStateBanner
                }

                // MARK: Sección — Datos personales
                ProfileSection(title: "profile.section.personal") {
                    ProfileTextField(
                        label: "profile.name.label",
                        placeholder: "profile.name.placeholder",
                        text: $viewModel.name,
                        keyboardType: .default
                    )

                    ProfilePickerRow(
                        label: "profile.sex.label",
                        selection: $viewModel.biologicalSex,
                        options: BiologicalSex.allCases,
                        displayName: \.displayName
                    )

                    ProfileTextField(
                        label: "profile.birth_year.label",
                        placeholder: "profile.birth_year.placeholder",
                        text: $viewModel.birthYear,
                        keyboardType: .numberPad
                    )

                    ProfileTextField(
                        label: "profile.weight.label",
                        placeholder: "profile.weight.placeholder",
                        text: $viewModel.weightKg,
                        keyboardType: .decimalPad
                    )

                    ProfileTextField(
                        label: "profile.height.label",
                        placeholder: "profile.height.placeholder",
                        text: $viewModel.heightCm,
                        keyboardType: .decimalPad
                    )
                }

                // MARK: Sección — Nivel de actividad
                ProfileSection(title: "profile.section.activity") {
                    ProfilePickerRow(
                        label: "profile.activity.label",
                        selection: $viewModel.activityLevel,
                        options: ActivityLevel.allCases,
                        displayName: \.displayName
                    )
                }

                // MARK: Sección — Objetivo calórico
                ProfileSection(title: "profile.section.goal") {
                    calorieGoalRow
                }

                // MARK: Botón guardar
                saveButton
                    .padding(.bottom, AppConstants.Spacing.xxxl)
            }
            .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
            .padding(.top, AppConstants.Spacing.md)
        }
        .background(AppColors.background)
        .navigationTitle(Text("profile.menu.personal"))
        .navigationBarTitleDisplayMode(.large)
        .alert("profile.save.success", isPresented: $viewModel.saveSuccess) {
            Button("OK", role: .cancel) {}
        }
        .alert(
            "error.generic.title",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Subvistas privadas

    private var isProfileEmpty: Bool {
        viewModel.name.isEmpty && viewModel.birthYear.isEmpty &&
        viewModel.weightKg.isEmpty && viewModel.heightCm.isEmpty
    }

    private var emptyStateBanner: some View {
        HStack(alignment: .top, spacing: AppConstants.Spacing.smMd) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: AppConstants.IconSize.lg))
                .foregroundStyle(AppColors.primary)

            Text("profile.empty.subtitle")
                .font(.system(size: AppConstants.FontSize.footnote))
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppConstants.Spacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.Radius.card)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    private var calorieGoalRow: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
            ProfileTextField(
                label: "profile.calories.label",
                placeholder: viewModel.estimatedCalories.map { "\($0)" } ?? "profile.calories.auto_placeholder",
                text: $viewModel.dailyCalorieGoal,
                keyboardType: .numberPad
            )

            if viewModel.dailyCalorieGoal.isEmpty, let estimated = viewModel.estimatedCalories {
                Text("profile.calories.auto_hint \(estimated)")
                    .font(.system(size: AppConstants.FontSize.caption))
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, AppConstants.Spacing.xs)
            }
        }
    }

    private var saveButton: some View {
        Button {
            Task { await viewModel.save() }
        } label: {
            Group {
                if viewModel.isSaving {
                    ProgressView().tint(AppColors.textOnColor)
                } else {
                    Text("profile.save.button")
                        .font(.system(size: AppConstants.FontSize.callout, weight: .semibold))
                        .foregroundStyle(AppColors.textOnColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.ComponentSize.buttonHeight)
        }
        .background(AppColors.primary)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.md))
        .disabled(viewModel.isSaving)
    }
}

// MARK: - ProfileSection

struct ProfileSection<Content: View>: View {

    let title: LocalizedStringKey
    @ViewBuilder let content: () -> Content

    var body: some View {
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
}

// MARK: - ProfileTextField

struct ProfileTextField: View {

    let label: LocalizedStringKey
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let keyboardType: UIKeyboardType

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: AppConstants.FontSize.callout))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 130, alignment: .leading)

            Spacer()

            TextField(placeholder, text: $text)
                .font(.system(size: AppConstants.FontSize.callout))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.trailing)
                .keyboardType(keyboardType)
                .submitLabel(.done)
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
}

// MARK: - ProfilePickerRow

struct ProfilePickerRow<T: Hashable & CaseIterable>: View where T.AllCases: RandomAccessCollection {

    let label: LocalizedStringKey
    @Binding var selection: T
    let options: T.AllCases
    let displayName: (T) -> String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: AppConstants.FontSize.callout))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Menu {
                ForEach(Array(options), id: \.hashValue) { option in
                    Button(displayName(option)) { selection = option }
                }
            } label: {
                HStack(spacing: AppConstants.Spacing.xs) {
                    Text(displayName(selection))
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
}
