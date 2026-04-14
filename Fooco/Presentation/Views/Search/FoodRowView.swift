// MARK: - FoodRowView.swift
//
// Celda de un alimento en la lista de resultados de búsqueda.
//
// Muestra:
//   - Nombre del alimento
//   - Calorías por 100g (dato más relevante en búsqueda)
//   - Tipo de base de datos (badge de calidad)
//   - Marca (solo alimentos Branded)

import SwiftUI

// MARK: - FoodRowView

struct FoodRowView: View {

    let food: Food

    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {

            // Ícono del tipo de alimento
            foodIcon

            // Info principal
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                Text(food.name)
                    .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: AppConstants.Spacing.sm) {
                    if let brand = food.brand {
                        Text(brand)
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(1)
                    }

                    dataTypeBadge
                }
            }

            Spacer()

            // Calorías
            caloriesView
        }
        .padding(.horizontal, AppConstants.Spacing.md)
        .padding(.vertical, AppConstants.Spacing.smMd)
        .frame(minHeight: AppConstants.ComponentSize.listRowHeight)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
        .shadow(color: AppColors.textPrimary.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Subviews

    private var foodIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppConstants.Radius.md)
                .fill(iconBackground)
                .frame(width: 44, height: 44)

            Image(systemName: iconName)
                .font(.system(size: AppConstants.IconSize.md))
                .foregroundStyle(iconColor)
        }
    }

    private var dataTypeBadge: some View {
        Text(food.dataType.displayName)
            .font(.system(size: AppConstants.FontSize.caption2, weight: .semibold))
            .foregroundStyle(badgeColor)
            .padding(.horizontal, AppConstants.Spacing.sm)
            .padding(.vertical, 2)
            .background(badgeColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.sm))
    }

    private var caloriesView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(caloriesFormatted)
                .font(.system(size: AppConstants.FontSize.title3, weight: .bold))
                .foregroundStyle(AppColors.primary)

            Text("unit.kcal_per_100g")
                .font(.system(size: AppConstants.FontSize.caption2))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Helpers

    private var caloriesFormatted: String {
        let kcal = food.nutrients.calories
        if kcal == 0 { return "—" }
        return kcal.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", kcal)
            : String(format: "%.1f", kcal)
    }

    private var iconName: String {
        switch food.dataType {
        case .foundation:  return "leaf.fill"
        case .srLegacy:    return "archivebox.fill"
        case .branded:     return "bag.fill"
        case .unknown:     return "questionmark.circle.fill"
        }
    }

    private var iconBackground: Color {
        switch food.dataType {
        case .foundation:  return AppColors.secondary.opacity(0.12)
        case .srLegacy:    return AppColors.accent.opacity(0.12)
        case .branded:     return AppColors.primary.opacity(0.12)
        case .unknown:     return AppColors.textSecondary.opacity(0.1)
        }
    }

    private var iconColor: Color {
        switch food.dataType {
        case .foundation:  return AppColors.secondary
        case .srLegacy:    return AppColors.accent
        case .branded:     return AppColors.primary
        case .unknown:     return AppColors.textSecondary
        }
    }

    private var badgeColor: Color {
        switch food.dataType {
        case .foundation:  return AppColors.secondary
        case .srLegacy:    return AppColors.accent
        case .branded:     return AppColors.primary
        case .unknown:     return AppColors.textSecondary
        }
    }
}

// MARK: - Food.DataType + displayName

private extension Food.DataType {
    var displayName: String {
        switch self {
        case .foundation: return localized(StringKey.FoodType.foundation)
        case .srLegacy:   return localized(StringKey.FoodType.srLegacy)
        case .branded:    return localized(StringKey.FoodType.branded)
        case .unknown:    return localized(StringKey.FoodType.unknown)
        }
    }
}

// MARK: - Skeleton

/// Celda de carga mientras llegan los resultados.
/// Mismo layout que FoodRowView pero con bloques grises animados.
struct FoodRowSkeleton: View {

    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            RoundedRectangle(cornerRadius: AppConstants.Radius.md)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                RoundedRectangle(cornerRadius: AppConstants.Radius.sm)
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)

                RoundedRectangle(cornerRadius: AppConstants.Radius.sm)
                    .frame(width: 80, height: 12)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppConstants.Spacing.xs) {
                RoundedRectangle(cornerRadius: AppConstants.Radius.sm)
                    .frame(width: 48, height: 20)

                RoundedRectangle(cornerRadius: AppConstants.Radius.sm)
                    .frame(width: 36, height: 10)
            }
        }
        .padding(.horizontal, AppConstants.Spacing.md)
        .padding(.vertical, AppConstants.Spacing.smMd)
        .frame(minHeight: AppConstants.ComponentSize.listRowHeight)
        .foregroundStyle(AppColors.surfaceElevated)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
        .opacity(isAnimating ? 0.5 : 1.0)
        .animation(
            .easeInOut(duration: AppConstants.Animation.emphasis)
            .repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear { isAnimating = true }
    }
}

// MARK: - Preview

#Preview("Food Row") {
    VStack(spacing: AppConstants.Spacing.sm) {
        FoodRowView(food: Food(
            id: 171705,
            name: "Avocado, raw",
            dataType: .foundation,
            brand: nil,
            nutrients: Food.Nutrients(
                calories: 160, protein: 2, fat: 14.66,
                carbs: 8.53, fiber: 6.7, sugar: 0.66, sodium: 7
            )
        ))
        FoodRowView(food: Food(
            id: 888888,
            name: "Organic Almond Butter",
            dataType: .branded,
            brand: "Whole Foods Market",
            nutrients: Food.Nutrients(
                calories: 614, protein: 21, fat: 56,
                carbs: 18, fiber: 10, sugar: 4, sodium: 5
            )
        ))
        FoodRowSkeleton()
    }
    .padding()
    .background(AppColors.background)
}
