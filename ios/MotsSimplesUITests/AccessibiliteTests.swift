import XCTest

/// Audit d'accessibilité automatique d'Apple, sur l'accueil et sur une fiche.
/// L'audit vérifie entre autres : libellés, contraste, tailles de texte, cibles tactiles, texte coupé.
final class AccessibiliteTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Ferme l'app à la fin de chaque test et attend qu'elle soit vraiment arrêtée.
    /// Sans cela, le test suivant échoue parfois à son lancement : « Failed to terminate ».
    @MainActor
    override func tearDown() async throws {
        let app = XCUIApplication()
        if app.state != .notRunning {
            app.terminate()
            _ = app.wait(for: .notRunning, timeout: 30)
        }
    }

    @MainActor
    private func lancer(tailleDeTexte: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        if let tailleDeTexte {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", tailleDeTexte]
        }
        app.launch()
        return app
    }

    @MainActor
    private func ouvrirFacture(_ app: XCUIApplication) {
        let champ = app.textFields["champ-recherche"]
        XCTAssertTrue(champ.waitForExistence(timeout: 5))
        champ.tap()                                   // toucher 1
        champ.typeText("facture")
        let resultat = app.buttons["mot-facture"].firstMatch
        XCTAssertTrue(resultat.waitForExistence(timeout: 5))
        resultat.tap()                                // toucher 2
        XCTAssertTrue(app.staticTexts["fiche-mot"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAuditDeLAccueil() throws {
        let app = lancer()
        XCTAssertTrue(app.textFields["champ-recherche"].waitForExistence(timeout: 5))
        try app.auditer("testAuditDeLAccueil-1")
    }

    @MainActor
    func testAuditDUneFiche() throws {
        let app = lancer()
        ouvrirFacture(app)
        try app.auditer("testAuditDUneFiche-1")
    }

    @MainActor
    func testAuditALaPlusGrandeTailleDeTexte() throws {
        let app = lancer(tailleDeTexte: "UICTContentSizeCategoryAccessibilityXXXL")
        try app.auditer("testAuditALaPlusGrandeTailleDeTexte-1")
        ouvrirFacture(app)
        try app.auditer("testAuditALaPlusGrandeTailleDeTexte-2")
    }

    /// Du lancement à une fiche : deux touchers, hors saisie. Le critère en demande trois au plus.
    @MainActor
    func testDuLancementAUneFiche() {
        let app = lancer()
        ouvrirFacture(app)
        XCTAssertTrue(app.buttons["tout-ecouter"].exists)
    }

    @MainActor
    func testToutEcouterDevientArreter() {
        let app = lancer()
        ouvrirFacture(app)
        let bouton = app.buttons["tout-ecouter"]
        bouton.tap()
        XCTAssertEqual(bouton.label, "Arrêter")
        bouton.tap()
        XCTAssertEqual(bouton.label, "Tout écouter")
    }

    @MainActor
    func testMotAbsent() {
        let app = lancer()
        let champ = app.textFields["champ-recherche"]
        XCTAssertTrue(champ.waitForExistence(timeout: 5))
        champ.tap()
        champ.typeText("girafe")
        XCTAssertTrue(app.staticTexts["Ce mot n'est pas encore dans le dictionnaire."].waitForExistence(timeout: 5))
    }
}
