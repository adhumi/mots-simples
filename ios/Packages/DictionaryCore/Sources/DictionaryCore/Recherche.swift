import Foundation

// Recherche dans le dictionnaire. Même règle que tools/recherche.ts.
// Les deux sont rejouées sur le même corpus : tools/donnees/requetes-recherche.json.

public enum Normalisation {
    /// Minuscules, sans accent, apostrophes unifiées, ponctuation retirée, espaces simples.
    public static func normaliser(_ texte: String) -> String {
        let plie = texte.folding(
            options: [.diacriticInsensitive, .caseInsensitive, .widthInsensitive],
            locale: Locale(identifier: "fr_FR")
        )
        var sortie = ""
        var espaceEnAttente = false
        func ajouter(_ morceau: String, a sortie: inout String, espace: inout Bool) {
            if espace && !sortie.isEmpty { sortie.append(" ") }
            espace = false
            sortie.append(morceau)
        }
        for caractere in plie {
            switch caractere {
            case "œ":
                ajouter("oe", a: &sortie, espace: &espaceEnAttente)
            case "æ":
                ajouter("ae", a: &sortie, espace: &espaceEnAttente)
            case "'", "’", "‘", "`", "ʼ":
                ajouter("'", a: &sortie, espace: &espaceEnAttente)
            case ".":
                continue
            case "a"..."z", "0"..."9":
                ajouter(String(caractere), a: &sortie, espace: &espaceEnAttente)
            default:
                espaceEnAttente = true
            }
        }
        return sortie
    }

    static let motsVides: Set<String> = [
        "de", "du", "des", "le", "la", "les", "un", "une", "au", "aux", "et", "en", "par", "sur", "d", "l",
    ]

    /// Les mots d'un texte normalisé qui comptent pour la recherche : plus de 2 lettres, pas un petit mot.
    static func motsUtiles(_ texteNormalise: String) -> [String] {
        texteNormalise
            .split(whereSeparator: { $0 == " " || $0 == "'" })
            .map(String.init)
            .filter { $0.count > 2 && !motsVides.contains($0) }
    }

    /// Vrai si les deux textes sont à une faute près :
    /// une lettre en trop, en moins, changée, ou deux lettres voisines inversées.
    public static func aUneFautePres(_ premier: String, _ second: String) -> Bool {
        if premier == second { return true }
        let a = Array(premier)
        let b = Array(second)
        if abs(a.count - b.count) > 1 { return false }
        var i = 0
        while i < a.count && i < b.count && a[i] == b[i] { i += 1 }
        if a.count == b.count {
            if a[(i + 1)...] == b[(i + 1)...] { return true }
            return i + 1 < a.count && a[i] == b[i + 1] && a[i + 1] == b[i] && a[(i + 2)...] == b[(i + 2)...]
        }
        return a.count > b.count ? a[(i + 1)...] == b[i...] : a[i...] == b[(i + 1)...]
    }

    /// Vrai si la requête est à une faute près de la cible, ou du début de la cible.
    static func procheDuDebut(_ requete: String, _ cible: String) -> Bool {
        if aUneFautePres(requete, cible) { return true }
        let longueur = requete.count
        for n in [longueur - 1, longueur, longueur + 1] where n >= 3 && n < cible.count {
            if aUneFautePres(requete, String(cible.prefix(n))) { return true }
        }
        return false
    }
}

/// Index en mémoire sur les formes normalisées des fiches.
public struct IndexDeRecherche: Sendable {
    public static let longueurMinimale = 2
    static let longueurPourUneFaute = 4

    private struct Entree: Sendable {
        let position: Int
        let mot: String
        let motsDuMot: [String]
        let formes: [String]
        let motsDesFormes: [String]
    }

    private let fiches: [Fiche]
    private let entrees: [Entree]

    public init(fiches: [Fiche]) {
        self.fiches = fiches
        self.entrees = fiches.enumerated().map { position, fiche in
            let mot = Normalisation.normaliser(fiche.mot)
            let formes = fiche.formesDeRecherche.map(Normalisation.normaliser).filter { !$0.isEmpty }
            return Entree(
                position: position,
                mot: mot,
                motsDuMot: Normalisation.motsUtiles(mot),
                formes: formes,
                motsDesFormes: formes.flatMap(Normalisation.motsUtiles)
            )
        }
    }

    /// Rang d'une fiche pour une requête normalisée. Plus petit = meilleur. `nil` = pas de résultat.
    private func rang(_ q: String, _ e: Entree) -> Int? {
        if e.mot == q { return 0 }
        if e.mot.hasPrefix(q) { return 1 }
        if e.motsDuMot.contains(where: { $0.hasPrefix(q) }) { return 2 }
        if e.formes.contains(q) { return 3 }
        if e.formes.contains(where: { $0.hasPrefix(q) }) || e.motsDesFormes.contains(where: { $0.hasPrefix(q) }) {
            return 4
        }
        if q.count >= Self.longueurPourUneFaute {
            if Normalisation.procheDuDebut(q, e.mot) || e.motsDuMot.contains(where: { Normalisation.procheDuDebut(q, $0) }) {
                return 5
            }
            if e.formes.contains(where: { Normalisation.procheDuDebut(q, $0) }) { return 6 }
        }
        return nil
    }

    /// Résultats dès 2 lettres. Ordre : début du mot, puis formes de recherche, puis une faute.
    public func chercher(_ requete: String, limite: Int = 20) -> [Fiche] {
        let q = Normalisation.normaliser(requete)
        guard q.count >= Self.longueurMinimale else { return [] }
        var trouves: [(rang: Int, entree: Entree)] = []
        for entree in entrees {
            if let rang = rang(q, entree) { trouves.append((rang, entree)) }
        }
        trouves.sort { a, b in
            a.rang != b.rang ? a.rang < b.rang : a.entree.mot < b.entree.mot
        }
        return trouves.prefix(limite).map { fiches[$0.entree.position] }
    }
}
