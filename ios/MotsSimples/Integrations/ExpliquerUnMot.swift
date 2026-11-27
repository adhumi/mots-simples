import AppIntents
import DictionaryCore
import DictionaryUI

/// « Expliquer un mot », depuis Siri, Raccourcis et le bouton Action.
/// Siri dit la définition, puis l'app s'ouvre sur la fiche. Tout se passe sur l'appareil.
struct ExpliquerUnMotIntent: AppIntent {
    static let title: LocalizedStringResource = "Expliquer un mot"
    static let description = IntentDescription("Donne l'explication simple d'un mot, puis ouvre sa fiche dans Mots simples.")
    static let openAppWhenRun = true

    @Parameter(title: "Mot", requestValueDialog: "Quel mot voulez-vous comprendre ?")
    var mot: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let dictionnaire = AppPartagee.bibliotheque.dictionnaire
        Aiguillage.partage.expliquer(mot, dans: dictionnaire)
        guard let fiche = dictionnaire.ficheExacte(pour: mot) else {
            return .result(dialog: IntentDialog(stringLiteral: Textes.motAbsentPourSiri))
        }
        let explication = ([fiche.motADire + "."] + fiche.definition).joined(separator: " ")
        return .result(dialog: IntentDialog(stringLiteral: explication))
    }
}

struct RaccourcisMotsSimples: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ExpliquerUnMotIntent(),
            phrases: [
                "Expliquer un mot avec \(.applicationName)",
                "Explique un mot avec \(.applicationName)",
                "Chercher un mot dans \(.applicationName)",
            ],
            shortTitle: "Expliquer un mot",
            systemImageName: "book.fill"
        )
    }
}
