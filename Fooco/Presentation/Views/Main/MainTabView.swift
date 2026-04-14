// MARK: - MainTabView.swift
//
// Estructura principal de navegación de Fooco.
//
// 4 tabs según el PRD:
//   Biblioteca   → buscar y explorar alimentos
//   Registro     → log diario de comidas (próximamente)
//   Estadísticas → gráficas y progreso (próximamente)
//   Perfil       → configuración y cuenta (próximamente)
//
// ¿Por qué TabView y no NavigationSplitView?
// Fooco es una app móvil con flujos independientes por tab.
// TabView es el patrón correcto para iOS según HIG de Apple.
// NavigationSplitView es para iPad/Mac con panel lateral.

import SwiftUI

// MARK: - MainTabView

struct MainTabView: View {

    // MARK: - Dependencias

    /// Repositorio de log inyectado desde FoocoApp.
    /// Es `any FoodLogRepositoryProtocol` para permitir mocks en previews.
    let logRepository: any FoodLogRepositoryProtocol

    /// Repositorio de perfil inyectado desde FoocoApp.
    let profileRepository: any UserProfileRepositoryProtocol

    // MARK: - Estado

    /// Tab actualmente seleccionada.
    @State private var selectedTab: Tab = .library

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: Biblioteca
            NavigationStack {
                SearchView(
                    viewModel: SearchViewModel(
                        searchUseCase: SearchFoodUseCase(
                            repository: FoodRepository()
                        ),
                        translator: AppleQueryTranslator(),
                        frequentFoodsUseCase: GetFrequentFoodsUseCase(
                            repository: logRepository
                        ),
                        logFoodUseCase: LogFoodUseCase(
                            repository: logRepository
                        ),
                        foodNameTranslator: AppleFoodNameTranslator()
                    )
                )
            }
            .tabItem {
                Label("tab.library", systemImage: "magnifyingglass")
            }
            .tag(Tab.library)

            // MARK: Registro
            NavigationStack {
                LogView(
                    viewModel: LogViewModel(
                        getTodayEntriesUseCase: GetTodayEntriesUseCase(
                            repository: logRepository
                        ),
                        getWeeklyEntriesUseCase: GetWeeklyEntriesUseCase(
                            repository: logRepository
                        )
                    )
                )
            }
            .tabItem {
                Label("tab.log", systemImage: "fork.knife")
            }
            .tag(Tab.log)

            // MARK: Estadísticas (placeholder)
            NavigationStack {
                ComingSoonView(title: "tab.stats", icon: "chart.bar.fill")
            }
            .tabItem {
                Label("tab.stats", systemImage: "chart.bar.fill")
            }
            .tag(Tab.stats)

            // MARK: Perfil
            NavigationStack {
                ProfileMenuView(
                    viewModel: ProfileViewModel(
                        getProfileUseCase: GetUserProfileUseCase(
                            repository: profileRepository
                        ),
                        saveProfileUseCase: SaveUserProfileUseCase(
                            repository: profileRepository
                        )
                    )
                )
            }
            .tabItem {
                Label("tab.profile", systemImage: "person.fill")
            }
            .tag(Tab.profile)
        }
        .tint(AppColors.primary)
    }
}

// MARK: - Tab

private extension MainTabView {

    /// Identificadores de cada tab para el binding de selección.
    enum Tab {
        case library, log, stats, profile
    }
}

// MARK: - ComingSoonView
//
// Placeholder para tabs que aún no están implementadas.
// Se reemplaza por la View real cuando esté lista.

private struct ComingSoonView: View {

    let title: LocalizedStringKey
    let icon: String

    var body: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: AppConstants.IconSize.xxl))
                .foregroundStyle(AppColors.primary.opacity(0.4))

            Text(title)
                .font(.system(size: AppConstants.FontSize.title3, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text("coming.soon")
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

// MARK: - Preview

#Preview {
    MainTabView(
        logRepository: PreviewFoodLogRepository(),
        profileRepository: PreviewUserProfileRepository()
    )
}

// MARK: - Preview Mocks

private final class PreviewFoodLogRepository: FoodLogRepositoryProtocol, @unchecked Sendable {
    func logFood(_ food: Food, grams: Double) async throws {}
    func getFrequentFoods(limit: Int) async throws -> [Food] { [] }
    func getTodayEntries() async throws -> [LogEntry] { [] }
    func getEntries(from startDate: Date, to endDate: Date) async throws -> [LogEntry] { [] }
}

private final class PreviewUserProfileRepository: UserProfileRepositoryProtocol, @unchecked Sendable {
    func getProfile() async throws -> UserProfile? { nil }
    func saveProfile(_ profile: UserProfile) async throws {}
}
