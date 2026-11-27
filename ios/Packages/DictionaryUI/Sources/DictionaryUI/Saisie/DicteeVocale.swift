import AVFoundation
import Observation
import Speech

/// Chercher en parlant : écoute un mot et le rend en texte.
/// La reconnaissance se fait sur l'appareil quand il le permet.
/// L'autorisation est demandée au premier usage, jamais au lancement.
@MainActor
@Observable
final class DicteeVocale {
    enum Etat: Equatable {
        case repos
        case ecoute
        /// Le micro ou la reconnaissance vocale a été refusé dans les réglages.
        case refusee
        /// Le téléphone ne sait pas reconnaître le français pour le moment.
        case indisponible
    }

    private(set) var etat: Etat = .repos
    /// Le texte reconnu, mis à jour pendant que la personne parle.
    private(set) var texte = ""

    @ObservationIgnored private let reconnaisseur = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
    @ObservationIgnored private let moteur = AVAudioEngine()
    @ObservationIgnored private var tache: SFSpeechRecognitionTask?
    @ObservationIgnored private var arretAutomatique: Task<Void, Never>?

    /// Durée d'écoute la plus longue, et silence après lequel on s'arrête seul.
    private static let dureeMaximale: Duration = .seconds(8)
    private static let silence: Duration = .seconds(2)

    /// La boîte passe la demande au fil audio, qui n'est pas le fil principal.
    private final class Boite: @unchecked Sendable {
        let demande = SFSpeechAudioBufferRecognitionRequest()
    }

    func basculer() async {
        if etat == .ecoute {
            arreter()
        } else {
            await commencer()
        }
    }

    func commencer() async {
        texte = ""
        guard let reconnaisseur, reconnaisseur.isAvailable else {
            etat = .indisponible
            return
        }
        guard await Self.autorisationDeReconnaissance(), await AVAudioApplication.requestRecordPermission() else {
            etat = .refusee
            return
        }

        let boite = Boite()
        boite.demande.shouldReportPartialResults = true
        // Sur l'appareil quand c'est possible : la voix ne part pas sur internet.
        boite.demande.requiresOnDeviceRecognition = reconnaisseur.supportsOnDeviceRecognition

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: [.notifyOthersOnDeactivation])
            let entree = moteur.inputNode
            entree.removeTap(onBus: 0)
            entree.installTap(onBus: 0, bufferSize: 1024, format: entree.outputFormat(forBus: 0)) { tampon, _ in
                boite.demande.append(tampon)
            }
            moteur.prepare()
            try moteur.start()
        } catch {
            arreter()
            etat = .indisponible
            return
        }

        etat = .ecoute
        tache = reconnaisseur.recognitionTask(with: boite.demande) { [weak self] resultat, erreur in
            let entendu = resultat?.bestTranscription.formattedString
            let fini = resultat?.isFinal ?? false || erreur != nil
            Task { @MainActor [weak self] in
                self?.aEntendu(entendu, fini: fini)
            }
        }
        programmerLArret(apres: Self.dureeMaximale)
    }

    private func aEntendu(_ entendu: String?, fini: Bool) {
        guard etat == .ecoute else { return }
        if let entendu, !entendu.isEmpty {
            texte = entendu
            // La personne dit un mot, pas une phrase : un court silence suffit pour s'arrêter.
            programmerLArret(apres: Self.silence)
        }
        if fini { arreter() }
    }

    private func programmerLArret(apres delai: Duration) {
        arretAutomatique?.cancel()
        arretAutomatique = Task { [weak self] in
            try? await Task.sleep(for: delai)
            guard !Task.isCancelled else { return }
            self?.arreter()
        }
    }

    func arreter() {
        arretAutomatique?.cancel()
        arretAutomatique = nil
        if moteur.isRunning { moteur.stop() }
        moteur.inputNode.removeTap(onBus: 0)
        tache?.cancel()
        tache = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        if etat == .ecoute { etat = .repos }
    }

    private static func autorisationDeReconnaissance() async -> Bool {
        await withCheckedContinuation { suite in
            SFSpeechRecognizer.requestAuthorization { statut in
                suite.resume(returning: statut == .authorized)
            }
        }
    }
}
