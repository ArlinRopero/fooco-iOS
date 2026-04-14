// MARK: - ProfileViewModelTests.swift

import Testing
import Foundation
@testable import Fooco

// MARK: - Mocks

private final class MockGetUserProfileUseCase: GetUserProfileUseCaseProtocol, @unchecked Sendable {
    var profile: UserProfile?
    var error: Error?
    private(set) var callCount = 0

    func execute() async throws -> UserProfile? {
        callCount += 1
        if let error { throw error }
        return profile
    }
}

private final class MockSaveUserProfileUseCase: SaveUserProfileUseCaseProtocol, @unchecked Sendable {
    var error: Error?
    private(set) var callCount = 0
    private(set) var savedProfile: UserProfile?

    func execute(_ profile: UserProfile) async throws {
        callCount += 1
        if let error { throw error }
        savedProfile = profile
    }
}

// MARK: - Tests

@Suite("ProfileViewModel")
@MainActor
struct ProfileViewModelTests {

    // MARK: - Setup helpers

    private func makeSUT(
        existingProfile: UserProfile? = nil,
        getError: Error? = nil,
        saveError: Error? = nil
    ) -> (
        sut: ProfileViewModel,
        getUC: MockGetUserProfileUseCase,
        saveUC: MockSaveUserProfileUseCase
    ) {
        let getUC = MockGetUserProfileUseCase()
        getUC.profile = existingProfile
        getUC.error   = getError

        let saveUC = MockSaveUserProfileUseCase()
        saveUC.error = saveError

        let sut = ProfileViewModel(
            getProfileUseCase:  getUC,
            saveProfileUseCase: saveUC
        )
        return (sut, getUC, saveUC)
    }

    private func makeProfile(
        name: String? = "Ana",
        sex: BiologicalSex = .female,
        birthYear: Int? = 1990,
        weightKg: Double? = 60,
        heightCm: Double? = 165,
        activityLevel: ActivityLevel = .moderatelyActive,
        calorieGoal: Int? = nil,
        conditions: Set<HealthCondition> = [.anemia]
    ) -> UserProfile {
        UserProfile(
            id: UUID(),
            name: name,
            biologicalSex: sex,
            birthYear: birthYear,
            weightKg: weightKg,
            heightCm: heightCm,
            activityLevel: activityLevel,
            dailyCalorieGoal: calorieGoal,
            healthConditions: conditions
        )
    }

    // MARK: - Estado inicial

    @Test("Estado inicial: campos vacíos y sin carga")
    func initialState() {
        let (sut, _, _) = makeSUT()

        #expect(sut.name.isEmpty)
        #expect(sut.biologicalSex == .unspecified)
        #expect(sut.birthYear.isEmpty)
        #expect(sut.weightKg.isEmpty)
        #expect(sut.heightCm.isEmpty)
        #expect(sut.activityLevel == .sedentary)
        #expect(sut.selectedConditions.isEmpty)
        #expect(!sut.isLoading)
        #expect(!sut.isSaving)
        #expect(sut.errorMessage == nil)
    }

    // MARK: - load()

    @Test("load() puebla campos con el perfil guardado")
    func loadPopulatesFields() async {
        let profile = makeProfile()
        let (sut, _, _) = makeSUT(existingProfile: profile)

        await sut.load()

        #expect(sut.name == "Ana")
        #expect(sut.biologicalSex == .female)
        #expect(sut.birthYear == "1990")
        #expect(sut.weightKg == "60")
        #expect(sut.heightCm == "165")
        #expect(sut.activityLevel == .moderatelyActive)
        #expect(sut.selectedConditions == [.anemia])
    }

    @Test("load() con perfil nil deja los campos en blanco")
    func loadWithNoProfileLeavesFieldsEmpty() async {
        let (sut, _, _) = makeSUT(existingProfile: nil)

        await sut.load()

        #expect(sut.name.isEmpty)
        #expect(sut.weightKg.isEmpty)
        #expect(sut.selectedConditions.isEmpty)
    }

    @Test("load() error expone errorMessage")
    func loadErrorSetsErrorMessage() async {
        let (sut, _, _) = makeSUT(getError: URLError(.notConnectedToInternet))

        await sut.load()

        #expect(sut.errorMessage != nil)
    }

