import Foundation
import Testing
@testable import DictionaryCore

@Suite("Demander un mot, liens de mot")
struct DemandesTests {
    @Test("Nettoie et valide le mot, comme le point de collecte")
    func nettoyer() {
        #expect(Demande.nettoyer("  Hypothèque ") == "hypothèque")
        #expect(Demande.nettoyer("Mise  en   demeure") == "mise en demeure")
        #expect(Demande.nettoyer("Aujourd’hui") == "aujourd'hui")
        #expect(Demande.nettoyer("Rendez-vous") == "rendez-vous")
        #expect(Demande.nettoyer("a") == nil)
        #expect(Demande.nettoyer(String(repeating: "x", count: 41)) == nil)
        #expect(Demande.nettoyer("marie@exemple.fr") == nil)
        #expect(Demande.nettoyer("06 12 34 56 78") == nil)
        #expect(Demande.nettoyer("mot2") == nil)
        #expect(Demande.nettoyer("-mot") == nil)
        #expect(Demande.nettoyer("mot--mot") == nil)
    }

    private func file() throws -> (FileDeDemandes, () -> Void) {
        let nom = "tests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: nom))
        return (FileDeDemandes(defaults: defaults), { defaults.removePersistentDomain(forName: nom) })
    }

    @Test("La file garde les mots sans doublon, 20 au plus")
    func fileSansDoublon() throws {
        let (file, nettoyer) = try file()
        defer { nettoyer() }
        file.ajouter("caution")
        file.ajouter("hypothèque")
        file.ajouter("caution")
        #expect(file.mots == ["hypothèque", "caution"])
        let lettres = Array("abcdefghijklmnopqrstuvwxyzàâéèêîôûç")
        for lettre in lettres.prefix(30) { file.ajouter("mot \(lettre)") }
        #expect(file.mots.count == 20)
    }

    @Test("Sans réseau, tout reste. Avec le réseau, tout part")
    func vider() async throws {
        let (file, nettoyer) = try file()
        defer { nettoyer() }
        file.ajouter("caution")
        file.ajouter("hypothèque")
        #expect(await file.vider { _ in .plusTard } == 0)
        #expect(file.mots == ["caution", "hypothèque"])
        #expect(await file.vider { _ in .recu } == 2)
        #expect(file.mots.isEmpty)
    }

    @Test("Un mot refusé sort de la file, un échec arrête la tournée")
    func viderEnPartie() async throws {
        let (file, nettoyer) = try file()
        defer { nettoyer() }
        for mot in ["un", "deux", "trois"] { file.ajouter(mot) }
        let partis = await file.vider { mot in
            switch mot {
            case "un": .refuse
            case "deux": .recu
            default: .plusTard
            }
        }
        #expect(partis == 1)
        #expect(file.mots == ["trois"])
    }

    @Test("Adresse de la page d'un mot, dans les deux sens")
    func liens() throws {
        let site = try #require(URL(string: "https://motssimples.fr"))
        let adresse = LienDeMot.adresse(slug: "fiche-de-paie", site: site)
        #expect(adresse.absoluteString == "https://motssimples.fr/mot/fiche-de-paie")
        #expect(LienDeMot.slug(depuis: adresse) == "fiche-de-paie")
        #expect(LienDeMot.slug(depuis: try #require(URL(string: "https://motssimples.fr/mot/facture.html"))) == "facture")
        #expect(LienDeMot.slug(depuis: try #require(URL(string: "https://motssimples.fr/mot/facture/"))) == "facture")
        #expect(LienDeMot.slug(depuis: try #require(URL(string: "https://motssimples.fr/theme/argent"))) == nil)
        #expect(LienDeMot.slug(depuis: try #require(URL(string: "https://motssimples.fr/mot/Facture%20X"))) == nil)
        #expect(LienDeMot.slug(depuis: try #require(URL(string: "https://motssimples.fr/"))) == nil)
    }
}
