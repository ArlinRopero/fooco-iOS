// MARK: - MockUserProfileRepository.swift

import Foundation
@testable import Fooco

// MARK: - MockUserProfileRepository

final class MockUserProfileRepository: UserProfileRepositoryProtocol, @unchecked Sendable {

    var storedProfile: UserProfile?
    var error: Error?

    private(set) var getCallCount  = 0
    private(set) var saveCallCount = 0
    private(set) var lastSavedProfile: UserProfile?

    func getProfile() async throws -> UserProfile? {
        getCallCount += 1
        if let error { throw error }
        return storedProfile
    }

    func saveProfile(_ profile: UserProfile) async throws {
        saveCallCount += 1
        if let error { throw error }
        lastSavedProfile = profile
        storedProfile = profile
    }
}
