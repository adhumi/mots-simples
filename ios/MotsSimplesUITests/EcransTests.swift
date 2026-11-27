import XCTest

/// Audit d'accessibilité automatique sur chaque écran du lot 4, et captures aux plus grandes tailles de texte.
final class EcransTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func lancer(tailleDeTexte: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        if let tailleDeTexte {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", tailleDeTexte]
        }
        app.launch()
        XCTAssertTrue(app.champDeRecherche.waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    private func ouvrirLesThemes(_ app: XCUIApplication) {
        let bouton = app.buttons["voir-les-themes"]
        XCTAssertTrue(bouton.waitForExistence(timeout: 5))
        bouton.tap()
        XCTAssertTrue(app.buttons["theme-argent"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func chercher(_ app: XCUIApplication, _ texte: String) {
        let champ = app.champDeRecherche
        champ.tap()
        champ.typeText(texte)
    }

    @MainActor
    func testAuditDesThemes() throws {
        let app = lancer()
        ouvrirLesThemes(app)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'theme-'")).count, 8)
        try app.auditer("testAuditDesThemes-1")
    }

    @MainActor
    func testAuditDUnTheme() throws {
        let app = lancer()
        ouvrirLesThemes(app)
        app.buttons["theme-argent"].tap()
        XCTAssertTrue(app.buttons["mot-facture"].waitForExistence(timeout: 5))
        try app.auditer("testAuditDUnTheme-1")
    }

    /// Depuis la liste d'un thème comme depuis la grille, « Retour » ramène à l'accueil.
    @MainActor
    func testRetourRameneALAccueil() {
        let app = lancer()
        ouvrirLesThemes(app)
        app.buttons["theme-sante"].tap()
        XCTAssertTrue(app.buttons["mot-ordonnance"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.champDeRecherche.waitForExistence(timeout: 5))
    }

    @MainActor
    func testAuditDuMotAbsent() throws {
        let app = lancer()
        // « Rechercher » range le clavier : l'audit porte sur l'écran de l'app, pas sur le clavier du système.
        chercher(app, "girafe\n")
        XCTAssertTrue(app.staticTexts["Ce mot n'est pas encore dans le dictionnaire."].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["demander-ce-mot"].exists)
        XCTAssertFalse(app.keyboards.firstMatch.exists)
        try app.auditer("testAuditDuMotAbsent-1")
    }

    /// Un texte qui n'est pas un mot ne peut pas partir : le bouton n'apparaît pas.
    @MainActor
    func testUnNumeroNePeutPasEtreDemande() {
        let app = lancer()
        chercher(app, "0612345678")
        XCTAssertTrue(app.staticTexts["Ce mot n'est pas encore dans le dictionnaire."].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["demander-ce-mot"].exists)
    }

    @MainActor
    func testAuditDeLAide() throws {
        let app = lancer()
        let aide = app.buttons["aide"]
        XCTAssertTrue(aide.waitForExistence(timeout: 5))
        aide.tap()
        XCTAssertTrue(app.buttons["vitesse-lente"].waitForExistence(timeout: 5))
        try app.auditer("testAuditDeLAide-1")
        app.buttons["vitesse-lente"].tap()
        XCTAssertTrue(app.buttons["vitesse-lente"].isSelected)
        app.buttons["vitesse-normale"].tap()
    }

    @MainActor
    func testLaFichePeutEtrePartagee() {
        let app = lancer()
        chercher(app, "facture")
        app.buttons["mot-facture"].firstMatch.tap()
        XCTAssertTrue(app.buttons["partager"].waitForExistence(timeout: 5))
    }

    /// Captures aux plus grandes tailles de texte, en clair et en sombre. À lancer sur iPhone et sur iPad.
    /// Les images sont jointes au résultat du test, dans Xcode.
    @MainActor
    func testCapturesAuxGrandesTailles() throws {
        for (nom, apparence) in [("clair", XCUIDevice.Appearance.light), ("sombre", XCUIDevice.Appearance.dark)] {
            XCUIDevice.shared.appearance = apparence
            let app = lancer(tailleDeTexte: "UICTContentSizeCategoryAccessibilityXXXL")
            capturer(app, "accueil-\(nom)")
            try app.auditer("testCapturesAuxGrandesTailles-1")
            ouvrirLesThemes(app)
            capturer(app, "themes-\(nom)")
            try app.auditer("testCapturesAuxGrandesTailles-2")
            app.buttons["theme-logement"].tap()
            XCTAssertTrue(app.buttons["mot-bail"].waitForExistence(timeout: 5))
            capturer(app, "theme-\(nom)")
            app.buttons["mot-bail"].firstMatch.tap()
            XCTAssertTrue(app.staticTexts["fiche-mot"].waitForExistence(timeout: 5))
            capturer(app, "fiche-\(nom)")
            try app.auditer("testCapturesAuxGrandesTailles-3")
            app.terminate()
        }
        XCUIDevice.shared.appearance = .light
    }

    @MainActor
    private func capturer(_ app: XCUIApplication, _ nom: String) {
        let piece = XCTAttachment(screenshot: app.screenshot())
        piece.name = nom
        piece.lifetime = .keepAlways
        add(piece)
    }

    /// Toutes les orientations : la fiche reste utilisable couchée.
    @MainActor
    func testOrientationPaysage() throws {
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = lancer()
        chercher(app, "facture")
        app.buttons["mot-facture"].firstMatch.tap()
        XCTAssertTrue(app.buttons["tout-ecouter"].waitForExistence(timeout: 5))
        try app.auditer("testOrientationPaysage-1")
    }
}
