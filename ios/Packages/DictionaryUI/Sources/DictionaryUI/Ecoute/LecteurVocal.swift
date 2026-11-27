import AVFoundation
import Observation

/// Un morceau de texte à lire, avec un identifiant pour le mettre en évidence à l'écran.
public struct Enonce: Sendable, Hashable {
    public let id: String
    public let texte: String

    public init(id: String, texte: String) {
        self.id = id
        self.texte = texte
    }
}

public enum VitesseDeVoix: String, CaseIterable, Sendable, Identifiable {
    case normale
    case lente

    public var id: String { rawValue }

    static let cle = "vitesseDeLaVoix"

    var debit: Float {
        switch self {
        case .normale: AVSpeechUtteranceDefaultSpeechRate * 0.9
        case .lente: AVSpeechUtteranceDefaultSpeechRate * 0.7
        }
    }
}

/// Lit des textes avec une voix française du système.
/// Pas de pause : on lit, ou on arrête. Après un arrêt, la lecture repart du début.
@MainActor
@Observable
public final class LecteurVocal: NSObject {
    /// Identifiant de la lecture en cours : « tout », « definition », « liste:facture »… `nil` si rien n'est lu.
    public private(set) var lectureEnCours: String?
    /// Identifiant de la phrase en cours de lecture, pour la mettre en évidence.
    public private(set) var enonceEnCours: String?
    /// Vitesse choisie. Mémorisée sur l'appareil.
    public private(set) var vitesse: VitesseDeVoix

    @ObservationIgnored private let synthetiseur = AVSpeechSynthesizer()
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var paroles: [AVSpeechUtterance] = []
    @ObservationIgnored private var identifiants: [ObjectIdentifier: String] = [:]

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.vitesse = defaults.string(forKey: VitesseDeVoix.cle).flatMap(VitesseDeVoix.init(rawValue:)) ?? .normale
        super.init()
        synthetiseur.delegate = self
    }

    /// Change la vitesse. La lecture en cours s'arrête : la suivante prend la nouvelle vitesse.
    public func choisir(vitesse nouvelle: VitesseDeVoix) {
        arreter()
        vitesse = nouvelle
        defaults.set(nouvelle.rawValue, forKey: VitesseDeVoix.cle)
    }

    /// Vrai si le téléphone a une voix française.
    public static var voixDisponible: Bool { voix != nil }

    private static var voix: AVSpeechSynthesisVoice? { AVSpeechSynthesisVoice(language: "fr-FR") }

    public func estEnCours(_ lecture: String) -> Bool { lectureEnCours == lecture }

    /// Lance la lecture, ou l'arrête si c'est elle qui est en cours.
    public func basculer(_ lecture: String, enonces: [Enonce]) {
        if lectureEnCours == lecture {
            arreter()
        } else {
            lire(lecture, enonces: enonces)
        }
    }

    public func lire(_ lecture: String, enonces: [Enonce]) {
        arreter()
        let aLire = enonces.filter { !$0.texte.isEmpty }
        guard !aLire.isEmpty else { return }

        // La personne a demandé la lecture : elle doit s'entendre même en mode silencieux.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)

        lectureEnCours = lecture
        for enonce in aLire {
            let parole = AVSpeechUtterance(string: enonce.texte)
            parole.voice = Self.voix
            parole.rate = vitesse.debit
            parole.postUtteranceDelay = 0.3
            paroles.append(parole)
            identifiants[ObjectIdentifier(parole)] = enonce.id
            synthetiseur.speak(parole)
        }
    }

    public func arreter() {
        let lisait = lectureEnCours != nil
        paroles = []
        identifiants = [:]
        lectureEnCours = nil
        enonceEnCours = nil
        if synthetiseur.isSpeaking {
            synthetiseur.stopSpeaking(at: .immediate)
        }
        if lisait {
            try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        }
    }

    // Les paroles d'une lecture arrêtée ne sont plus dans `identifiants` : leurs événements sont ignorés.

    private func aCommence(_ cle: ObjectIdentifier) {
        guard let id = identifiants[cle] else { return }
        enonceEnCours = id
    }

    private func aFini(_ cle: ObjectIdentifier) {
        guard let id = identifiants[cle] else { return }
        if enonceEnCours == id { enonceEnCours = nil }
        if let derniere = paroles.last, ObjectIdentifier(derniere) == cle {
            arreter()
        }
    }
}

extension LecteurVocal: AVSpeechSynthesizerDelegate {
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        let cle = ObjectIdentifier(utterance)
        Task { @MainActor in self.aCommence(cle) }
    }

    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let cle = ObjectIdentifier(utterance)
        Task { @MainActor in self.aFini(cle) }
    }

    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let cle = ObjectIdentifier(utterance)
        Task { @MainActor in self.aFini(cle) }
    }
}
