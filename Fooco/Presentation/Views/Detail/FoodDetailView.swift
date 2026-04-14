// MARK: - FoodDetailView.swift
//
// Pantalla de detalle nutricional de un alimento.
//
// Los datos llegan completos desde la búsqueda — no hay carga inicial.
// "Saber más" carga bajo demanda: categoría, porciones, minerales, vitaminas, grasas.

import SwiftUI

// MARK: - FoodDetailView

struct FoodDetailView: View {

    @State var viewModel: FoodDetailViewModel

    @State private var selectedGrams: Double = 100

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppConstants.Spacing.lg) {
                    headerSection
                    caloriesHeroSection
                    macrosSection
                    servingNote
                    knowMoreSection
                    logButton
                }
                .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
                .padding(.top, AppConstants.Spacing.md)
                .padding(.bottom, AppConstants.Spacing.xxxl)
            }

            if viewModel.isLogged {
                loggedConfirmation
            }
        }
        .navigationTitle(viewModel.food.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.Radius.cardLg)
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 56, height: 56)

                Image(systemName: "leaf.fill")
                    .font(.system(size: AppConstants.IconSize.xl))
                    .foregroundStyle(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                Text(viewModel.food.name)
                    .font(.system(size: AppConstants.FontSize.title3, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: AppConstants.Spacing.sm) {
                    dataTypeBadge

                    if let brand = viewModel.food.brand {
                        Text(brand)
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding(AppConstants.Spacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
    }

    // MARK: - Calorías Hero

    private var caloriesHeroSection: some View {
        VStack(spacing: AppConstants.Spacing.xs) {
            Text("detail.calories.label")
                .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)

            HStack(alignment: .lastTextBaseline, spacing: AppConstants.Spacing.xs) {
                Text(caloriesFormatted)
                    .font(.system(size: AppConstants.FontSize.hero, weight: .black))
                    .foregroundStyle(AppColors.primary)
                    .contentTransition(.numericText())

                Text("unit.kcal")
                    .font(.system(size: AppConstants.FontSize.title2, weight: .semibold))
                    .foregroundStyle(AppColors.primary.opacity(0.7))
            }

            Text("detail.per_100g")
                .font(.system(size: AppConstants.FontSize.caption))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppConstants.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.Radius.card)
                .fill(AppColors.primary.opacity(0.08))
        )
    }

    // MARK: - Macros Principales

    private var macrosSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            Text("detail.macros.title")
                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: AppConstants.Spacing.sm) {
                MacroCard(
                    label: "detail.macro.protein",
                    value: viewModel.food.nutrients.protein,
                    unit: "g",
                    color: AppColors.macroProtein,
                    icon: "flame.fill"
                )
                MacroCard(
                    label: "detail.macro.carbs",
                    value: viewModel.food.nutrients.carbs,
                    unit: "g",
                    color: AppColors.macroCarbs,
                    icon: "bolt.fill"
                )
                MacroCard(
                    label: "detail.macro.fat",
                    value: viewModel.food.nutrients.fat,
                    unit: "g",
                    color: AppColors.macroFat,
                    icon: "drop.fill"
                )
            }
        }
    }

    // MARK: - Nutrientes Secundarios

    private var secondaryNutrientsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            Text("detail.secondary.title")
                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            VStack(spacing: 0) {
                if let fiber = viewModel.food.nutrients.fiber {
                    NutrientRow(
                        label: "detail.nutrient.fiber",
                        value: fiber, unit: "g",
                        color: AppColors.macroFiber,
                        isLast: viewModel.food.nutrients.sugar == nil && viewModel.food.nutrients.sodium == nil
                    )
                }
                if let sugar = viewModel.food.nutrients.sugar {
                    NutrientRow(
                        label: "detail.nutrient.sugar",
                        value: sugar, unit: "g",
                        color: AppColors.accent,
                        isLast: viewModel.food.nutrients.sodium == nil
                    )
                }
                if let sodium = viewModel.food.nutrients.sodium {
                    NutrientRow(
                        label: "detail.nutrient.sodium",
                        value: sodium, unit: "mg",
                        color: AppColors.error,
                        isLast: true
                    )
                }
            }
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
        }
    }

    // MARK: - Nota de porción

    private var servingNote: some View {
        HStack(spacing: AppConstants.Spacing.sm) {
            Image(systemName: "info.circle")
                .font(.system(size: AppConstants.IconSize.sm))
                .foregroundStyle(AppColors.textSecondary)
            Text("detail.serving_note")
                .font(.system(size: AppConstants.FontSize.caption))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppConstants.Spacing.md)
        .background(AppColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.md))
    }

    // MARK: - Saber más

    @ViewBuilder
    private var knowMoreSection: some View {
        if let detail = viewModel.fullDetail {
            fullDetailSection(detail)
        } else {
            knowMoreButton
        }
    }

    private var knowMoreButton: some View {
        Button {
            Task { await viewModel.loadFullDetail() }
        } label: {
            HStack(spacing: AppConstants.Spacing.sm) {
                if viewModel.isLoadingFullDetail {
                    ProgressView()
                        .tint(AppColors.primary)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "info.circle")
                        .font(.system(size: AppConstants.IconSize.sm))
                }
                Text(viewModel.isLoadingFullDetail ? "detail.know_more.loading" : "detail.know_more.button")
                    .font(.system(size: AppConstants.FontSize.callout, weight: .medium))
            }
            .foregroundStyle(AppColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(AppColors.primary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Radius.md)
                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(viewModel.isLoadingFullDetail)
    }

    @ViewBuilder
    private func fullDetailSection(_ detail: FoodDetail) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.lg) {

            // Encabezado de la sección
            HStack {
                Text("detail.know_more.title")
                    .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }

            // Metadatos (categoría + nombre científico)
            if detail.category != nil || detail.scientificName != nil {
                metadataCard(detail)
            }

            // Porciones de referencia
            if !detail.portions.isEmpty {
                portionsCard(detail.portions)
            }

            // Minerales
            let minerals = mineralRows(detail.extended)
            if !minerals.isEmpty {
                extendedNutrientsCard(
                    title: "detail.know_more.minerals",
                    rows: minerals
                )
            }

            // Vitaminas
            let vitamins = vitaminRows(detail.extended)
            if !vitamins.isEmpty {
                extendedNutrientsCard(
                    title: "detail.know_more.vitamins",
                    rows: vitamins
                )
            }

            // Grasas desglosadas
            let fats = fatRows(detail.extended)
            if !fats.isEmpty {
                extendedNutrientsCard(
                    title: "detail.know_more.fats",
                    rows: fats
                )
            }
        }
    }

    // MARK: - Subvistas del detalle ampliado

    private func metadataCard(_ detail: FoodDetail) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            if let category = detail.category {
                HStack {
                    Image(systemName: "tag")
                        .font(.system(size: AppConstants.IconSize.sm))
                        .foregroundStyle(AppColors.textSecondary)
                    Text(category)
                        .font(.system(size: AppConstants.FontSize.body))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                }
            }
            if let sci = detail.scientificName {
                HStack {
                    Image(systemName: "leaf")
                        .font(.system(size: AppConstants.IconSize.sm))
                        .foregroundStyle(AppColors.textSecondary)
                    Text(sci)
                        .font(.system(size: AppConstants.FontSize.body).italic())
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                }
            }
        }
        .padding(AppConstants.Spacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
    }

    private func portionsCard(_ portions: [FoodPortion]) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            Text("detail.know_more.portions")
                .font(.system(size: AppConstants.FontSize.caption, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: AppConstants.Spacing.sm) {
                ForEach(portions.prefix(4)) { portion in
                    VStack(spacing: 4) {
                        Text(portionLabel(portion))
                            .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(portionGrams(portion))
                            .font(.system(size: AppConstants.FontSize.caption2))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppConstants.Spacing.sm)
                    .background(AppColors.primary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.sm))
                }
            }
        }
        .padding(AppConstants.Spacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
    }

    private func extendedNutrientsCard(title: LocalizedStringKey, rows: [(name: String, value: String)]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: AppConstants.FontSize.caption, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, AppConstants.Spacing.md)
                .padding(.top, AppConstants.Spacing.md)
                .padding(.bottom, AppConstants.Spacing.sm)

            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack {
                    Text(row.name)
                        .font(.system(size: AppConstants.FontSize.body))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Text(row.value)
                        .font(.system(size: AppConstants.FontSize.body, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }
                .padding(.horizontal, AppConstants.Spacing.md)
                .padding(.vertical, AppConstants.Spacing.smMd)

                if index < rows.count - 1 {
                    Divider()
                        .padding(.leading, AppConstants.Spacing.md)
                }
            }
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
    }

    // MARK: - Sección de registro

    private var logButton: some View {
        VStack(spacing: AppConstants.Spacing.md) {

            Text("detail.log.section_title")
                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: AppConstants.Spacing.smMd) {

                HStack(spacing: AppConstants.Spacing.sm) {
                    ForEach(GramsPreset.allCases, id: \.self) { preset in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                selectedGrams = preset.grams
                            }
                        } label: {
                            Text(preset.label)
                                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                                .foregroundStyle(selectedGrams == preset.grams ? AppColors.textOnColor : AppColors.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(
                                    selectedGrams == preset.grams
                                        ? AppColors.primary
                                        : AppColors.primary.opacity(0.1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.sm))
                        }
                    }
                }

                HStack(spacing: AppConstants.Spacing.md) {
                    Slider(value: $selectedGrams, in: 5...500, step: 5)
                        .tint(AppColors.primary)

                    HStack(spacing: 2) {
                        Text(gramsFormatted)
                            .font(.system(size: AppConstants.FontSize.body, weight: .bold).monospacedDigit())
                            .foregroundStyle(AppColors.textPrimary)
                        Text("g")
                            .font(.system(size: AppConstants.FontSize.footnote))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(width: 52, alignment: .trailing)
                }

                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: AppConstants.Spacing.xs))
                        .foregroundStyle(AppColors.primary)
                    Text(calculatedCaloriesText)
                        .font(.system(size: AppConstants.FontSize.footnote))
                        .foregroundStyle(AppColors.textSecondary)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.2), value: selectedGrams)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(AppConstants.Spacing.md)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))

            Button {
                Task { await viewModel.logFood(grams: selectedGrams) }
            } label: {
                HStack(spacing: AppConstants.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: AppConstants.IconSize.md))
                    Text("detail.log.button")
                        .font(.system(size: AppConstants.FontSize.callout, weight: .semibold))
                }
                .foregroundStyle(AppColors.textOnColor)
                .frame(maxWidth: .infinity)
                .frame(height: AppConstants.ComponentSize.buttonHeight)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.md))
            }
            .disabled(viewModel.isLogged)
        }
    }

    // MARK: - Confirmación de registro

    private var loggedConfirmation: some View {
        VStack(spacing: AppConstants.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: AppConstants.IconSize.xl))
                .foregroundStyle(.white)

            Text("detail.log.success")
                .font(.system(size: AppConstants.FontSize.callout, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, AppConstants.Spacing.xl)
        .padding(.vertical, AppConstants.Spacing.lg)
        .background(AppColors.secondary.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.isLogged)
    }

    // MARK: - Helpers de gramaje

    private var gramsFormatted: String {
        selectedGrams.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", selectedGrams)
            : String(format: "%.1f", selectedGrams)
    }

    private var calculatedCaloriesText: String {
        let kcal = viewModel.food.nutrients.calories * (selectedGrams / 100)
        let formatted = kcal.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", kcal)
            : String(format: "%.1f", kcal)
        return "\(formatted) kcal para \(gramsFormatted)g"
    }

    private var caloriesFormatted: String {
        let kcal = viewModel.food.nutrients.calories
        return kcal.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", kcal)
            : String(format: "%.1f", kcal)
    }

    // MARK: - Helpers de porciones

    private func portionLabel(_ portion: FoodPortion) -> String {
        portion.amount.truncatingRemainder(dividingBy: 1) == 0
            ? "\(String(format: "%.0f", portion.amount)) \(portion.modifier)"
            : "\(String(format: "%.1f", portion.amount)) \(portion.modifier)"
    }

    private func portionGrams(_ portion: FoodPortion) -> String {
        portion.gramWeight.truncatingRemainder(dividingBy: 1) == 0
            ? "\(String(format: "%.0f", portion.gramWeight)) g"
            : "\(String(format: "%.1f", portion.gramWeight)) g"
    }

    // MARK: - Helpers de nutrientes extendidos

    private func mineralRows(_ ext: ExtendedNutrients) -> [(name: String, value: String)] {
        let items: [(String, Double?, String)] = [
            ("Calcio",   ext.calcium,    "mg"),
            ("Hierro",   ext.iron,       "mg"),
            ("Magnesio", ext.magnesium,  "mg"),
            ("Fósforo",  ext.phosphorus, "mg"),
            ("Potasio",  ext.potassium,  "mg"),
            ("Zinc",     ext.zinc,       "mg"),
        ]
        return items.compactMap { name, value, unit in
            guard let v = value else { return nil }
            return (name, formatNutrient(v, unit: unit))
        }
    }

    private func vitaminRows(_ ext: ExtendedNutrients) -> [(name: String, value: String)] {
        let items: [(String, Double?, String)] = [
            ("Vitamina C",  ext.vitaminC,   "mg"),
            ("Vitamina B6", ext.vitaminB6,  "mg"),
            ("Folato",      ext.folate,     "µg"),
            ("Vitamina B12",ext.vitaminB12, "µg"),
            ("Vitamina A",  ext.vitaminA,   "µg"),
        ]
        return items.compactMap { name, value, unit in
            guard let v = value else { return nil }
            return (name, formatNutrient(v, unit: unit))
        }
    }

    private func fatRows(_ ext: ExtendedNutrients) -> [(name: String, value: String)] {
        let items: [(String, Double?, String)] = [
            ("Saturadas",       ext.saturatedFat,       "g"),
            ("Monoinsaturadas", ext.monounsaturatedFat, "g"),
            ("Poliinsaturadas", ext.polyunsaturatedFat, "g"),
        ]
        return items.compactMap { name, value, unit in
            guard let v = value else { return nil }
            return (name, formatNutrient(v, unit: unit))
        }
    }

    private func formatNutrient(_ value: Double, unit: String) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(String(format: "%.0f", value)) \(unit)"
            : "\(String(format: "%.2f", value)) \(unit)"
    }

    // MARK: - Badge de tipo de alimento

    private var dataTypeBadge: some View {
        Text(viewModel.food.dataType.localizedName)
            .font(.system(size: AppConstants.FontSize.caption2, weight: .semibold))
            .foregroundStyle(AppColors.secondary)
            .padding(.horizontal, AppConstants.Spacing.sm)
            .padding(.vertical, 2)
            .background(AppColors.secondary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.sm))
    }
}

