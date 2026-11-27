import XCTest

extension XCUIApplication {
    /// Le champ de recherche de l'accueil, quel que soit son type pour XCUITest.
    @MainActor
    var champDeRecherche: XCUIElement {
        descendants(matching: .any).matching(identifier: "champ-recherche").firstMatch
    }

    /// Lance l'audit d'accessibilité d'Apple et écrit chaque défaut dans le journal, avec l'élément concerné.
    /// Tous les défauts d'un écran sont relevés d'un coup, puis le test échoue s'il y en a.
    /// Les lignes « AUDIT » se retrouvent dans le résumé de l'intégration continue.
    @MainActor
    func auditer(_ ecran: String, fichier: StaticString = #filePath, ligne: UInt = #line) throws {
        nonisolated(unsafe) var defauts: [String] = []
        try performAccessibilityAudit { defaut in
            // L'audit appelle ce bloc sur le fil principal.
            let element = MainActor.assumeIsolated {
                defaut.element.map { "type \($0.elementType.rawValue), libellé « \($0.label) », identifiant « \($0.identifier) »" }
                    ?? "élément inconnu"
            }
            defauts.append("\(defaut.compactDescription) | \(element) | \(defaut.detailedDescription)")
            return true
        }
        for defaut in defauts {
            print("AUDIT [\(ecran)] \(defaut)")
        }
        XCTAssertTrue(
            defauts.isEmpty,
            "Audit d'accessibilité, écran « \(ecran) » : \(defauts.count) défaut(s). \(defauts.joined(separator: " /// "))",
            file: fichier,
            line: ligne
        )
    }
}
