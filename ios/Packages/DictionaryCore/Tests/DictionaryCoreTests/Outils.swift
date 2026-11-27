import Foundation
import Testing
@testable import DictionaryCore

enum Ressources {
    static func donnees(_ nom: String) throws -> Data {
        let url = try #require(
            Bundle.module.url(forResource: nom, withExtension: "json", subdirectory: "Ressources"),
            "Ressource de test absente : \(nom).json. Lancer « npm run embed:content »."
        )
        return try Data(contentsOf: url)
    }

    static func paquet() throws -> Paquet {
        try Chargeur.charger(
            paquet: donnees("paquet"),
            manifeste: donnees("manifest"),
            accepterPreversion: true
        )
    }

    static func dictionnaire() throws -> Dictionnaire { Dictionnaire(paquet: try paquet()) }
}

func ficheDeTest(_ mot: String, slug: String, formes: [String] = [], theme: String = "argent") -> Fiche {
    Fiche(
        mot: mot,
        slug: slug,
        theme: theme,
        statut: .brouillon,
        definition: ["\(mot) est un mot de test."],
        exemple: "Voici \(mot).",
        formesDeRecherche: formes,
        pictogramme: Pictogramme(source: "arasaac", id: nil, alt: "Une image de test.")
    )
}
