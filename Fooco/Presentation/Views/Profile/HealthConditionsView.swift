// MARK: - HealthConditionsView.swift
//
// Sub-pantalla para declarar condiciones de salud.
//
// Lista fija de condiciones (enum HealthCondition).
// Evolutivo: reemplazar por búsqueda dinámica contra la API ICD-10-CM de NLM
// (https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search)
// cuando se implemente la integración de red para esta pantalla.

import SwiftUI

// MARK: - HealthConditionsView

struct HealthConditionsView: View {

    // MARK: - ViewModel compartido

    @Bindable var viewModel: ProfileViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.lg) {

                // Descripción
                descriptionBanner

                // Tags de condiciones seleccionadas
                if !viewModel.selectedConditions.isEmpty {
                    selectedConditionsSection
                }

                // Búsqueda + lista
                ProfileSection(title: "profile.section.health") {
                    searchField

                    let unselected = viewModel.filteredConditions
                        .filter { !viewModel.selectedConditions.contains($0) }

                    if unselected.isEmpty && !viewModel.conditionSearchText.isEmpty {
                        noResultsRow
                    } else {
                        ForEach(unselected, id: \.self) { condition in
                            conditionRow(condition, isLast: condition == unselected.last)
                        }
                    }
                }

                saveButton
                    .padding(.bottom, AppConstants.Spacing.xxxl)
            }
            .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
            .padding(.top, AppConstants.Spacing.md)
        }
        .background(AppColors.background)
        .navigationTitle(Text("profile.menu.health"))
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

    // MARK: - Subvistas

    private var descriptionBanner: some View {
        HStack(alignment: .top, spacing: AppConstants.Spacing.smMd) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: AppConstants.IconSize.md))
                .foregroundStyle(AppColors.secondary)

            Text("profile.health.description")
                .font(.system(size: AppConstants.FontSize.footnote))
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppConstants.Spacing.md)
        .background(AppColors.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
    }

    private var selectedConditionsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.smMd) {
            Text("profile.health.selected_title")
                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            ConditionFlowLayout(spacing: AppConstants.Spacing.sm) {
                ForEach(
                    Array(viewModel.selectedConditions).sorted { $0.rawValue < $1.rawValue },
                    id: \.self
                ) { condition in
                    ConditionTag(
                        name: condition.displayName,
                        isSelected: true,
                        action: { viewModel.toggleCondition(condition) }
                    )
                }
            }
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textSecondary)
                .font(.system(size: AppConstants.FontSize.callout))

            TextField(
                LocalizedStringKey("profile.health.search.placeholder"),
                text: $viewModel.conditionSearchText
            )
            .font(.system(size: AppConstants.FontSize.callout))
            .foregroundStyle(AppColors.textPrimary)

            if !viewModel.conditionSearchText.isEmpty {
                Button {
                    viewModel.conditionSearchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
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

    private var noResultsRow: some View {
        Text("profile.health.no_results")
            .font(.system(size: AppConstants.FontSize.callout))
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(AppConstants.Spacing.lg)
    }

    private func conditionRow(_ condition: HealthCondition, isLast: Bool) -> some View {
        Button {
            viewModel.toggleCondition(condition)
        } label: {
            HStack {
                Text(condition.displayName)
                    .font(.system(size: AppConstants.FontSize.callout))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "plus.circle")
                    .foregroundStyle(AppColors.primary)
                    .font(.system(size: AppConstants.FontSize.callout))
            }
            .padding(.horizontal, AppConstants.Spacing.md)
            .padding(.vertical, AppConstants.Spacing.smMd)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(AppColors.separator)
                    .frame(height: 1)
                    .padding(.horizontal, AppConstants.Spacing.md)
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
        .background(AppColors.secondary)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.md))
        .disabled(viewModel.isSaving)
    }
}

// MARK: - ConditionTag

struct ConditionTag: View {

    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppConstants.Spacing.xs) {
                Text(name)
                    .font(.system(size: AppConstants.FontSize.footnote, weight: .medium))

                Image(systemName: isSelected ? "xmark" : "plus")
                    .font(.system(size: AppConstants.FontSize.caption2, weight: .semibold))
            }
            .padding(.horizontal, AppConstants.Spacing.smMd)
            .padding(.vertical, AppConstants.Spacing.sm)
            .foregroundStyle(isSelected ? AppColors.textOnColor : AppColors.secondary)
            .background(isSelected ? AppColors.secondary : AppColors.secondary.opacity(0.12))
            .clipShape(Capsule())
        }
    }
}

// MARK: - ConditionFlowLayout

struct ConditionFlowLayout: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                height += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
