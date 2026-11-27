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
    case fiche(String)
}
