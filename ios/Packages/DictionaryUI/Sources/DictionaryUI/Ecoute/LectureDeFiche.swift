import DictionaryCore
import Foundation

/// Ce que la voix lit pour une fiche, bloc par bloc.
/// « Tout écouter » lit dans l'ordre : le mot, la définition, l'exemple, les autres sens, puis « à ne pas confondre ».
public struct LectureDeFiche: Sendable {
    public let mot: [Enonce]
    public let definition: [Enonce]
    public let exemple: [Enonce]
    public let autresSens: [Enonce]
    public let aNePasConfondre: [Enonce]

    public init(fiche: Fiche) {
        mot = [Enonce(id: "mot", texte: fiche.motADire)]
        definition = fiche.definition.enumerated().map { Enonce(id: "definition-\($0.offset)", texte: $0.element) }
        exemple = [Enonce(id: "exemple", texte: fiche.exemple)]

        var sens: [Enonce] = []
        for (i, autre) in fiche.autresSens.enumerated() {
            for (j, phrase) in autre.definition.enumerated() {
                sens.append(Enonce(id: "sens-\(i)-\(j)", texte: phrase))
            }
            if let exemple = autre.exemple, !exemple.isEmpty {
                sens.append(Enonce(id: "sens-\(i)-exemple", texte: exemple))
            }
        }
        autresSens = sens

        if let confusion = fiche.aNePasConfondre {
            aNePasConfondre = [Enonce(id: "confusion-mot", texte: Textes.aNePasConfondreAvec(confusion.nomAffiche))]
                + Self.phrases(confusion.difference).enumerated().map { Enonce(id: "confusion-\($0.offset)", texte: $0.element) }
        } else {
            aNePasConfondre = []
        }
    }

    /// Toute la fiche. Un titre parlé sépare les blocs, pour suivre sans regarder l'écran.
    public var tout: [Enonce] {
        var enonces = mot + definition
        enonces.append(Enonce(id: "titre-exemple", texte: Textes.exemple + "."))
        enonces += exemple
        if !autresSens.isEmpty {
            enonces.append(Enonce(id: "titre-sens", texte: Textes.autresSens + "."))
            enonces += autresSens
        }
        enonces += aNePasConfondre
        return enonces
    }

    /// Coupe un texte en phrases, sur un point, un point d'interrogation ou d'exclamation suivi d'un espace.
    public static func phrases(_ texte: String) -> [String] {
        var resultat: [String] = []
        var courante = ""
        var finDePhrase = false
        for caractere in texte {
            if finDePhrase && caractere == " " {
                resultat.append(courante)
                courante = ""
                finDePhrase = false
                continue
            }
            courante.append(caractere)
            finDePhrase = caractere == "." || caractere == "!" || caractere == "?"
        }
        let reste = courante.trimmingCharacters(in: .whitespaces)
        if !reste.isEmpty { resultat.append(reste) }
        return resultat
    }
}
