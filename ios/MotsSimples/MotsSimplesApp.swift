import DictionaryUI
import SwiftUI

@main
struct MotsSimplesApp: App {
    /// Le contenu embarqué est chargé en mémoire au lancement. L'app est utile tout de suite, sans réseau.
    @State private var bibliotheque = Bibliotheque.embarquee(bundle: .main, accepterPreversion: Reglages.preversion)

    var body: some Scene {
        WindowGroup {
            RacineView(bibliotheque: bibliotheque)
        }
    }
}
