import XCTest

/// Mesure des budgets de performance des specs. À lancer sur le plus ancien simulateur ou téléphone disponible.
/// Les chiffres s'affichent dans le rapport de test de Xcode.
final class PerformanceTests: XCTestCase {
    /// Budget : moins de 1 seconde du lancement au champ de recherche utilisable.
    @MainActor
    func testLancement() {
        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            XCUIApplication().launch()
        }
    }

    /// Budget : moins de 50 millisecondes pour afficher les résultats après une lettre tapée.
    /// La mesure prend aussi le temps du clavier simulé : elle donne un plafond, pas la valeur exacte.
    @MainActor
    func testRecherche() {
        let app = XCUIApplication()
        app.launch()
        let champ = app.textFields["champ-recherche"]
        XCTAssertTrue(champ.waitForExistence(timeout: 5))
        champ.tap()
        champ.typeText("fa")
        measure(metrics: [XCTClockMetric()]) {
            champ.typeText("c")
            XCTAssertTrue(app.buttons["mot-facture"].firstMatch.waitForExistence(timeout: 2))
            champ.typeText(XCUIKeyboardKey.delete.rawValue)
        }
    }
}
