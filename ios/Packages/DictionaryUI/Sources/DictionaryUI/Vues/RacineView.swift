import DictionaryCore
import SwiftUI

/// La racine de l'app : l'accueil, puis les fiches. Navigation standard du système, sans barre d'onglets.
public struct RacineView: View {
    private let bibliotheque: Bibliotheque
    private let configuration: Configuration
    @State private var lecteur = LecteurVocal()
    @State private var demandes: ServiceDeDemandes
    @Bindable private var aiguillage: Aiguillage
    @Environment(\.scenePhase) private var phase

    public init(bibliotheque: Bibliotheque, configuration: Configuration, aiguillage: Aiguillage = .partage) {
        self.bibliotheque = bibliotheque
        self.configuration = configuration
        self.aiguillage = aiguillage
        self._demandes = State(initialValue: ServiceDeDemandes(adresse: configuration.adresseDesDemandes))
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
        .environment(demandes)
        .environment(\.configuration, configuration)
        // À l'ouverture et à chaque retour dans l'app : les mots demandés sans réseau partent, et le contenu se met à jour.
        // Rien n'est demandé à la personne, et aucune erreur n'est affichée.
        .task(id: phase) {
            guard phase == .active else { return }
            await demandes.envoyerCeQuiAttend()
            await Contenu.mettreAJour(bibliotheque, configuration: configuration)
        }
        .tint(Jetons.Couleur.accent)
    }
}
