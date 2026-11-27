import SwiftUI

/// Les réglages de l'app, fixés à la compilation et passés aux écrans par l'environnement.
public struct Configuration: Sendable, Equatable {
    /// Vrai pour un build de préversion : les brouillons sont affichés avec leur bandeau.
    /// Un build public ne charge jamais un paquet de préversion.
    public var preversion: Bool
    /// L'adresse du site : pages de mots à partager, et paquet de contenu à télécharger.
    public var adresseDuSite: URL
    /// L'adresse du point de collecte des mots demandés. `nil` : le bouton « Demander ce mot » n'apparaît pas.
    public var adresseDesDemandes: URL?
    /// Vrai dans la scène d'Accès d'aide : l'app est réduite à Chercher et Fiche.
    public var modeReduit: Bool
    /// Version de l'app, affichée dans « Aide et à propos ».
    public var versionDeLApp: String

    public init(
        preversion: Bool,
        adresseDuSite: URL,
        adresseDesDemandes: URL?,
        modeReduit: Bool = false,
        versionDeLApp: String = ""
    ) {
        self.preversion = preversion
        self.adresseDuSite = adresseDuSite
        self.adresseDesDemandes = adresseDesDemandes
        self.modeReduit = modeReduit
        self.versionDeLApp = versionDeLApp
    }

    public static let siteParDefaut = URL(string: "https://motssimples.fr")!

    public static let parDefaut = Configuration(preversion: false, adresseDuSite: siteParDefaut, adresseDesDemandes: nil)

    /// Lit les réglages dans Info.plist. Leurs valeurs viennent de Config/MotsSimples.xcconfig.
    public static func depuis(bundle: Bundle) -> Configuration {
        func texte(_ cle: String) -> String? {
            guard let valeur = bundle.object(forInfoDictionaryKey: cle) as? String, !valeur.isEmpty else { return nil }
            return valeur
        }
        func adresse(_ cle: String) -> URL? {
            guard let url = texte(cle).flatMap(URL.init(string:)), url.scheme == "https", url.host() != nil else { return nil }
            return url
        }
        return Configuration(
            preversion: texte("MotsSimplesPreversion") == "YES",
            adresseDuSite: adresse("MotsSimplesSite") ?? siteParDefaut,
            adresseDesDemandes: adresse("MotsSimplesDemandes"),
            versionDeLApp: texte("CFBundleShortVersionString") ?? ""
        )
    }
}

extension EnvironmentValues {
    @Entry public var configuration: Configuration = .parDefaut
}

/// Les appels réseau de l'app. Il n'y en a que deux : envoyer un mot demandé, et télécharger le contenu.
/// Session éphémère : aucun cookie, aucun cache sur disque, aucun identifiant.
enum Reseau {
    static let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 15
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()
}