// MARK: - GramsPreset

private enum GramsPreset: CaseIterable {
    case small, medium, large, extraLarge

    var grams: Double {
        switch self {
        case .small:      return 50
        case .medium:     return 100
        case .large:      return 150
        case .extraLarge: return 200
        }
    }

    var label: String {
        switch self {
        case .small:      return "50g"
        case .medium:     return "100g"
        case .large:      return "150g"
        case .extraLarge: return "200g"
        }
    }
}

// MARK: - Food.DataType + localizedName

private extension Food.DataType {
    var localizedName: String {
        switch self {
        case .foundation: return localized(StringKey.FoodType.foundation)
        case .srLegacy:   return localized(StringKey.FoodType.srLegacy)
        case .branded:    return localized(StringKey.FoodType.branded)
        case .unknown:    return localized(StringKey.FoodType.unknown)
        }
    }
}

// MARK: - MacroCard

private struct MacroCard: View {
    let label: LocalizedStringKey
    let value: Double
    let unit: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: AppConstants.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: AppConstants.IconSize.sm))
                .foregroundStyle(color)

            Text(valueFormatted)
                .font(.system(size: AppConstants.FontSize.title3, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: AppConstants.FontSize.caption2))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppConstants.Spacing.md)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.Radius.card)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }

    private var valueFormatted: String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(String(format: "%.0f", value))\(unit)"
            : "\(String(format: "%.1f", value))\(unit)"
    }
}

