import Foundation

/// Le paquet téléchargé, rangé sur l'appareil. Il remplace le paquet embarqué quand il existe et qu'il est sain.
public struct DepotDeContenu: Sendable {
    public let dossier: URL

    public init(dossier: URL) {
        self.dossier = dossier
    }

    /// Le dossier habituel : Application Support/Contenu.
    public static func parDefaut() -> DepotDeContenu {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return DepotDeContenu(dossier: base.appendingPathComponent("Contenu", isDirectory: true))
    }

    /// Le paquet téléchargé, s'il existe et s'il est sain. Sinon `nil` : l'app garde son contenu embarqué.
    public func charger(accepterPreversion: Bool) -> Paquet? {
        try? Chargeur.charger(dossier: dossier, accepterPreversion: accepterPreversion)
    }

    /// Vérifie le paquet, puis remplace l'ancien d'un seul coup.
    /// Si la vérification échoue, rien n'est écrit et l'erreur remonte.
    @discardableResult
    public func installer(paquet: Data, manifeste: Data, accepterPreversion: Bool) throws -> Paquet {
        let lu = try Chargeur.charger(paquet: paquet, manifeste: manifeste, accepterPreversion: accepterPreversion)
        let fichiers = FileManager.default
        let parent = dossier.deletingLastPathComponent()
        try fichiers.createDirectory(at: parent, withIntermediateDirectories: true)

        // On écrit tout dans un dossier provisoire, puis on l'échange avec l'ancien : jamais de paquet à moitié écrit.
        let provisoire = parent.appendingPathComponent("Contenu-\(UUID().uuidString)", isDirectory: true)
        try fichiers.createDirectory(at: provisoire, withIntermediateDirectories: true)
        do {
            try paquet.write(to: provisoire.appendingPathComponent("paquet.json"), options: .atomic)
            try manifeste.write(to: provisoire.appendingPathComponent("manifest.json"), options: .atomic)
            if fichiers.fileExists(atPath: dossier.path) {
                _ = try fichiers.replaceItemAt(dossier, withItemAt: provisoire)
            } else {
                try fichiers.moveItem(at: provisoire, to: dossier)
            }
        } catch {
            try? fichiers.removeItem(at: provisoire)
            throw error
        }
        return lu
    }

    /// Efface le paquet téléchargé. L'app retrouve son contenu embarqué.
    public func effacer() {
        try? FileManager.default.removeItem(at: dossier)
    }
}

/// Mise à jour du contenu : au plus une fois par jour, sans jamais montrer d'erreur.
public struct MiseAJourDuContenu: Sendable {
    /// Délai minimal entre deux vérifications : un jour.
    public static let intervalle: TimeInterval = 24 * 60 * 60

    /// L'adresse du dossier du paquet sur le site : https://motssimples.fr/contenu/v1/
    public let adresse: URL
    public let depot: DepotDeContenu
    public let accepterPreversion: Bool
    /// Télécharge une adresse. Remplaçable dans les tests.
    public let telecharger: @Sendable (URL) async throws -> Data

    public init(
        adresse: URL,
        depot: DepotDeContenu,
        accepterPreversion: Bool,
        telecharger: @escaping @Sendable (URL) async throws -> Data
    ) {
        self.adresse = adresse
        self.depot = depot
        self.accepterPreversion = accepterPreversion
        self.telecharger = telecharger
    }

    /// Vrai si la dernière vérification date d'un jour ou plus, ou s'il n'y en a jamais eu.
    public static func doitVerifier(derniere: Date?, maintenant: Date = Date()) -> Bool {
        guard let derniere else { return true }
        let ecoule = maintenant.timeIntervalSince(derniere)
        // Une date dans le futur veut dire que l'horloge a changé : on vérifie.
        return ecoule < 0 || ecoule >= intervalle
    }

    /// Regarde si le site a une autre version. Si oui, la télécharge, la vérifie et l'installe.
    /// Renvoie le nouveau paquet, ou `nil` s'il n'y a rien de neuf ou si quelque chose ne va pas.
    /// Un paquet trop récent, de préversion pour un build public, corrompu ou incomplet est ignoré.
    public func verifier(versionActuelle: String) async -> Paquet? {
        do {
            let donneesDuManifeste = try await telecharger(adresse.appendingPathComponent("manifest.json"))
            let manifeste = try Chargeur.lireManifeste(donneesDuManifeste)
            if manifeste.preversion && !accepterPreversion { return nil }
            if manifeste.version == versionActuelle { return nil }

            // Le paquet est demandé avec sa version : le site peut alors le garder longtemps en cache.
            var composants = URLComponents(url: adresse.appendingPathComponent("paquet.json"), resolvingAgainstBaseURL: false)
            composants?.queryItems = [URLQueryItem(name: "v", value: manifeste.version)]
            guard let adresseDuPaquet = composants?.url else { return nil }
            let paquet = try await telecharger(adresseDuPaquet)
            return try depot.installer(paquet: paquet, manifeste: donneesDuManifeste, accepterPreversion: accepterPreversion)
        } catch {
            return nil
        }
    }
}
