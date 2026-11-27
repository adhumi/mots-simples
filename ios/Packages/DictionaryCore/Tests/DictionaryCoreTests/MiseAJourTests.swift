import Foundation
import Testing
@testable import DictionaryCore

@Suite("Mise à jour du contenu")
struct MiseAJourTests {
    struct Introuvable: Error {}

    private func depotProvisoire() -> DepotDeContenu {
        DepotDeContenu(dossier: FileManager.default.temporaryDirectory
            .appendingPathComponent("tests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("Contenu", isDirectory: true))
    }

    private let base = URL(string: "https://motssimples.fr/contenu/v1/")!

    /// Un faux site : il rend les fichiers donnés, et note les adresses demandées.
    private func miseAJour(
        depot: DepotDeContenu,
        manifeste: Data?,
        paquet: Data?,
        accepterPreversion: Bool = true,
        demandees: Journal = Journal()
    ) -> MiseAJourDuContenu {
        MiseAJourDuContenu(adresse: base, depot: depot, accepterPreversion: accepterPreversion) { url in
            await demandees.noter(url)
            if url.lastPathComponent == "manifest.json", let manifeste { return manifeste }
            if url.lastPathComponent == "paquet.json", let paquet { return paquet }
            throw Introuvable()
        }
    }

    actor Journal {
        private(set) var adresses: [URL] = []
        func noter(_ url: URL) { adresses.append(url) }
    }

    @Test("Au plus une fois par jour")
    func unJour() {
        let maintenant = Date(timeIntervalSince1970: 1_800_000_000)
        #expect(MiseAJourDuContenu.doitVerifier(derniere: nil, maintenant: maintenant))
        #expect(!MiseAJourDuContenu.doitVerifier(derniere: maintenant.addingTimeInterval(-3600), maintenant: maintenant))
        #expect(MiseAJourDuContenu.doitVerifier(derniere: maintenant.addingTimeInterval(-25 * 3600), maintenant: maintenant))
        #expect(MiseAJourDuContenu.doitVerifier(derniere: maintenant.addingTimeInterval(3600), maintenant: maintenant))
    }

    @Test("Une nouvelle version est téléchargée, vérifiée et installée")
    func installe() async throws {
        let depot = depotProvisoire()
        defer { depot.effacer() }
        let journal = Journal()
        let nouveau = await miseAJour(
            depot: depot, manifeste: try Ressources.donnees("manifest"), paquet: try Ressources.donnees("paquet"), demandees: journal
        ).verifier(versionActuelle: "ancienne")
        let attendu = try Ressources.paquet()
        #expect(nouveau?.version == attendu.version)
        #expect(depot.charger(accepterPreversion: true) == attendu)
        let adresses = await journal.adresses.map(\.absoluteString)
        #expect(adresses == [
            "https://motssimples.fr/contenu/v1/manifest.json",
            "https://motssimples.fr/contenu/v1/paquet.json?v=\(attendu.version)",
        ])
    }

    @Test("La même version ne télécharge pas le paquet")
    func rienDeNeuf() async throws {
        let depot = depotProvisoire()
        let journal = Journal()
        let version = try Ressources.paquet().version
        let nouveau = await miseAJour(
            depot: depot, manifeste: try Ressources.donnees("manifest"), paquet: try Ressources.donnees("paquet"), demandees: journal
        ).verifier(versionActuelle: version)
        #expect(nouveau == nil)
        #expect(await journal.adresses.count == 1)
        #expect(depot.charger(accepterPreversion: true) == nil)
    }

    @Test("Un paquet corrompu ou incomplet est ignoré, l'ancien reste")
    func corrompu() async throws {
        let depot = depotProvisoire()
        defer { depot.effacer() }
        let manifeste = try Ressources.donnees("manifest")
        let bon = try Ressources.donnees("paquet")
        try depot.installer(paquet: bon, manifeste: manifeste, accepterPreversion: true)

        var abime = bon
        abime[abime.count / 2] = abime[abime.count / 2] == 0x61 ? 0x62 : 0x61
        #expect(await miseAJour(depot: depot, manifeste: manifeste, paquet: abime).verifier(versionActuelle: "ancienne") == nil)
        #expect(await miseAJour(depot: depot, manifeste: manifeste, paquet: Data(bon.dropLast(100))).verifier(versionActuelle: "ancienne") == nil)
        #expect(await miseAJour(depot: depot, manifeste: manifeste, paquet: nil).verifier(versionActuelle: "ancienne") == nil)
        #expect(await miseAJour(depot: depot, manifeste: Data("<html>".utf8), paquet: bon).verifier(versionActuelle: "ancienne") == nil)
        #expect(await miseAJour(depot: depot, manifeste: nil, paquet: nil).verifier(versionActuelle: "ancienne") == nil)

        let intact = try Ressources.paquet()
        #expect(depot.charger(accepterPreversion: true) == intact)
    }

    @Test("Un schéma trop récent est ignoré sans télécharger le paquet")
    func schemaTropRecent() async throws {
        let journal = Journal()
        let manifeste = Data(#"{"schema":99,"version":"futur","sha256":"00","taille":1}"#.utf8)
        let nouveau = await miseAJour(depot: depotProvisoire(), manifeste: manifeste, paquet: Data("{}".utf8), demandees: journal)
            .verifier(versionActuelle: "ancienne")
        #expect(nouveau == nil)
        #expect(await journal.adresses.count == 1)
    }

    @Test("Un build public ne charge jamais un paquet de préversion")
    func preversionRefusee() async throws {
        let depot = depotProvisoire()
        let journal = Journal()
        let nouveau = await miseAJour(
            depot: depot, manifeste: try Ressources.donnees("manifest"), paquet: try Ressources.donnees("paquet"),
            accepterPreversion: false, demandees: journal
        ).verifier(versionActuelle: "ancienne")
        #expect(nouveau == nil)
        #expect(await journal.adresses.count == 1, "le paquet n'est même pas téléchargé")
        #expect(depot.charger(accepterPreversion: false) == nil)
        // Même déjà rangé sur l'appareil, un paquet de préversion n'est pas chargé par un build public.
        try depot.installer(paquet: try Ressources.donnees("paquet"), manifeste: try Ressources.donnees("manifest"), accepterPreversion: true)
        defer { depot.effacer() }
        #expect(depot.charger(accepterPreversion: false) == nil)
    }
}
