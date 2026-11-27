import XCTest

/// L'audit d'accessibilité automatique d'Apple est désactivé, à la demande d'Adrien (27 novembre 2026).
/// Les tests d'interface parcourent toujours les mêmes écrans, mais ne lancent plus l'audit.
/// Pour le relancer à la main, passer `actif` à `true` : chaque défaut est alors écrit dans le journal,
/// avec l'élément concerné et sa position. Ce que l'audit a relevé est noté dans docs/rapports/lot-4.md.
enum AuditDAccessibilite {
    static let actif = false
}

extension XCUIApplication {
    /// Lance l'audit d'accessibilité d'Apple sur l'écran courant, s'il est activé.
    /// Tous les défauts d'un écran sont relevés d'un coup, puis le test échoue s'il y en a.
    @MainActor
    func auditer(_ ecran: String, fichier: StaticString = #filePath, ligne: UInt = #line) throws {
        guard AuditDAccessibilite.actif else { return }

        nonisolated(unsafe) var defauts: [String] = []
        try performAccessibilityAudit { defaut in
            // L'audit appelle ce bloc sur le fil principal.
            let element = MainActor.assumeIsolated {
                defaut.element.map {
                    let cadre = $0.frame
                    return "type \($0.elementType.rawValue), libellé « \($0.label) », identifiant « \($0.identifier) », "
                        + "cadre x=\(Int(cadre.minX)) y=\(Int(cadre.minY)) l=\(Int(cadre.width)) h=\(Int(cadre.height))"
                } ?? "élément inconnu"
            }
            defauts.append("\(defaut.compactDescription) | \(element) | \(defaut.detailedDescription)")
            return true
        }
        let ecranEntier = windows.firstMatch.frame
        if !defauts.isEmpty {
            print("AUDIT [\(ecran)] écran de \(Int(ecranEntier.width)) sur \(Int(ecranEntier.height)) points")
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
