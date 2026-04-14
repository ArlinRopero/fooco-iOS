// MARK: - SearchView.swift
//
// Pantalla principal de búsqueda de la biblioteca de alimentos.
//
// Estados que maneja:
//   .idle     → pantalla de bienvenida con sugerencias
//   .loading  → skeleton mientras carga
//   .results  → lista de resultados
//   .empty    → sin resultados para la query
//   .error    → algo falló
//
// ¿Por qué @State para el viewModel y no @Environment?
// SearchView es el "dueño" del ViewModel — lo crea y lo posee.
// @Environment es para compartir un objeto entre muchas views sin
// pasarlo explícitamente. Aquí no necesitamos eso.
//
// ¿Por qué navigationDestination en lugar de NavigationLink con destination?
// navigationDestination es la API moderna de iOS 16+.
// Separa la navegación del contenido — más limpio y testeable.

import SwiftUI
import Translation

// MARK: - SearchView

struct SearchView: View {

    // MARK: - ViewModel

    @State var viewModel: SearchViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
                    .padding(.top, AppConstants.Spacing.sm)
                    .padding(.bottom, AppConstants.Spacing.md)

                stateContent
            }
        }
        .navigationTitle("search.title")
        .navigationBarTitleDisplayMode(.large)
        // Traductor 1: idioma del dispositivo → inglés (query del usuario)
        .translationTask(
            (viewModel.translator as? AppleQueryTranslator)?.configuration
        ) { session in
            await (viewModel.translator as? AppleQueryTranslator)?.performTranslation(using: session)
        }
        // Traductor 2: inglés → idioma del dispositivo (nombres de resultados)
        .translationTask(
            (viewModel.foodNameTranslator as? AppleFoodNameTranslator)?.configuration
        ) { session in
            await (viewModel.foodNameTranslator as? AppleFoodNameTranslator)?.performTranslation(using: session)
        }
        .navigationDestination(for: Food.self) { food in
            FoodDetailView(
                viewModel: FoodDetailViewModel(
                    food: food,
                    getFullDetailUseCase: GetFoodDetailUseCase(
                        repository: FoodRepository()
                    ),
                    logFoodUseCase: viewModel.logFoodUseCase
                )
            )
        }
        .onAppear {
            Task { await viewModel.loadFrequentFoods() }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: AppConstants.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: AppConstants.IconSize.md, height: AppConstants.IconSize.md)

            TextField("search.placeholder", text: $viewModel.query)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundStyle(AppColors.textPrimary)
                .submitLabel(.search)
                .onSubmit {
                    Task { await viewModel.search() }
                }

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.clear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, AppConstants.Spacing.md)
        .frame(height: AppConstants.ComponentSize.searchBarHeight)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.pill))
    }

    // MARK: - State Content
    //
    // Switch sobre el estado del ViewModel.
    // Cada estado tiene su propia View — nunca booleanos anidados.

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.state {
        case .idle:
            idleView
        case .loading:
            loadingView
        case .results:
            resultsList
        case .empty:
            emptyView
        case .error(let message):
            errorView(message: message)
        }
    }

    // MARK: - Idle

    private var idleView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xl) {

                // Frecuentes — solo si hay historial
                if !viewModel.frequentFoods.isEmpty {
                    frequentFoodsSection
                }

                // Sugerencias rápidas — siempre visibles
                suggestionsSection

                // Placeholder solo si no hay frecuentes (primera vez)
                if viewModel.frequentFoods.isEmpty {
                    emptyHeroPlaceholder
                }
            }
            .padding(.top, AppConstants.Spacing.md)
            .padding(.bottom, AppConstants.Spacing.xxxl)
        }
    }

    // MARK: - Frecuentes

    private var frequentFoodsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            Text("search.frequent.title")
                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, AppConstants.Spacing.screenHorizontal)

            LazyVStack(spacing: AppConstants.Spacing.sm) {
                ForEach(viewModel.frequentFoods) { food in
                    NavigationLink(value: food) {
                        FoodRowView(food: food)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
                }
            }
        }
    }

    // MARK: - Sugerencias

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            Text("search.suggestions.title")
                .font(.system(size: AppConstants.FontSize.footnote, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, AppConstants.Spacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppConstants.Spacing.sm) {
                    ForEach(SearchView.suggestions, id: \.self) { suggestion in
                        Button {
                            viewModel.query = suggestion
                            Task { await viewModel.search() }
                        } label: {
                            Text(suggestion)
                                .font(.system(size: AppConstants.FontSize.footnote, weight: .medium))
                                .foregroundStyle(AppColors.primary)
                                .padding(.horizontal, AppConstants.Spacing.md)
                                .padding(.vertical, AppConstants.Spacing.sm)
                                .background(AppColors.primary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.pill))
                        }
                    }
                }
                .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
            }
        }
    }

    // MARK: - Placeholder inicial (sin historial)

    private var emptyHeroPlaceholder: some View {
        VStack(spacing: AppConstants.Spacing.md) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.primary.opacity(0.12))

            Text("search.idle.title")
                .font(.system(size: AppConstants.FontSize.title3, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text("search.idle.subtitle")
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.Spacing.xl)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppConstants.Spacing.xl)
    }

    // MARK: - Loading (Skeleton)

    private var loadingView: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.Spacing.sm) {
                ForEach(0..<6, id: \.self) { _ in
                    FoodRowSkeleton()
                }
            }
            .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
            .padding(.top, AppConstants.Spacing.sm)
        }
    }

    // MARK: - Results (con scroll infinito)

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.Spacing.sm) {
                ForEach(viewModel.foods) { food in
                    NavigationLink(value: food) {
                        FoodRowView(food: food)
                    }
                    .buttonStyle(.plain)
                }

                // Sentinel de scroll infinito — visible cuando hay más páginas
                if viewModel.canLoadMore {
                    ProgressView()
                        .tint(AppColors.primary)
                        .padding(.vertical, AppConstants.Spacing.md)
                        .onAppear {
                            Task { await viewModel.loadMore() }
                        }
                }
            }
            .padding(.horizontal, AppConstants.Spacing.screenHorizontal)
            .padding(.top, AppConstants.Spacing.sm)
            .padding(.bottom, AppConstants.Spacing.xxl)
        }
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: AppConstants.Spacing.md) {
            Spacer()

            Image(systemName: "tray")
                .font(.system(size: AppConstants.IconSize.xxl))
                .foregroundStyle(AppColors.textDisabled)

            Text("search.empty.title")
                .font(.system(size: AppConstants.FontSize.title3, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text(localized(StringKey.Search.emptySubtitle, args: viewModel.query))
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.Spacing.xl)

            Spacer()
        }
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: AppConstants.Spacing.md) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: AppConstants.IconSize.xxl))
                .foregroundStyle(AppColors.error.opacity(0.7))

            Text("search.error.title")
                .font(.system(size: AppConstants.FontSize.title3, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.Spacing.xl)

            Button {
                Task { await viewModel.search() }
            } label: {
                Text("search.error.retry")
                    .font(.system(size: AppConstants.FontSize.callout, weight: .semibold))
                    .foregroundStyle(AppColors.textOnColor)
                    .frame(height: AppConstants.ComponentSize.buttonHeight)
                    .padding(.horizontal, AppConstants.Spacing.xl)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.Radius.md))
            }

            Spacer()
        }
    }
}

// MARK: - Sugerencias de búsqueda

private extension SearchView {
    static let suggestions = [
        "Aguacate", "Arroz", "Pollo", "Frijoles",
        "Plátano", "Huevo", "Arepa", "Quinoa"
    ]
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SearchView(
            viewModel: SearchViewModel(
                searchUseCase: SearchFoodUseCase(
                    repository: FoodRepository()
                )
            )
        )
    }
}
