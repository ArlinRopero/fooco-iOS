// MARK: - SaveUserProfileUseCase.swift

import Foundation

// MARK: - SaveUserProfileUseCaseProtocol

protocol SaveUserProfileUseCaseProtocol: Sendable {
    func execute(_ profile: UserProfile) async throws
}

// MARK: - SaveUserProfileUseCase

struct SaveUserProfileUseCase: SaveUserProfileUseCaseProtocol {

    private let repository: any UserProfileRepositoryProtocol

    init(repository: any UserProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ profile: UserProfile) async throws {
        try await repository.saveProfile(profile)
    }
}