    @Test("isLoading es false al terminar load()")
    func isLoadingFalseAfterLoad() async {
        let (sut, _, _) = makeSUT()

        await sut.load()

        #expect(!sut.isLoading)
    }

    // MARK: - save()

    @Test("save() llama al use case con los campos del formulario")
    func saveDelegatesToUseCase() async {
        let (sut, _, saveUC) = makeSUT()
        sut.name        = "Luis"
        sut.biologicalSex = .male
        sut.birthYear   = "1985"
        sut.weightKg    = "75"
        sut.heightCm    = "180"

        await sut.save()

        #expect(saveUC.callCount == 1)
        #expect(saveUC.savedProfile?.name == "Luis")
        #expect(saveUC.savedProfile?.biologicalSex == .male)
        #expect(saveUC.savedProfile?.birthYear == 1985)
        #expect(saveUC.savedProfile?.weightKg == 75)
        #expect(saveUC.savedProfile?.heightCm == 180)
    }

    @Test("save() exitoso activa saveSuccess")
    func saveSuccessSetsFlag() async {
        let (sut, _, _) = makeSUT()

        await sut.save()

        #expect(sut.saveSuccess)
    }

    @Test("save() error expone errorMessage y no activa saveSuccess")
    func saveErrorSetsErrorMessage() async {
        let (sut, _, _) = makeSUT(saveError: URLError(.notConnectedToInternet))

        await sut.save()

        #expect(sut.errorMessage != nil)
        #expect(!sut.saveSuccess)
    }

    @Test("isSaving es false al terminar save()")
    func isSavingFalseAfterSave() async {
        let (sut, _, _) = makeSUT()

        await sut.save()

        #expect(!sut.isSaving)
    }

    // MARK: - toggleCondition()

    @Test("toggleCondition añade condición no seleccionada")
    func toggleConditionAdds() {
        let (sut, _, _) = makeSUT()

        sut.toggleCondition(.anemia)

        #expect(sut.selectedConditions.contains(.anemia))
    }

    @Test("toggleCondition quita condición ya seleccionada")
    func toggleConditionRemoves() {
        let (sut, _, _) = makeSUT()
        sut.selectedConditions = [.anemia, .diabetes2]

        sut.toggleCondition(.anemia)

        #expect(!sut.selectedConditions.contains(.anemia))
        #expect(sut.selectedConditions.contains(.diabetes2))
    }

    // MARK: - filteredConditions

    @Test("filteredConditions retorna todas las condiciones si la búsqueda está vacía")
    func filteredConditionsAllWhenEmpty() {
        let (sut, _, _) = makeSUT()

        #expect(sut.filteredConditions.count == HealthCondition.allCases.count)
    }

    @Test("filteredConditions filtra por texto")
    func filteredConditionsByText() {
        let (sut, _, _) = makeSUT()
        sut.conditionSearchText = "anemia"

        #expect(sut.filteredConditions.contains(.anemia))
        #expect(!sut.filteredConditions.contains(.diabetes2))
    }

    // MARK: - estimatedCalories

    @Test("estimatedCalories es nil sin datos de perfil")
    func estimatedCaloriesNilWithoutData() {
        let (sut, _, _) = makeSUT()

        #expect(sut.estimatedCalories == nil)
    }

    @Test("estimatedCalories calcula el TDEE cuando hay datos completos")
    func estimatedCaloriesCalculatesTDEE() async {
        let (sut, _, _) = makeSUT()
        sut.biologicalSex = .female
        sut.birthYear     = "1990"
        sut.weightKg      = "60"
        sut.heightCm      = "165"
        sut.activityLevel = .sedentary

        let calories = sut.estimatedCalories

        #expect(calories != nil)
        if let calories {
            // 1400-1600 kcal es el rango razonable para mujer sedentaria, 34 años, 60kg, 165cm
            #expect(calories > 1300)
            #expect(calories < 1800)
        }
    }

    // MARK: - Roundtrip load → save

    @Test("load() seguido de save() preserva el mismo ID del perfil")
    func loadThenSavePreservesProfileID() async {
        let original = makeProfile()
        let (sut, _, saveUC) = makeSUT(existingProfile: original)

        await sut.load()
        await sut.save()

        #expect(saveUC.savedProfile?.id == original.id)
    }
}
