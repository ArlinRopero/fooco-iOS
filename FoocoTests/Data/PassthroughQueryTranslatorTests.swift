// MARK: - PassthroughQueryTranslatorTests.swift

import Testing
import Foundation
@testable import Fooco

@Suite("PassthroughQueryTranslator")
struct PassthroughQueryTranslatorTests {

    private let sut = PassthroughQueryTranslator()

    @Test("Devuelve la query sin modificar")
    func returnsQueryUnchanged() async {
        let result = await sut.translateToEnglish("pollo asado")
        #expect(result == "pollo asado")
    }

    @Test("Devuelve query vacía sin crash")
    func handlesEmptyQuery() async {
        let result = await sut.translateToEnglish("")
        #expect(result == "")
    }

    @Test("Devuelve queries en inglés sin modificar")
    func returnsEnglishQueryUnchanged() async {
        let result = await sut.translateToEnglish("roasted chicken")
        #expect(result == "roasted chicken")
    }

    @Test("Devuelve queries con caracteres especiales sin crash")
    func handlesSpecialCharacters() async {
        let result = await sut.translateToEnglish("fríjoles con chicharrón")
        #expect(result == "fríjoles con chicharrón")
    }
}
