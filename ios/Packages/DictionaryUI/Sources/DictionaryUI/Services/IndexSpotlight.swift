import CoreSpotlight
import DictionaryCore
import Foundation
import UniformTypeIdentifiers

/// Spotlight : chaque mot du dictionnaire se trouve depuis la recherche du téléphone, et ouvre sa fiche.
/// L'index reste sur l'appareil.
public enum IndexSpotlight {
    static let domaine = "fr.adhumi.motssimples.mots"
    static let cleDeVersion = "spotlight.versionIndexee"

    /// Refait l'index quand le contenu a changé. Sans effet si la version est déjà indexée.
    public static func mettreAJour(dictionnaire: Dictionnaire) async {
        let version = dictionnaire.paquet.version
        guard CSSearchableIndex.isIndexingAvailable(), UserDefaults.standard.string(forKey: cleDeVersion) != version else { return }

        let elements = dictionnaire.fiches.map { fiche in
            let attributs = CSSearchableItemAttributeSet(contentType: UTType.text)
            attributs.title = fiche.mot
            attributs.contentDescription = fiche.definition.joined(separator: " ")
            attributs.keywords = fiche.formesDeRecherche
            return CSSearchableItem(uniqueIdentifier: fiche.slug, domainIdentifier: domaine, attributeSet: attributs)
        }
        let index = CSSearchableIndex.default()
        do {
            try await index.deleteSearchableItems(withDomainIdentifiers: [domaine])
            try await index.indexSearchableItems(elements)
            UserDefaults.standard.set(version, forKey: cleDeVersion)
        } catch {
            // Sans index, l'app marche comme avant. On réessaiera au prochain lancement.
        }
    }

    /// Le slug de la fiche choisie dans Spotlight, ou `nil` si l'activité vient d'ailleurs.
    public static func slug(depuis activite: NSUserActivity) -> String? {
        guard activite.activityType == CSSearchableItemActionType else { return nil }
        return activite.userInfo?[CSSearchableItemActivityIdentifier] as? String
    }
}
