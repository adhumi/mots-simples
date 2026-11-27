import DictionaryUI
import SwiftUI

/// Ce que l'app partage entre ses scènes et avec Siri : les réglages, le contenu, la navigation.
@MainActor
enum AppPartagee {
    static let configuration = Configuration.depuis(bundle: .main)

    /// Le contenu est chargé en mémoire au lancement, hors ligne. L'app est utile tout de suite.
    static let bibliotheque = Contenu.charger(bundle: .main, configuration: configuration)

    /// La navigation de la scène d'Accès d'aide, à part de celle de l'app habituelle.
    static let aiguillageReduit = Aiguillage()

    static var configurationReduite: Configuration {
        var reduite = configuration
        reduite.modeReduit = true
        return reduite
    }
}

@main
struct MotsSimplesApp: App {
    var body: some Scene {
        WindowGroup {
            RacineView(bibliotheque: AppPartagee.bibliotheque, configuration: AppPartagee.configuration)
        }

        // Accès d'aide : une scène dédiée, réduite à Chercher et Fiche.
        // L'app déclare sa prise en charge avec la clé UISupportsAssistiveAccess de Info.plist.
        AssistiveAccess {
            RacineView(
                bibliotheque: AppPartagee.bibliotheque,
                configuration: AppPartagee.configurationReduite,
                aiguillage: AppPartagee.aiguillageReduit
            )
        }
    }
}
