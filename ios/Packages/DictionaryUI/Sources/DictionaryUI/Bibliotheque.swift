import DictionaryCore
import Foundation
import Observation

/// L'état partagé de l'app : le dictionnaire chargé et les derniers mots consultés.
@MainActor
@Observable
public final class Bibliotheque {
    public private(set) var dictionnaire: Dictionnaire
    /// Slugs des derniers mots consultés, du plus récent au plus ancien.
    public private(set) var derniersSlugs: [String]

    @ObservationIgnored private let stockage: DerniersMots

    public init(dictionnaire: Dictionnaire, stockage: DerniersMots = DerniersMots()) {
        self.dictionnaire = dictionnaire
        self.stockage = stockage
        self.derniersSlugs = stockage.slugs
    }

    /// Charge le paquet embarqué dans l'app. S'il est illisible, le dictionnaire est vide : l'app s'ouvre quand même.
    public static func embarquee(bundle: Bundle, accepterPreversion: Bool) -> Bibliotheque {
        let paquet = (try? Chargeur.chargerEmbarque(bundle: bundle, accepterPreversion: accepterPreversion)) ?? Self.paquetVide
        return Bibliotheque(dictionnaire: Dictionnaire(paquet: paquet))
    }

    public static let paquetVide = Paquet(
        schema: Chargeur.schemaConnu, version: "vide", genereLe: "", preversion: false, themes: [], fiches: []
    )

    /// Les derniers mots qui existent encore dans le dictionnaire.
    public var derniersMots: [Fiche] { derniersSlugs.compactMap { dictionnaire.fiche(slug: $0) } }

    public func aConsulte(_ fiche: Fiche) {
        derniersSlugs = stockage.ajouter(fiche.slug)
    }

    /// Remplace tout le contenu d'un seul coup, après une mise à jour.
    public func remplacer(par paquet: Paquet) {
        dictionnaire = Dictionnaire(paquet: paquet)
    }
}

/// Les écrans vers lesquels on navigue depuis l'accueil.
public enum Destination: Hashable, Sendable {
    /// La fiche d'un mot, par son slug.
    case fiche(String)
    /// La grille des huit thèmes.
    case themes
    /// Les mots d'un thème, par son slug.
    case theme(String)
}

/// L'état de la navigation. Il est partagé pour que Siri, Spotlight et les liens puissent ouvrir une fiche.
@MainActor
@Observable
public final class Aiguillage {
    /// Les écrans empilés au-dessus de l'accueil.
    public var chemin: [Destination] = []

    public init() {}

    /// L'aiguillage de l'app. Les intégrations système écrivent dedans.
    public static let partage = Aiguillage()

    /// Ajoute un écran au-dessus de l'écran courant.
    public func allerA(_ destination: Destination) {
        chemin.append(destination)
    }

    /// Ouvre un écran directement au-dessus de l'accueil. « Retour » ramène alors à l'accueil.
    public func ouvrir(_ destination: Destination) {
        chemin = [destination]
    }

    public func retourALAccueil() {
        chemin = []
    }
}
