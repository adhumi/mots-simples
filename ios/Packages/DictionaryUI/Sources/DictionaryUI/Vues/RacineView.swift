import DictionaryCore
import SwiftUI

/// La racine de l'app : l'accueil, puis les fiches. Navigation standard du système, sans barre d'onglets.
public struct RacineView: View {
    private let bibliotheque: Bibliotheque
    @State private var lecteur = LecteurVocal()
    @Bindable private var aiguillage: Aiguillage

    public init(bibliotheque: Bibliotheque, aiguillage: Aiguillage = .partage) {
        self.bibliotheque = bibliotheque
        self.aiguillage = aiguillage
        Polices.enregistrer()
    }

    public var body: some View {
        NavigationStack(path: $aiguillage.chemin) {
            AccueilView()
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .fiche(let slug):
                        FicheView(slug: slug)
                    case .themes:
                        ThemesView()
                    case .theme(let slug):
                        ThemeView(slug: slug)
                    }
                }
        }
        .environment(bibliotheque)
        .environment(lecteur)
        .environment(aiguillage)
        .tint(Jetons.Couleur.accent)
    }
}
