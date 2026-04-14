// MARK: - LogView.swift
//
// Pantalla de registro diario de alimentos.
//
// Estructura:
//   • Resumen de hoy — calorías totales + barra de macros
//   • Lista de registros del día
//   • Historial de la semana — día a día con barra de calorías
//
// Se carga al aparecer y se recarga cada vez que la tab queda activa,
// para reflejar los nuevos registros sin reiniciar la vista.

import SwiftUI

// MARK: - LogView

struct LogView: View {

    @State var viewModel: LogViewModel

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if viewModel.isLoading && viewModel.todayEntries.isEmpty {
                loadingView
            } else {
                ScrollView {
                    VStack(spacing: AppConstants.Spacing.lg) {
                        todaySummarySection
                        todayEntriesSection
                        weekSection
                    }
                    .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
                    .padding(.top, AppConstants.Spacing.md)
                    .padding(.bottom, AppConstants.Spacing.xxxl)
                }
            }
        }
        .navigationTitle("log.screen.title")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }

    // MARK: - Loading

    private var loadingView: some View {
        ProgressView()
            .tint(AppColors.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Resumen de hoy

    private var todaySummarySection: some View {
        VStack(spacing: AppConstants.Spacing.md) {

            // Calorías hero
            VStack(spacing: AppConstants.Spacing.xs) {
                Text("log.today.calories.label")
                    .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                HStack(alignment: .lastTextBaseline, spacing: AppConstants.Spacing.xs) {
                    Text(formatCalories(viewModel.todayCalories))
                        .font(.system(size: AppConstants.FontSize.hero, weight: .black))
                        .foregroundStyle(AppColors.primary)
                        .contentTransition(.numericText())

                    Text("unit.kcal")
                        .font(.system(size: AppConstants.FontSize.title3, weight: .semibold))
                        .foregroundStyle(AppColors.primary.opacity(0.7))
                }
            }

            // Barra de macros
            if viewModel.todayCalories > 0 {
                macroBar
            }

            // Chips de macros
            HStack(spacing: AppConstants.Spacing.sm) {
                MacroChip(
                    label: "log.macro.protein",
                    value: viewModel.todayProtein,
                    color: AppColors.macroProtein
                )
                MacroChip(
                    label: "log.macro.carbs",
                    value: viewModel.todayCarbs,
                    color: AppColors.macroCarbs
                )
                MacroChip(
                    label: "log.macro.fat",
                    value: viewModel.todayFat,
                    color: AppColors.macroFat
                )
            }
        }
        .padding(AppConstants.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.Radius.card)
                .fill(AppColors.primary.opacity(0.06))
        )
        .animation(.easeOut(duration: 0.3), value: viewModel.todayCalories)
    }

    private var macroBar: some View {
        let total = viewModel.todayProtein + viewModel.todayCarbs + viewModel.todayFat
        let pP = total > 0 ? viewModel.todayProtein / total : 0
        let pC = total > 0 ? viewModel.todayCarbs / total : 0

        return GeometryReader { geo in
            HStack(spacing: 2) {
                // Proteína
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColors.macroProtein)
                    .frame(width: max(0, geo.size.width * pP))

                // Carbos
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColors.macroCarbs)
                    .frame(width: max(0, geo.size.width * pC))

                // Grasa (ocupa el resto)
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColors.macroFat)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 6)
        .clipShape(Capsule())
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.todayProtein)
    }

    // MARK: - Registros de hoy

    private var todayEntriesSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            Text("log.today.section")
                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            if viewModel.todayEntries.isEmpty {
                emptyTodayView
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.todayEntries.enumerated()), id: \.element.id) { index, entry in
                        LogEntryRow(
                            entry: entry,
                            isLast: index == viewModel.todayEntries.count - 1
                        )
                    }
                }
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
            }
        }
    }

    private var emptyTodayView: some View {
        VStack(spacing: AppConstants.Spacing.sm) {
            Image(systemName: "fork.knife")
                .font(.system(size: AppConstants.IconSize.xl))
                .foregroundStyle(AppColors.primary.opacity(0.3))

            Text("log.today.empty.title")
                .font(.system(size: AppConstants.FontSize.subheadline, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text("log.today.empty.subtitle")
                .font(.system(size: AppConstants.FontSize.footnote))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppConstants.Spacing.xl)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
    }

    // MARK: - Historial semanal

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            Text("log.week.section")
                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            if viewModel.weeklyDays.isEmpty {
                emptyWeekView
            } else {
                weekCalendarRow
                weekDaysList
            }
        }
    }

    /// Minibarra horizontal de los últimos 7 días (estilo calendario).
    private var weekCalendarRow: some View {
        let maxCalories = viewModel.weeklyDays.map { $0.totalCalories }.max() ?? 1
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return HStack(spacing: AppConstants.Spacing.xs) {
            ForEach(last7Days(), id: \.self) { day in
                let dailyLog = viewModel.weeklyDays.first(where: { $0.date == day })
                let calories = dailyLog?.totalCalories ?? 0
                let isToday  = day == today
                let fraction = maxCalories > 0 ? min(calories / maxCalories, 1.0) : 0

                VStack(spacing: 4) {
                    // Mini barra
                    GeometryReader { geo in
                        VStack {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isToday ? AppColors.primary : AppColors.primary.opacity(0.35))
                                .frame(height: max(4, geo.size.height * fraction))
                        }
                    }
                    .frame(height: 36)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: calories)

                    // Día de la semana
                    Text(dayLabel(day))
                        .font(.system(size: 10, weight: isToday ? .bold : .regular))
                        .foregroundStyle(isToday ? AppColors.primary : AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(AppConstants.Spacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
    }

    private var weekDaysList: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.weeklyDays.enumerated()), id: \.element.id) { index, daily in
                WeekDayRow(
                    daily: daily,
                    isLast: index == viewModel.weeklyDays.count - 1
                )
            }
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
    }

    private var emptyWeekView: some View {
        Text("log.week.empty")
            .font(.system(size: AppConstants.FontSize.footnote))
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, AppConstants.Spacing.lg)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.card))
    }

    // MARK: - Helpers

    private func last7Days() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7)
            .compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }
    }

    private func dayLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date)     { return "Hoy" }
        if calendar.isDateInYesterday(date) { return "Ayer" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale.current
        return formatter.string(from: date).capitalized
    }

    private func formatCalories(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}

