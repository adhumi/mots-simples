import DictionaryCore
import SwiftUI

/// La racine de l'app : l'accueil, puis les fiches. Navigation standard du système, sans barre d'onglets.
public struct RacineView: View {
    private let bibliotheque: Bibliotheque
    @State private var lecteur = LecteurVocal()
    @State private var chemin: [Destination] = []

    public init(bibliotheque: Bibliotheque) {
        self.bibliotheque = bibliotheque
        Polices.enregistrer()
    }

    public var body: some View {
        NavigationStack(path: $chemin) {
            AccueilView()
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .fiche(let slug):
                        FicheView(slug: slug)
                    }
                }
        }
        .environment(bibliotheque)
        .environment(lecteur)
        .tint(Jetons.Couleur.accent)
    }
}
