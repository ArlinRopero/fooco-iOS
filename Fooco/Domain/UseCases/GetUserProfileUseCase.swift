// MARK: - GetUserProfileUseCase.swift

import Foundation

// MARK: - GetUserProfileUseCaseProtocol

protocol GetUserProfileUseCaseProtocol: Sendable {
    func execute() async throws -> UserProfile?
}

// MARK: - GetUserProfileUseCase

struct GetUserProfileUseCase: GetUserProfileUseCaseProtocol {

    private let repository: any UserProfileRepositoryProtocol

    init(repository: any UserProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> UserProfile? {
        try await repository.getProfile()
    }
}