// MARK: - MacroChip

private struct MacroChip: View {
    let label: LocalizedStringKey
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(valueFormatted)
                .font(.system(size: AppConstants.FontSize.footnote, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: AppConstants.FontSize.caption2))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppConstants.Spacing.sm)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.sm))
    }

    private var valueFormatted: String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(String(format: "%.0f", value))g"
            : "\(String(format: "%.1f", value))g"
    }
}

// MARK: - LogEntryRow

private struct LogEntryRow: View {
    let entry: LogEntry
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppConstants.Spacing.md) {
                // Icono
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.primary)
                }

                // Nombre + gramos
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.food.name)
                        .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    Text(gramsLabel)
                        .font(.system(size: AppConstants.FontSize.caption))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                // Calorías calculadas
                VStack(alignment: .trailing, spacing: 2) {
                    Text(caloriesFormatted)
                        .font(.system(size: AppConstants.FontSize.subheadline, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("unit.kcal")
                        .font(.system(size: AppConstants.FontSize.caption2))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, AppConstants.Spacing.md)
            .padding(.vertical, AppConstants.Spacing.smMd)

            if !isLast {
                Divider()
                    .padding(.leading, 56 + AppConstants.Spacing.md)
            }
        }
    }

    private var gramsLabel: String {
        entry.grams.truncatingRemainder(dividingBy: 1) == 0
            ? "\(String(format: "%.0f", entry.grams)) g"
            : "\(String(format: "%.1f", entry.grams)) g"
    }

    private var caloriesFormatted: String {
        let kcal = entry.calculatedCalories
        return kcal.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", kcal)
            : String(format: "%.1f", kcal)
    }
}

// MARK: - WeekDayRow

