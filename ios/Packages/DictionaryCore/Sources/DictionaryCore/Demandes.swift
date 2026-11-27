import Foundation

/// « Demander un mot » : la règle du mot acceptable et la file des demandes en attente.
/// Seul le mot part. Aucun identifiant ne l'accompagne.
public enum Demande {
    public static let longueurMinimale = 2
    public static let longueurMaximale = 40

    /// Même règle que le point de collecte (server/demandes.mjs) :
    /// 2 à 40 caractères, des lettres, des espaces, des tirets et des apostrophes seulement.
    /// Renvoie le mot nettoyé, ou `nil` s'il ne peut pas être envoyé.
    public static func nettoyer(_ brut: String) -> String? {
        var mot = brut.precomposedStringWithCanonicalMapping
        for apostrophe in ["’", "‘", "`", "ʼ"] { mot = mot.replacingOccurrences(of: apostrophe, with: "'") }
        mot = mot.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased(with: Locale(identifier: "fr_FR"))
        guard (longueurMinimale...longueurMaximale).contains(mot.count), let premier = mot.first, premier.isLetter else { return nil }
        var precedentEstUnSeparateur = false
        for caractere in mot {
            let separateur = caractere == " " || caractere == "'" || caractere == "-"
            guard caractere.isLetter || separateur else { return nil }
            if separateur && precedentEstUnSeparateur { return nil }
            precedentEstUnSeparateur = separateur
        }
        return mot
    }
}

/// Ce que le point de collecte a répondu.
public enum ResultatDEnvoi: Sendable, Equatable {
    /// Le mot est compté.
    case recu
    /// Le mot est refusé pour de bon : inutile de réessayer.
    case refuse
    /// Pas de réseau, ou le service est occupé : on réessaiera plus tard.
    case plusTard
}

/// La file des mots demandés qui ne sont pas encore partis. Stockée sur l'appareil, 20 mots au plus.
public struct FileDeDemandes {
    public static let maximum = 20
    public static let cleParDefaut = "demandesEnAttente"

    private let defaults: UserDefaults
    private let cle: String

    public init(defaults: UserDefaults = .standard, cle: String = FileDeDemandes.cleParDefaut) {
        self.defaults = defaults
        self.cle = cle
    }

    public var mots: [String] { defaults.stringArray(forKey: cle) ?? [] }

    public func ajouter(_ mot: String) {
        var liste = mots.filter { $0 != mot }
        liste.append(mot)
        defaults.set(Array(liste.suffix(Self.maximum)), forKey: cle)
    }

    public func retirer(_ mot: String) {
        defaults.set(mots.filter { $0 != mot }, forKey: cle)
    }

    /// Essaie d'envoyer tout ce qui attend. Un mot reçu ou refusé sort de la file. Les autres restent.
    /// Renvoie le nombre de mots partis.
    @discardableResult
    public func vider(envoyer: (String) async -> ResultatDEnvoi) async -> Int {
        var partis = 0
        for mot in mots {
            switch await envoyer(mot) {
            case .recu:
                retirer(mot)
                partis += 1
            case .refuse:
                retirer(mot)
            case .plusTard:
                // Le réseau manque sans doute encore : on garde le reste pour la prochaine fois.
                return partis
            }
        }
        return partis
    }
}

/// Liens entre une fiche et sa page web : https://motssimples.fr/mot/<slug>.
public enum LienDeMot {
    public static func adresse(slug: String, site: URL) -> URL {
        site.appendingPathComponent("mot").appendingPathComponent(slug)
    }

    /// Le slug porté par l'adresse d'une page de mot, ou `nil` si ce n'en est pas une.
    public static func slug(depuis adresse: URL) -> String? {
        let morceaux = adresse.pathComponents.filter { $0 != "/" }
        guard morceaux.count == 2, morceaux[0] == "mot" else { return nil }
        let slug = morceaux[1].hasSuffix(".html") ? String(morceaux[1].dropLast(5)) : morceaux[1]
        let valide = !slug.isEmpty && slug.allSatisfy { ("a"..."z").contains($0) || ("0"..."9").contains($0) || $0 == "-" }
        return valide ? slug : nil
    }
}
