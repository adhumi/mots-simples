import Foundation

/// Les derniers mots consultés : 10 au plus, du plus récent au plus ancien.
/// Stockés dans `UserDefaults`, sur l'appareil. Rien ne part ailleurs.
public struct DerniersMots {
    public static let maximum = 10
    public static let cleParDefaut = "derniersMots"

    private let defaults: UserDefaults
    private let cle: String

    public init(defaults: UserDefaults = .standard, cle: String = DerniersMots.cleParDefaut) {
        self.defaults = defaults
        self.cle = cle
    }

    /// Les slugs, du plus récent au plus ancien.
    public var slugs: [String] { defaults.stringArray(forKey: cle) ?? [] }

    /// Met le mot en tête de liste et renvoie la nouvelle liste.
    @discardableResult
    public func ajouter(_ slug: String) -> [String] {
        let liste = Self.ajouter(slug, a: slugs)
        defaults.set(liste, forKey: cle)
        return liste
    }

    /// Règle pure, sans stockage : un mot déjà présent remonte en tête, la liste garde 10 mots.
    public static func ajouter(_ slug: String, a liste: [String]) -> [String] {
        var nouvelle = liste.filter { $0 != slug }
        nouvelle.insert(slug, at: 0)
        return Array(nouvelle.prefix(maximum))
    }
}
