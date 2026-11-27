import Foundation
import Testing
@testable import DictionaryCore

@Suite("Mots reconnus dans un texte")
struct MotsReconnusTests {
    @Test("Un mot seul avec une fiche")
    func motSeul() throws {
        let resultat = try Ressources.dictionnaire().motsReconnus(dans: "Facture")
        #expect(resultat.map(\.fiche?.slug) == ["facture"])
    }

    @Test("Une expression passe avant ses mots")
    func expression() throws {
        let resultat = try Ressources.dictionnaire().motsReconnus(dans: "Joindre un justificatif de domicile récent")
        #expect(resultat.first?.fiche?.slug == "justificatif-de-domicile")
        #expect(!resultat.contains { $0.texte.lowercased() == "domicile" })
        #expect(resultat.contains { $0.fiche == nil && $0.texte == "Joindre" })
    }

    @Test("Les mots connus viennent d'abord, les petits mots sont retirés")
    func ordre() throws {
        let resultat = try Ressources.dictionnaire().motsReconnus(dans: "Le montant de la facture et l'échéance")
        #expect(resultat.prefix(2).map(\.fiche?.slug) == ["facture", "echeance"])
        #expect(!resultat.contains { ["le", "de", "la", "et"].contains($0.texte.lowercased()) })
        #expect(resultat.contains { $0.texte == "montant" && $0.fiche == nil })
    }

    @Test("Pluriel déclaré, article collé, pas de doublon")
    func formes() throws {
        let resultat = try Ressources.dictionnaire().motsReconnus(dans: "Vos factures. L'ordonnance, la facture.")
        #expect(resultat.compactMap(\.fiche?.slug) == ["facture", "ordonnance"])
    }

    @Test("Un texte sans lettre ne donne rien")
    func vide() throws {
        #expect(try Ressources.dictionnaire().motsReconnus(dans: "12/03 — 45,00 €").isEmpty)
    }
}
