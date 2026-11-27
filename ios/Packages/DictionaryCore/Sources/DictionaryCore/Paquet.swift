import CryptoKit
import Foundation

public struct Theme: Codable, Sendable, Hashable, Identifiable {
    public let slug: String
    public let nom: String
    public var id: String { slug }

    public init(slug: String, nom: String) {
        self.slug = slug
        self.nom = nom
    }
}

/// Le paquet de contenu. Format décrit dans docs/paquet.md.
public struct Paquet: Codable, Sendable, Equatable {
    public let schema: Int
    public let version: String
    public let genereLe: String
    public let preversion: Bool
    public let themes: [Theme]
    public let fiches: [Fiche]

    enum CodingKeys: String, CodingKey {
        case schema, version, preversion, themes, fiches
        case genereLe = "genere_le"
    }

    public init(schema: Int, version: String, genereLe: String, preversion: Bool, themes: [Theme], fiches: [Fiche]) {
        self.schema = schema
        self.version = version
        self.genereLe = genereLe
        self.preversion = preversion
        self.themes = themes
        self.fiches = fiches
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        schema = try c.decode(Int.self, forKey: .schema)
        version = try c.decode(String.self, forKey: .version)
        genereLe = try c.decodeIfPresent(String.self, forKey: .genereLe) ?? ""
        preversion = try c.decodeIfPresent(Bool.self, forKey: .preversion) ?? false
        themes = try c.decodeIfPresent([Theme].self, forKey: .themes) ?? []
        fiches = try c.decode([Fiche].self, forKey: .fiches)
    }
}

public struct Manifeste: Codable, Sendable, Equatable {
    public let schema: Int
    public let version: String
    public let preversion: Bool
    public let paquet: String
    public let sha256: String
    public let taille: Int

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        schema = try c.decode(Int.self, forKey: .schema)
        version = try c.decode(String.self, forKey: .version)
        preversion = try c.decodeIfPresent(Bool.self, forKey: .preversion) ?? false
        paquet = try c.decodeIfPresent(String.self, forKey: .paquet) ?? "paquet.json"
        sha256 = try c.decode(String.self, forKey: .sha256)
        taille = try c.decode(Int.self, forKey: .taille)
    }
}

public enum ErreurDePaquet: Error, Equatable, Sendable {
    /// Le fichier est absent ou n'est pas du JSON attendu.
    case illisible
    /// Le paquet a été écrit pour une app plus récente. L'app garde son contenu.
    case schemaTropRecent(Int)
    case empreinteInvalide
    case tailleInvalide
    /// Un build public ne charge jamais un paquet de préversion.
    case preversionRefusee
    /// Le paquet et son manifeste ne parlent pas de la même version.
    case versionIncoherente
}

public enum Chargeur {
    /// Le numéro de schéma le plus récent que cette version du code sait lire.
    public static let schemaConnu = 1

    private struct Entete: Decodable {
        let schema: Int
    }

    public static func empreinte(_ donnees: Data) -> String {
        SHA256.hash(data: donnees).map { String(format: "%02x", $0) }.joined()
    }

    /// Lit un manifeste. Refuse un schéma trop récent avant de lire le reste.
    public static func lireManifeste(_ donnees: Data) throws -> Manifeste {
        let decodeur = JSONDecoder()
        guard let entete = try? decodeur.decode(Entete.self, from: donnees) else { throw ErreurDePaquet.illisible }
        guard entete.schema <= schemaConnu else { throw ErreurDePaquet.schemaTropRecent(entete.schema) }
        guard let manifeste = try? decodeur.decode(Manifeste.self, from: donnees) else { throw ErreurDePaquet.illisible }
        return manifeste
    }

    /// Vérifie un paquet contre son manifeste, puis le lit.
    /// Ordre des contrôles : schéma, préversion, taille, empreinte, lecture, version.
    public static func charger(paquet: Data, manifeste donneesDuManifeste: Data, accepterPreversion: Bool) throws -> Paquet {
        let manifeste = try lireManifeste(donneesDuManifeste)
        if manifeste.preversion && !accepterPreversion { throw ErreurDePaquet.preversionRefusee }
        guard paquet.count == manifeste.taille else { throw ErreurDePaquet.tailleInvalide }
        guard empreinte(paquet) == manifeste.sha256.lowercased() else { throw ErreurDePaquet.empreinteInvalide }

        let decodeur = JSONDecoder()
        guard let entete = try? decodeur.decode(Entete.self, from: paquet) else { throw ErreurDePaquet.illisible }
        guard entete.schema <= schemaConnu else { throw ErreurDePaquet.schemaTropRecent(entete.schema) }
        guard let lu = try? decodeur.decode(Paquet.self, from: paquet) else { throw ErreurDePaquet.illisible }
        if lu.preversion && !accepterPreversion { throw ErreurDePaquet.preversionRefusee }
        guard lu.version == manifeste.version else { throw ErreurDePaquet.versionIncoherente }
        return lu
    }

    /// Charge le paquet rangé dans un dossier : `paquet.json` et `manifest.json`.
    public static func charger(dossier: URL, accepterPreversion: Bool) throws -> Paquet {
        guard
            let paquet = try? Data(contentsOf: dossier.appendingPathComponent("paquet.json")),
            let manifeste = try? Data(contentsOf: dossier.appendingPathComponent("manifest.json"))
        else { throw ErreurDePaquet.illisible }
        return try charger(paquet: paquet, manifeste: manifeste, accepterPreversion: accepterPreversion)
    }

    /// Charge le paquet embarqué dans un bundle. Les deux fichiers sont à la racine des ressources,
    /// ou dans le sous-dossier `Contenu` si le bundle garde les dossiers.
    public static func chargerEmbarque(bundle: Bundle, accepterPreversion: Bool) throws -> Paquet {
        func url(_ nom: String) -> URL? {
            bundle.url(forResource: nom, withExtension: "json")
                ?? bundle.url(forResource: nom, withExtension: "json", subdirectory: "Contenu")
        }
        guard
            let urlPaquet = url("paquet"), let urlManifeste = url("manifest"),
            let paquet = try? Data(contentsOf: urlPaquet),
            let manifeste = try? Data(contentsOf: urlManifeste)
        else { throw ErreurDePaquet.illisible }
        return try charger(paquet: paquet, manifeste: manifeste, accepterPreversion: accepterPreversion)
    }
}
