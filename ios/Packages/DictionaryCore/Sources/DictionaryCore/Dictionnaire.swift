import Foundation

/// Le dictionnaire chargé en mémoire : les fiches, les thèmes et la recherche.
public struct Dictionnaire: Sendable {
    public let paquet: Paquet
    /// Toutes les fiches, par ordre alphabétique.
    public let fiches: [Fiche]
    private let parSlug: [String: Fiche]
    private let index: IndexDeRecherche

    public init(paquet: Paquet) {
        self.paquet = paquet
        let triees = paquet.fiches.sorted {
            Normalisation.normaliser($0.mot) < Normalisation.normaliser($1.mot)
        }
        self.fiches = triees
        self.parSlug = Dictionary(triees.map { ($0.slug, $0) }, uniquingKeysWith: { premier, _ in premier })
        self.index = IndexDeRecherche(fiches: triees)
    }

    public var themes: [Theme] { paquet.themes }

    public func fiche(slug: String) -> Fiche? { parSlug[slug] }

    public func fiches(duTheme slug: String) -> [Fiche] { fiches.filter { $0.theme == slug } }

    public func nomDuTheme(_ slug: String) -> String {
        paquet.themes.first(where: { $0.slug == slug })?.nom ?? slug
    }

    /// Les fiches liées qui existent vraiment dans le paquet, dans l'ordre de la fiche.
    public func motsLies(de fiche: Fiche) -> [Fiche] { fiche.motsLies.compactMap { parSlug[$0] } }

    public func chercher(_ requete: String, limite: Int = 20) -> [Fiche] {
        index.chercher(requete, limite: limite)
    }

    /// Trouve la fiche qui correspond exactement à un mot, par son nom ou une forme déclarée.
    /// Sert aux liens, à Siri et à la photo : pas de résultat approximatif.
    public func ficheExacte(pour mot: String) -> Fiche? {
        let q = Normalisation.normaliser(mot)
        guard !q.isEmpty else { return nil }
        if let parNom = fiches.first(where: { Normalisation.normaliser($0.mot) == q }) { return parNom }
        return fiches.first { fiche in
            fiche.formesDeRecherche.contains { Normalisation.normaliser($0) == q }
        }
    }

    /// Mots à proposer quand la recherche ne donne rien : on raccourcit la requête jusqu'à trouver.
    public func motsProches(de requete: String, limite: Int = 3) -> [Fiche] {
        var q = Normalisation.normaliser(requete)
        while q.count >= 3 {
            let resultats = index.chercher(q, limite: limite)
            if !resultats.isEmpty { return resultats }
            q.removeLast()
        }
        return []
    }
}