private struct WeekDayRow: View {
    let daily: DailyLog
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Fecha
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayTitle)
                        .font(.system(size: AppConstants.FontSize.body, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(daySubtitle)
                        .font(.system(size: AppConstants.FontSize.caption))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                // Totales del día
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(caloriesFormatted)
                            .font(.system(size: AppConstants.FontSize.subheadline, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("unit.kcal")
                            .font(.system(size: AppConstants.FontSize.caption2))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Text(entriesCount)
                        .font(.system(size: AppConstants.FontSize.caption2))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, AppConstants.Spacing.md)
            .padding(.vertical, AppConstants.Spacing.smMd)

            if !isLast {
                Divider()
                    .padding(.leading, AppConstants.Spacing.md)
            }
        }
    }

    private var dayTitle: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(daily.date)     { return "Hoy" }
        if calendar.isDateInYesterday(daily.date) { return "Ayer" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale.current
        return formatter.string(from: daily.date).capitalized
    }

    private var daySubtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale.current
        return formatter.string(from: daily.date)
    }

    private var caloriesFormatted: String {
        let kcal = daily.totalCalories
        return kcal.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", kcal)
            : String(format: "%.1f", kcal)
    }

    private var entriesCount: String {
        daily.entries.count == 1 ? "1 alimento" : "\(daily.entries.count) alimentos"
    }
}

// MARK: - Preview

#Preview("Con datos") {
    NavigationStack {
        LogView(
            viewModel: LogViewModel(
                getTodayEntriesUseCase: PreviewGetTodayEntriesUseCase(),
                getWeeklyEntriesUseCase: PreviewGetWeeklyEntriesUseCase()
            )
        )
    }
}

#Preview("Sin registros") {
    NavigationStack {
        LogView(
            viewModel: LogViewModel(
                getTodayEntriesUseCase: PreviewGetTodayEntriesUseCase(isEmpty: true),
                getWeeklyEntriesUseCase: PreviewGetWeeklyEntriesUseCase(isEmpty: true)
            )
        )
    }
}

// MARK: - Preview Helpers

private struct PreviewGetTodayEntriesUseCase: GetTodayEntriesUseCaseProtocol {
    let isEmpty: Bool
    init(isEmpty: Bool = false) { self.isEmpty = isEmpty }

    func execute() async throws -> [LogEntry] {
        guard !isEmpty else { return [] }
        let avocado = Food(
            id: 171705, name: "Aguacate", dataType: .foundation, brand: nil,
            nutrients: Food.Nutrients(calories: 160, protein: 2, fat: 14.66, carbs: 8.53, fiber: 6.7, sugar: 0.66, sodium: 7)
        )
        let almond = Food(
            id: 170567, name: "Mantequilla de almendra", dataType: .branded, brand: "Whole Foods",
            nutrients: Food.Nutrients(calories: 614, protein: 21, fat: 56, carbs: 19, fiber: 11, sugar: 4, sodium: 7)
        )
        return [
            LogEntry(id: UUID(), food: avocado, grams: 150, loggedAt: Date()),
            LogEntry(id: UUID(), food: almond,  grams: 30,  loggedAt: Date().addingTimeInterval(-3600))
        ]
    }
}

private struct PreviewGetWeeklyEntriesUseCase: GetWeeklyEntriesUseCaseProtocol {
    let isEmpty: Bool
    init(isEmpty: Bool = false) { self.isEmpty = isEmpty }

    func execute() async throws -> [LogEntry] {
        guard !isEmpty else { return [] }
        let avocado = Food(
            id: 171705, name: "Aguacate", dataType: .foundation, brand: nil,
            nutrients: Food.Nutrients(calories: 160, protein: 2, fat: 14.66, carbs: 8.53, fiber: nil, sugar: nil, sodium: nil)
        )
        let calendar = Calendar.current
        var entries: [LogEntry] = []
        for daysAgo in 0..<7 {
            if daysAgo == 2 || daysAgo == 5 { continue } // días sin registros
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            entries.append(LogEntry(id: UUID(), food: avocado, grams: Double(100 + daysAgo * 20), loggedAt: date))
        }
        return entries
    }
}
