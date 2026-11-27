import DictionaryCore
import Foundation
import Observation

/// « Demander ce mot » : envoie le mot seul au point de collecte.
/// Sans réseau, la demande est gardée sur l'appareil et part plus tard.
@MainActor
@Observable
public final class ServiceDeDemandes {
    public enum Etat: Equatable, Sendable {
        case envoi
        /// Le mot est parti.
        case envoye
        /// Pas de réseau : le mot est gardé, il partira plus tard.
        case enAttente
    }

    /// L'état de chaque mot demandé pendant cette session, par mot nettoyé.
    public private(set) var etats: [String: Etat] = [:]

    @ObservationIgnored private let adresse: URL?
    @ObservationIgnored private let file: FileDeDemandes

    public init(adresse: URL?, file: FileDeDemandes = FileDeDemandes()) {
        self.adresse = adresse
        self.file = file
        for mot in file.mots { etats[mot] = .enAttente }
    }

    /// Faux si aucun point de collecte n'est réglé : le bouton n'apparaît pas.
    public var disponible: Bool { adresse != nil }

    public func etat(pour brut: String) -> Etat? {
        Demande.nettoyer(brut).flatMap { etats[$0] }
    }

    /// Envoie le mot. S'il ne part pas, il rejoint la file d'attente.
    public func demander(_ brut: String) async {
        guard let mot = Demande.nettoyer(brut), etats[mot] != .envoi, etats[mot] != .envoye else { return }
        etats[mot] = .envoi
        switch await envoyer(mot) {
        case .recu, .refuse:
            // Un mot refusé par le service ne sert à rien de plus : on remercie de la même façon, sans culpabiliser.
            file.retirer(mot)
            etats[mot] = .envoye
        case .plusTard:
            file.ajouter(mot)
            etats[mot] = .enAttente
        }
    }

    /// À appeler au lancement et au retour dans l'app : envoie ce qui attendait.
    public func envoyerCeQuiAttend() async {
        guard disponible, !file.mots.isEmpty else { return }
        for mot in file.mots {
            switch await envoyer(mot) {
            case .recu, .refuse:
                file.retirer(mot)
                etats[mot] = .envoye
            case .plusTard:
                // Le réseau manque sans doute encore : le reste attend la prochaine fois.
                return
            }
        }
    }

    /// Le corps de la demande : le mot, et rien d'autre.
    private func envoyer(_ mot: String) async -> ResultatDEnvoi {
        guard let adresse, let corps = try? JSONEncoder().encode(["mot": mot]) else { return .plusTard }
        var requete = URLRequest(url: adresse.appendingPathComponent("demandes"))
        requete.httpMethod = "POST"
        requete.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requete.httpBody = corps
        guard let (_, reponse) = try? await Reseau.session.data(for: requete), let http = reponse as? HTTPURLResponse else {
            return .plusTard
        }
        switch http.statusCode {
        case 200...299: return .recu
        case 400, 415, 422: return .refuse
        default: return .plusTard
        }
    }
}
