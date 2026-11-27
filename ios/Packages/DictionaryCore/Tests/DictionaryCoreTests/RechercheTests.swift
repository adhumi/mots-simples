import Foundation
import Testing
@testable import DictionaryCore

@Suite("Recherche")
struct RechercheTests {
    struct Requete: Decodable, Sendable, CustomTestStringConvertible {
        let requete: String
        let attendu: String?
        let note: String?
        var testDescription: String { "« \(requete) » → \(attendu ?? "aucun résultat")" }
    }

    /// Le corpus est un fichier de données : tools/donnees/requetes-recherche.json.
    /// Pour ajouter un cas, ajoutez une ligne dans ce fichier, puis lancez « npm run embed:content ».
    static let corpus: [Requete] = {
        guard
            let url = Bundle.module.url(forResource: "requetes-recherche", withExtension: "json", subdirectory: "Ressources"),
            let donnees = try? Data(contentsOf: url),
            let requetes = try? JSONDecoder().decode([Requete].self, from: donnees)
        else { return [] }
        return requetes
    }()

    @Test("Le corpus est bien chargé")
    func corpusPresent() {
        #expect(Self.corpus.count >= 40)
    }

    @Test("Corpus de requêtes", arguments: corpus)
    func rejoueLeCorpus(cas: Requete) throws {
        let resultats = try Ressources.dictionnaire().chercher(cas.requete).map(\.slug)
        if let attendu = cas.attendu {
            #expect(resultats.first == attendu, "Résultats : \(resultats)")
        } else {
            #expect(resultats.isEmpty)
        }
    }

    @Test("Normalise : minuscules, accents, apostrophes, points, tirets")
    func normalise() {
        #expect(Normalisation.normaliser("  Échéance ") == "echeance")
        #expect(Normalisation.normaliser("R.I.B.") == "rib")
        #expect(Normalisation.normaliser("Rendez-vous") == "rendez vous")
        #expect(Normalisation.normaliser("l’AAH") == "l'aah")
        #expect(Normalisation.normaliser("Œuvre") == "oeuvre")
    }

    @Test("Une faute de distance 1, pas plus")
    func uneFaute() {
        #expect(Normalisation.aUneFautePres("facture", "factre"))
        #expect(Normalisation.aUneFautePres("facture", "factrue"))
        #expect(Normalisation.aUneFautePres("facture", "fakture"))
        #expect(Normalisation.aUneFautePres("facture", "facturee"))
        #expect(!Normalisation.aUneFautePres("facture", "fakturre"))
        #expect(!Normalisation.aUneFautePres("facture", "futcare"))
        #expect(Normalisation.aUneFautePres("ab", "ba"))
        #expect(Normalisation.aUneFautePres("a", ""))
    }

    @Test("Ordre : début du mot, puis formes de recherche, puis une faute")
    func ordreDesResultats() {
        let index = IndexDeRecherche(fiches: [
            ficheDeTest("Contact", slug: "contact"),
            ficheDeTest("Bail", slug: "bail", formes: ["contrat de location"]),
            ficheDeTest("Contrat", slug: "contrat"),
        ])
        #expect(index.chercher("contra").map(\.slug) == ["contrat", "bail", "contact"])
    }

    @Test("Pas de résultat avant 2 lettres")
    func deuxLettres() throws {
        let dictionnaire = try Ressources.dictionnaire()
        #expect(dictionnaire.chercher("f").isEmpty)
        #expect(dictionnaire.chercher(" ").isEmpty)
        #expect(!dictionnaire.chercher("fa").isEmpty)
    }

    @Test("Mots proches d'un mot absent")
    func motsProches() throws {
        let dictionnaire = try Ressources.dictionnaire()
        #expect(dictionnaire.chercher("facturation électronique").isEmpty)
        #expect(dictionnaire.motsProches(de: "facturation électronique").first?.slug == "facture")
        #expect(dictionnaire.motsProches(de: "xyzzy").isEmpty)
    }

    @Test("Fiche exacte par le nom ou par une forme déclarée")
    func ficheExacte() throws {
        let dictionnaire = try Ressources.dictionnaire()
        #expect(dictionnaire.ficheExacte(pour: "Factures")?.slug == "facture")
        #expect(dictionnaire.ficheExacte(pour: "rendez vous")?.slug == "rendez-vous")
        #expect(dictionnaire.ficheExacte(pour: "fact") == nil)
    }
}

@Suite("Performance de la recherche")
struct PerformanceDeLaRechercheTests {
    /// Budget des specs : moins de 50 millisecondes après une lettre tapée.
    /// Ici : 2 000 fiches, dix fois plus que la V1, et la moyenne de 50 recherches.
    @Test("Une recherche dans 2 000 fiches prend moins de 50 millisecondes")
    func budget() {
        let fiches = (0..<2000).map { n in
            ficheDeTest("Mot numéro \(n) facture", slug: "mot-\(n)", formes: ["forme \(n)", "variante \(n)", "factures \(n)"])
        }
        let index = IndexDeRecherche(fiches: fiches)
        let horloge = ContinuousClock()
        let requetes = ["fa", "fac", "fact", "factr", "factur", "mot numero 19", "variante", "xyz", "forme 12", "numéro"]
        let duree = horloge.measure {
            for tour in 0..<50 { _ = index.chercher(requetes[tour % requetes.count]) }
        }
        #expect(duree / 50 < .milliseconds(50), "Moyenne : \(duree / 50)")
    }
}
