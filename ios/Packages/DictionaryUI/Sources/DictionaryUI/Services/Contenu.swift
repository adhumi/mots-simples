import DictionaryCore
import Foundation

/// Le contenu de l'app : le paquet embarqué au départ, puis le paquet téléchargé quand il y en a un plus récent.
public enum Contenu {
    static let cleDeLaDerniereVerification = "contenu.derniereVerification"
    static let cleDeLaVersionDeLApp = "contenu.versionDeLApp"

    /// Charge le contenu au lancement. Tout se fait hors ligne.
    /// Après une mise à jour de l'app, le paquet téléchargé est effacé : le paquet embarqué est alors le plus récent.
    @MainActor
    public static func charger(bundle: Bundle, configuration: Configuration, defaults: UserDefaults = .standard) -> Bibliotheque {
        let depot = DepotDeContenu.parDefaut()
        let version = (bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""
        if defaults.string(forKey: cleDeLaVersionDeLApp) != version {
            depot.effacer()
            defaults.set(version, forKey: cleDeLaVersionDeLApp)
            defaults.removeObject(forKey: cleDeLaDerniereVerification)
        }
        if let telecharge = depot.charger(accepterPreversion: configuration.preversion) {
            return Bibliotheque(dictionnaire: Dictionnaire(paquet: telecharge))
        }
        return Bibliotheque.embarquee(bundle: bundle, accepterPreversion: configuration.preversion)
    }

    /// Regarde, au plus une fois par jour, si le site a un contenu plus récent.
    /// Si oui, il remplace l'ancien d'un seul coup. En cas de souci, rien ne change et rien n'est affiché.
    /// Renvoie vrai si le contenu a changé.
    @MainActor
    @discardableResult
    public static func mettreAJour(
        _ bibliotheque: Bibliotheque,
        configuration: Configuration,
        defaults: UserDefaults = .standard
    ) async -> Bool {
        let derniere = defaults.object(forKey: cleDeLaDerniereVerification) as? Date
        guard MiseAJourDuContenu.doitVerifier(derniere: derniere) else { return false }
        defaults.set(Date(), forKey: cleDeLaDerniereVerification)

        let miseAJour = MiseAJourDuContenu(
            adresse: configuration.adresseDuSite.appendingPathComponent("contenu").appendingPathComponent("v1"),
            depot: .parDefaut(),
            accepterPreversion: configuration.preversion
        ) { adresse in
            let (donnees, reponse) = try await Reseau.session.data(from: adresse)
            guard (reponse as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
            return donnees
        }
        guard let paquet = await miseAJour.verifier(versionActuelle: bibliotheque.dictionnaire.paquet.version) else { return false }
        bibliotheque.remplacer(par: paquet)
        return true
    }
}
