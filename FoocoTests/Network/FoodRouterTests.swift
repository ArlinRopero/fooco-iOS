// MARK: - FoodRouterTests.swift
//
// ¿Qué probamos aquí?
// Que FoodRouter construye URLRequests correctos para cada endpoint.
// Estos tests no tocan la red — solo verifican que la lógica de
// construcción de URLs y parámetros es la esperada.
//
// Son los tests más importantes de la capa de red porque si el Router
// construye una URL mal, todos los demás tests pasan pero la app falla.

import Testing
import Foundation
@testable import Fooco

@Suite("FoodRouter")
struct FoodRouterTests {

    // MARK: - baseURL

    @Test("search usa la baseURL de USDA")
    func searchUsesUSDABaseURL() {
        let router = FoodRouter.search(query: "apple")
        #expect(router.baseURL == "https://api.nal.usda.gov/fdc/v1")
    }

    @Test("detail usa la baseURL de USDA")
    func detailUsesUSDABaseURL() {
        let router = FoodRouter.detail(fdcId: 123)
        #expect(router.baseURL == "https://api.nal.usda.gov/fdc/v1")
    }

    // MARK: - path

    @Test("search tiene el path correcto")
    func searchHasCorrectPath() {
        let router = FoodRouter.search(query: "apple")
        #expect(router.path == "/foods/search")
    }

    @Test("detail incluye el fdcId en el path")
    func detailIncludesFdcIdInPath() {
        // Arrange
        let fdcId = 748967

        // Act
        let router = FoodRouter.detail(fdcId: fdcId)

        // Assert — el ID debe estar en el path, no como query param
        #expect(router.path == "/food/\(fdcId)")
    }

    // MARK: - method

    @Test("search usa GET")
    func searchUsesGet() {
        #expect(FoodRouter.search(query: "rice").method == .get)
    }

    @Test("detail usa GET")
    func detailUsesGet() {
        #expect(FoodRouter.detail(fdcId: 1).method == .get)
    }

    // MARK: - parameters

    @Test("search incluye el query en los parámetros")
    func searchIncludesQuery() {
        // Arrange
        let query = "brown rice"

        // Act
        let params = FoodRouter.search(query: query).parameters

        // Assert
        #expect(params?["query"] as? String == query)
    }

    @Test("search incluye pageSize por defecto (20)")
    func searchIncludesDefaultPageSize() {
        let params = FoodRouter.search(query: "apple").parameters
        #expect(params?["pageSize"] as? Int == 20)
    }

    @Test("search respeta el pageSize personalizado")
    func searchRespectsCustomPageSize() {
        let params = FoodRouter.search(query: "apple", pageSize: 50).parameters
        #expect(params?["pageSize"] as? Int == 50)
    }

    @Test("search incluye dataType en los parámetros")
    func searchIncludesDataType() {
        let params = FoodRouter.search(query: "apple").parameters
        #expect(params?["dataType"] != nil)
    }

    @Test("detail no tiene parámetros")
    func detailHasNoParameters() {
        // El fdcId va en el path, no en query params
        #expect(FoodRouter.detail(fdcId: 123).parameters == nil)
    }

    // MARK: - asURLRequest

    @Test("search construye una URL válida")
    func searchBuildsValidURL() async throws {
        // Arrange
        let router = FoodRouter.search(query: "avocado")

        // Act
        let request = try await router.asURLRequest()

        // Assert
        #expect(request.url != nil)
        #expect(request.url?.host == "api.nal.usda.gov")
        #expect(request.url?.path == "/fdc/v1/foods/search")
    }

    @Test("search incluye query como query param en la URL")
    func searchIncludesQueryInURL() async throws {
        // Arrange
        let router = FoodRouter.search(query: "avocado")

        // Act
        let request = try await router.asURLRequest()
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
        let queryParam = components?.queryItems?.first(where: { $0.name == "query" })

        // Assert
        #expect(queryParam?.value == "avocado")
    }

    @Test("detail construye una URL válida con fdcId en el path")
    func detailBuildsValidURL() async throws {
        // Arrange
        let fdcId = 748967
        let router = FoodRouter.detail(fdcId: fdcId)

        // Act
        let request = try await router.asURLRequest()

        // Assert
        #expect(request.url?.path.contains("\(fdcId)") == true)
    }

    @Test("httpMethod del URLRequest es GET")
    func urlRequestMethodIsGET() async throws {
        let request = try await FoodRouter.search(query: "apple").asURLRequest()
        #expect(request.httpMethod == "GET")
    }
}
