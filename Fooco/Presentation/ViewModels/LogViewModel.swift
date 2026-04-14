// MARK: - LogViewModel.swift
//
// ViewModel de la pantalla de registro diario.
//
// Responsabilidades:
//   • Cargar los LogEntry de hoy y de la semana.
//   • Exponer totales calculados (calorías, macros) para el resumen de hoy.
//   • Agrupar los registros semanales en DailyLog para la vista.
//
// ¿Por qué DailyLog vive aquí y no en Domain?
// Es una estructura de presentación: agrupa datos para mostrarlos en la UI.
// El dominio solo conoce LogEntry — la agrupación es detalle de la vista.

import Foundation
import Observation

// MARK: - DailyLog

/// Agrupación de registros de un mismo día calendario.
struct DailyLog: Identifiable, Sendable {

    /// Inicio del día (startOfDay) — usado como ID único.
    let date: Date

    /// Registros del día, del más reciente al más antiguo.
    let entries: [LogEntry]

    var id: Date { date }

    var totalCalories: Double { entries.reduce(0) { $0 + $1.calculatedCalories } }
    var totalProtein:  Double { entries.reduce(0) { $0 + $1.calculatedProtein } }
    var totalCarbs:    Double { entries.reduce(0) { $0 + $1.calculatedCarbs } }
    var totalFat:      Double { entries.reduce(0) { $0 + $1.calculatedFat } }
}

// MARK: - LogViewModel

@Observable
@MainActor
final class LogViewModel {

    // MARK: - Estado público

    private(set) var todayEntries: [LogEntry] = []
    private(set) var weeklyDays: [DailyLog] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    // MARK: - Totales de hoy (calculados desde todayEntries)

    var todayCalories: Double { todayEntries.reduce(0) { $0 + $1.calculatedCalories } }
    var todayProtein:  Double { todayEntries.reduce(0) { $0 + $1.calculatedProtein } }
    var todayCarbs:    Double { todayEntries.reduce(0) { $0 + $1.calculatedCarbs } }
    var todayFat:      Double { todayEntries.reduce(0) { $0 + $1.calculatedFat } }

    // MARK: - Dependencias

    private let getTodayEntriesUseCase: any GetTodayEntriesUseCaseProtocol
    private let getWeeklyEntriesUseCase: any GetWeeklyEntriesUseCaseProtocol

    // MARK: - Init

    init(
        getTodayEntriesUseCase: any GetTodayEntriesUseCaseProtocol,
        getWeeklyEntriesUseCase: any GetWeeklyEntriesUseCaseProtocol
    ) {
        self.getTodayEntriesUseCase  = getTodayEntriesUseCase
        self.getWeeklyEntriesUseCase = getWeeklyEntriesUseCase
    }

    // MARK: - Carga

    /// Carga los registros de hoy y de la semana en paralelo.
    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let today   = getTodayEntriesUseCase.execute()
            async let weekly  = getWeeklyEntriesUseCase.execute()

            let (todayResult, weeklyResult) = try await (today, weekly)

            todayEntries = todayResult
            weeklyDays   = groupByDay(weeklyResult)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Helpers privados

    /// Agrupa un array plano de LogEntry en DailyLog por día calendario.
    ///
    /// El resultado incluye solo días con al menos un registro,
    /// ordenados del más reciente al más antiguo.
    private func groupByDay(_ entries: [LogEntry]) -> [DailyLog] {
        let calendar = Calendar.current
        var byDay: [Date: [LogEntry]] = [:]

        for entry in entries {
            let day = calendar.startOfDay(for: entry.loggedAt)
            byDay[day, default: []].append(entry)
        }

        return byDay
            .map { DailyLog(date: $0.key, entries: $0.value) }
            .sorted { $0.date > $1.date }
    }
}
