// MARK: - FirestoreFoodLogRepository.swift
//
// Implementación Firestore de FoodLogRepositoryProtocol.
//
// Ruta de documentos:
//   users/{uid}/foodLogs/{logId}
//
// Freemium — retención de datos:
//   Free    → 7 días  → deleteAt = loggedAt + 7d
//   Premium → 30 días → deleteAt = loggedAt + 30d
//
//   Configurar TTL en Firebase Console:
//   Firestore → Configuración → TTL → Colección: foodLogs → Campo: deleteAt
//
// Índices necesarios (ver firestore.indexes.json):
//   foodLogs: loggedAt ASC/DESC  (para historial semanal)
//   foodLogs: loggedAt DESC + calculatedCalories (para analytics)

import FirebaseFirestore
import FirebaseAuth
import Foundation

// MARK: - FirestoreFoodLogRepository

final class FirestoreFoodLogRepository: FoodLogRepositoryProtocol {

    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    // MARK: - FoodLogRepositoryProtocol

    func logFood(_ food: Food, grams: Double) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirestoreRepositoryError.notAuthenticated
        }

        let retention = await retentionDays(for: uid)
        let entry = LogEntry(id: UUID(), food: food, grams: grams, loggedAt: Date())
        let dto = FirestoreFoodLogDTO(from: entry, retentionDays: retention)

        try foodLogsRef(uid: uid).document().setData(from: dto)
    }

    func getFrequentFoods(limit: Int) async throws -> [Food] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        // Trae los últimos 200 logs para calcular frecuencia en cliente
        // (Firestore no soporta GROUP BY nativo)
        let snapshot = try await foodLogsRef(uid: uid)
            .order(by: "loggedAt", descending: true)
            .limit(to: 200)
            .getDocuments()

        var frequency: [Int: (food: Food, count: Int)] = [:]
        for doc in snapshot.documents {
            guard let dto = try? doc.data(as: FirestoreFoodLogDTO.self) else { continue }
            let entry = dto.toDomain()
            let food = entry.food
            frequency[food.id] = (food, (frequency[food.id]?.count ?? 0) + 1)
        }

        return frequency.values
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map(\.food)
    }

    func getTodayEntries() async throws -> [LogEntry] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        return try await getEntries(from: start, to: end)
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [LogEntry] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let snapshot = try await foodLogsRef(uid: uid)
            .whereField("loggedAt", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("loggedAt", isLessThan: Timestamp(date: endDate))
            .order(by: "loggedAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FirestoreFoodLogDTO.self)
        }.map { $0.toDomain() }
    }

    // MARK: - Helpers privados

    private func foodLogsRef(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("foodLogs")
    }

    /// Lee el perfil para determinar cuántos días de retención aplican.
    /// Si no se puede leer el perfil, usa el mínimo (7 días, Free).
    private func retentionDays(for uid: String) async -> Int {
        let ref = db.collection("users").document(uid)
            .collection("profile").document("data")
        guard let doc = try? await ref.getDocument(),
              let tierStr = doc.data()?["subscriptionTier"] as? String,
              let tier = SubscriptionTier(rawValue: tierStr),
              tier == .premium
        else { return 7 }

        // Verifica que la suscripción no haya expirado
        if let expires = doc.data()?["subscriptionExpiresAt"] as? Timestamp,
           expires.dateValue() < Date() {
            return 7
        }
        return 30
    }
}
