import Foundation

/// Un mot ou une expression repérés dans un texte lu par la caméra ou dicté.
public struct MotReconnu: Sendable, Hashable, Identifiable {
    /// Le texte tel qu'il a été lu.
    public let texte: String
    /// La fiche correspondante, si le dictionnaire en a une.
    public let fiche: Fiche?

    public var id: String { fiche?.slug ?? "absent:" + Normalisation.normaliser(texte) }
}

extension Dictionnaire {
    /// Découpe un texte en mots à proposer. Les expressions du dictionnaire passent avant les mots seuls :
    /// dans « votre mise en demeure », on propose « mise en demeure », puis les autres mots.
    /// Les mots connus viennent d'abord. Les petits mots sans fiche, comme « de » ou « la », sont retirés.
    public func motsReconnus(dans texte: String, limite: Int = 8) -> [MotReconnu] {
        let mots = texte
            .split(whereSeparator: { !($0.isLetter || $0.isNumber || $0 == "'" || $0 == "’" || $0 == "-") })
            .map(String.init)
            .filter { $0.contains(where: \.isLetter) }
        guard !mots.isEmpty else { return [] }

        var connus: [MotReconnu] = []
        var inconnus: [MotReconnu] = []
        var dejaVus = Set<String>()
        var couverts = Set<Int>()

        // Les expressions d'abord, des plus longues aux plus courtes.
        let plusLongue = min(4, mots.count)
        if plusLongue >= 2 {
            for longueur in stride(from: plusLongue, through: 2, by: -1) {
                for debut in 0...(mots.count - longueur) {
                    let positions = debut..<(debut + longueur)
                    if positions.contains(where: couverts.contains) { continue }
                    let expression = mots[positions].joined(separator: " ")
                    if let fiche = ficheExacte(pour: expression), dejaVus.insert(fiche.slug).inserted {
                        connus.append(MotReconnu(texte: expression, fiche: fiche))
                        couverts.formUnion(positions)
                    }
                }
            }
        }

        for (position, mot) in mots.enumerated() where !couverts.contains(position) {
            // « l'ordonnance » : on essaie aussi le mot sans son article.
            let sansArticle = mot.split(whereSeparator: { $0 == "'" || $0 == "’" }).last.map(String.init) ?? mot
            if let fiche = ficheExacte(pour: mot) ?? ficheExacte(pour: sansArticle) {
                if dejaVus.insert(fiche.slug).inserted { connus.append(MotReconnu(texte: sansArticle, fiche: fiche)) }
                continue
            }
            let cle = Normalisation.normaliser(sansArticle)
            if cle.count > 2 && !Normalisation.motsVides.contains(cle) && dejaVus.insert("absent:" + cle).inserted {
                inconnus.append(MotReconnu(texte: sansArticle, fiche: nil))
            }
        }
        return Array((connus + inconnus).prefix(limite))
    }
}