// MARK: - NutrientRow

private struct NutrientRow: View {
    let label: LocalizedStringKey
    let value: Double
    let unit: String
    let color: Color
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: AppConstants.Spacing.sm) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    Text(label)
                        .font(.system(size: AppConstants.FontSize.body))
                        .foregroundStyle(AppColors.textPrimary)
                }

                Spacer()

                Text(valueFormatted)
                    .font(.system(size: AppConstants.FontSize.body, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, AppConstants.Spacing.md)
            .padding(.vertical, AppConstants.Spacing.smMd)

            if !isLast {
                Divider()
                    .padding(.leading, AppConstants.Spacing.md)
                    .foregroundStyle(AppColors.separator)
            }
        }
    }

    private var valueFormatted: String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(String(format: "%.0f", value)) \(unit)"
            : "\(String(format: "%.1f", value)) \(unit)"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FoodDetailView(
            viewModel: FoodDetailViewModel(
                food: Food(
                    id: 171705,
                    name: "Aguacate",
                    dataType: .foundation,
                    brand: nil,
                    nutrients: Food.Nutrients(
                        calories: 160, protein: 2, fat: 14.66,
                        carbs: 8.53, fiber: 6.7, sugar: 0.66, sodium: 7
                    )
                ),
                getFullDetailUseCase: GetFoodDetailUseCase(
                    repository: FoodRepository()
                )
            )
        )
    }
}
