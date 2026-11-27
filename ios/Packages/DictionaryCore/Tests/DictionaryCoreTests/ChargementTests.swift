import Foundation
import Testing
@testable import DictionaryCore

@Suite("Chargement du paquet")
struct ChargementTests {
    @Test("Le paquet embarqué se charge et son empreinte est bonne")
    func chargeLePaquet() throws {
        let paquet = try Ressources.paquet()
        #expect(paquet.schema == 1)
        #expect(!paquet.fiches.isEmpty)
        #expect(paquet.themes.count == 8)
        #expect(paquet.fiches.contains { $0.slug == "facture" })
    }

    @Test("Un octet changé fait échouer l'empreinte")
    func refuseUnPaquetModifie() throws {
        var paquet = try Ressources.donnees("paquet")
        let position = try #require(paquet.firstIndex(of: UInt8(ascii: "F")))
        paquet[position] = UInt8(ascii: "G")
        #expect(throws: ErreurDePaquet.empreinteInvalide) {
            try Chargeur.charger(paquet: paquet, manifeste: Ressources.donnees("manifest"), accepterPreversion: true)
        }
    }

    @Test("Un paquet coupé est refusé pour sa taille")
    func refuseUnPaquetIncomplet() throws {
        let paquet = try Ressources.donnees("paquet").dropLast(10)
        #expect(throws: ErreurDePaquet.tailleInvalide) {
            try Chargeur.charger(paquet: Data(paquet), manifeste: Ressources.donnees("manifest"), accepterPreversion: true)
        }
    }

    @Test("Un build public refuse un paquet de préversion")
    func refuseLaPreversion() throws {
        #expect(throws: ErreurDePaquet.preversionRefusee) {
            try Chargeur.charger(
                paquet: Ressources.donnees("paquet"),
                manifeste: Ressources.donnees("manifest"),
                accepterPreversion: false
            )
        }
    }

    private func paire(_ json: String) -> (paquet: Data, manifeste: Data) {
        let paquet = Data(json.utf8)
        let manifeste = """
        {"schema":1,"version":"abc","preversion":false,"paquet":"paquet.json",
         "sha256":"\(Chargeur.empreinte(paquet))","taille":\(paquet.count)}
        """
        return (paquet, Data(manifeste.utf8))
    }

    private let ficheMinimale = """
    {"mot":"Facture","slug":"facture","theme":"argent","statut":"relu","definition":["Une facture est un document."],
     "exemple":"Vous recevez une facture.","pictogramme":{"source":"arasaac","id":null,"alt":"Une feuille."}
    """

    @Test("Les champs inconnus sont ignorés")
    func ignoreLesChampsInconnus() throws {
        let (paquet, manifeste) = paire("""
        {"schema":1,"version":"abc","genere_le":"2026-11-27","preversion":false,"champ_futur":42,
         "themes":[{"slug":"argent","nom":"Argent","couleur":"vert"}],
         "fiches":[\(ficheMinimale),"champ_futur":{"a":1}}]}
        """)
        let lu = try Chargeur.charger(paquet: paquet, manifeste: manifeste, accepterPreversion: false)
        #expect(lu.fiches.first?.mot == "Facture")
        #expect(lu.fiches.first?.motsLies == [])
    }

    @Test("Un statut inconnu est lu comme un brouillon")
    func statutInconnu() throws {
        let json = ficheMinimale.replacingOccurrences(of: "\"relu\"", with: "\"en-attente\"") + "}"
        let fiche = try JSONDecoder().decode(Fiche.self, from: Data(json.utf8))
        #expect(fiche.statut == .brouillon)
    }

    @Test("Un schéma plus récent est refusé proprement")
    func refuseUnSchemaTropRecent() throws {
        let paquet = Data(#"{"schema":2,"version":"abc","fiches":"autre format"}"#.utf8)
        let manifeste = Data("""
        {"schema":2,"version":"abc","sha256":"\(Chargeur.empreinte(paquet))","taille":\(paquet.count)}
        """.utf8)
        #expect(throws: ErreurDePaquet.schemaTropRecent(2)) {
            try Chargeur.charger(paquet: paquet, manifeste: manifeste, accepterPreversion: true)
        }
    }

    @Test("Un manifeste qui n'est pas du JSON est illisible")
    func refuseUnManifesteIllisible() throws {
        #expect(throws: ErreurDePaquet.illisible) {
            try Chargeur.lireManifeste(Data("<html>".utf8))
        }
    }

    @Test("Le paquet et le manifeste doivent porter la même version")
    func refuseUneVersionIncoherente() throws {
        let paquet = Data(#"{"schema":1,"version":"autre","fiches":[]}"#.utf8)
        let manifeste = Data("""
        {"schema":1,"version":"abc","sha256":"\(Chargeur.empreinte(paquet))","taille":\(paquet.count)}
        """.utf8)
        #expect(throws: ErreurDePaquet.versionIncoherente) {
            try Chargeur.charger(paquet: paquet, manifeste: manifeste, accepterPreversion: true)
        }
    }
}
