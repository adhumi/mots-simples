import Foundation

/// Réglages de compilation, lus dans Info.plist. Leurs valeurs viennent de Config/MotsSimples.xcconfig.
enum Reglages {
    /// Vrai pour un build de préversion (simulateur, TestFlight) : les brouillons sont affichés, avec leur bandeau.
    /// Un build public met ce réglage à NO et n'embarque que des fiches relues ou validées.
    static var preversion: Bool {
        (Bundle.main.object(forInfoDictionaryKey: "MotsSimplesPreversion") as? String) == "YES"
    }
}
