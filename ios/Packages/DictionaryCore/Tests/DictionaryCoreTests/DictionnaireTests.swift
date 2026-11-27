import Foundation
import Testing
@testable import DictionaryCore

@Suite("Dictionnaire et derniers mots")
struct DictionnaireTests {
    @Test("Les fiches sont triées et rangées par thème")
    func themes() throws {
        let dictionnaire = try Ressources.dictionnaire()
        let mots = dictionnaire.fiches.map { Normalisation.normaliser($0.mot) }
        #expect(mots == mots.sorted())
        #expect(dictionnaire.fiches(duTheme: "logement").map(\.slug).contains("bail"))
        #expect(dictionnaire.nomDuTheme("sante") == "Santé")
        #expect(dictionnaire.nomDuTheme("inconnu") == "inconnu")
    }

    @Test("Les mots liés sans fiche ne sont pas proposés")
    func motsLies() throws {
        let dictionnaire = try Ressources.dictionnaire()
        let facture = try #require(dictionnaire.fiche(slug: "facture"))
        let lies = dictionnaire.motsLies(de: facture).map(\.slug)
        #expect(lies.contains("echeance"))
        #expect(!lies.contains("devis"))
    }

    @Test("La voix lit la prononciation quand elle existe")
    func prononciation() throws {
        let dictionnaire = try Ressources.dictionnaire()
        #expect(dictionnaire.fiche(slug: "aah")?.motADire == "a-a-hache")
        #expect(dictionnaire.fiche(slug: "facture")?.motADire == "Facture")
    }

    @Test("Le contenu embarqué respecte les règles de forme")
    func controleDuContenu() throws {
        for fiche in try Ressources.paquet().fiches {
            #expect((1...3).contains(fiche.definition.count), "\(fiche.slug) : 1 à 3 phrases")
            for phrase in fiche.definition + [fiche.exemple] {
                let mots = phrase.split(separator: " ").filter { $0.contains(where: \.isLetter) || $0.contains(where: \.isNumber) }
                #expect(mots.count <= 15, "\(fiche.slug) : phrase trop longue")
            }
            #expect(!fiche.pictogramme.alt.isEmpty)
            #expect(fiche.autresSens.count <= 3)
            #expect(fiche.motsLies.count <= 4)
        }
    }

    @Test("Derniers mots : 10 au plus, le plus récent d'abord, sans doublon")
    func derniersMots() {
        var liste: [String] = []
        for n in 1...12 { liste = DerniersMots.ajouter("mot-\(n)", a: liste) }
        #expect(liste.count == 10)
        #expect(liste.first == "mot-12")
        #expect(liste.last == "mot-3")
        liste = DerniersMots.ajouter("mot-5", a: liste)
        #expect(liste.first == "mot-5")
        #expect(liste.filter { $0 == "mot-5" }.count == 1)
        #expect(liste.count == 10)
    }

    @Test("Derniers mots : stockage local")
    func stockage() throws {
        let nom = "tests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: nom))
        defer { defaults.removePersistentDomain(forName: nom) }
        let derniers = DerniersMots(defaults: defaults)
        #expect(derniers.slugs.isEmpty)
        derniers.ajouter("facture")
        derniers.ajouter("bail")
        #expect(DerniersMots(defaults: defaults).slugs == ["bail", "facture"])
    }
}
