import Foundation

/// Statut éditorial d'une fiche. Un statut inconnu est lu comme un brouillon : c'est le plus prudent.
public enum Statut: String, Codable, Sendable, CaseIterable {
    case brouillon
    case relu
    case valide

    public init(from decoder: Decoder) throws {
        let brut = try decoder.singleValueContainer().decode(String.self)
        self = Statut(rawValue: brut) ?? .brouillon
    }
}

public struct AutreSens: Codable, Sendable, Hashable {
    public let definition: [String]
    public let exemple: String?

    public init(definition: [String], exemple: String?) {
        self.definition = definition
        self.exemple = exemple
    }
}

public struct MotAConfondre: Codable, Sendable, Hashable {
    /// Slug du mot proche.
    public let mot: String
    public let difference: String

    public init(mot: String, difference: String) {
        self.mot = mot
        self.difference = difference
    }
}

public struct Pictogramme: Codable, Sendable, Hashable {
    public let source: String
    public let id: Int?
    public let alt: String

    public init(source: String, id: Int?, alt: String) {
        self.source = source
        self.id = id
        self.alt = alt
    }
}

/// Une fiche du dictionnaire, telle qu'elle est dans le paquet de contenu.
/// Les champs inconnus du paquet sont ignorés : c'est le comportement de `Codable`.
public struct Fiche: Codable, Sendable, Hashable, Identifiable {
    public let mot: String
    public let slug: String
    public let prononciation: String?
    /// Slug du thème. Un thème inconnu de l'app reste affichable.
    public let theme: String
    public let statut: Statut
    public let valideLe: String?
    public let definition: [String]
    public let exemple: String
    public let autresSens: [AutreSens]
    public let aNePasConfondre: MotAConfondre?
    public let motsLies: [String]
    public let formesDeRecherche: [String]
    public let pictogramme: Pictogramme

    public var id: String { slug }

    /// Ce que la voix doit dire pour le mot : la prononciation si elle existe, sinon le mot.
    public var motADire: String { prononciation ?? mot }

    enum CodingKeys: String, CodingKey {
        case mot, slug, prononciation, theme, statut, definition, exemple, pictogramme
        case valideLe = "valide_le"
        case autresSens = "autres_sens"
        case aNePasConfondre = "a_ne_pas_confondre"
        case motsLies = "mots_lies"
        case formesDeRecherche = "formes_de_recherche"
    }

    public init(
        mot: String,
        slug: String,
        prononciation: String? = nil,
        theme: String,
        statut: Statut,
        valideLe: String? = nil,
        definition: [String],
        exemple: String,
        autresSens: [AutreSens] = [],
        aNePasConfondre: MotAConfondre? = nil,
        motsLies: [String] = [],
        formesDeRecherche: [String] = [],
        pictogramme: Pictogramme
    ) {
        self.mot = mot
        self.slug = slug
        self.prononciation = prononciation
        self.theme = theme
        self.statut = statut
        self.valideLe = valideLe
        self.definition = definition
        self.exemple = exemple
        self.autresSens = autresSens
        self.aNePasConfondre = aNePasConfondre
        self.motsLies = motsLies
        self.formesDeRecherche = formesDeRecherche
        self.pictogramme = pictogramme
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        mot = try c.decode(String.self, forKey: .mot)
        slug = try c.decode(String.self, forKey: .slug)
        prononciation = try c.decodeIfPresent(String.self, forKey: .prononciation)
        theme = try c.decode(String.self, forKey: .theme)
        statut = try c.decode(Statut.self, forKey: .statut)
        valideLe = try c.decodeIfPresent(String.self, forKey: .valideLe)
        definition = try c.decode([String].self, forKey: .definition)
        exemple = try c.decode(String.self, forKey: .exemple)
        autresSens = try c.decodeIfPresent([AutreSens].self, forKey: .autresSens) ?? []
        aNePasConfondre = try c.decodeIfPresent(MotAConfondre.self, forKey: .aNePasConfondre)
        motsLies = try c.decodeIfPresent([String].self, forKey: .motsLies) ?? []
        formesDeRecherche = try c.decodeIfPresent([String].self, forKey: .formesDeRecherche) ?? []
        pictogramme = try c.decode(Pictogramme.self, forKey: .pictogramme)
    }
}
