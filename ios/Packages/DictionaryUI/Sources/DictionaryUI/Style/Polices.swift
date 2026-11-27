import CoreText
import SwiftUI

/// Les styles de texte de l'app. Chacun suit la taille de texte choisie dans les réglages du téléphone.
public enum StyleDeTexte: Sendable {
    case grandTitre
    case titre
    case sousTitre
    case corps
    case corpsFort
    case note

    var taille: CGFloat {
        switch self {
        case .grandTitre: 34
        case .titre: 26
        case .sousTitre: 21
        case .corps, .corpsFort: 19
        case .note: 16
        }
    }

    var relatifA: Font.TextStyle {
        switch self {
        case .grandTitre: .largeTitle
        case .titre: .title
        case .sousTitre: .title3
        case .corps, .corpsFort: .body
        case .note: .footnote
        }
    }

    var estFort: Bool {
        switch self {
        case .grandTitre, .titre, .sousTitre, .corpsFort: true
        case .corps, .note: false
        }
    }
}

/// Police Lexend, embarquée dans l'app. Licence SIL Open Font License 1.1, voir Ressources/Polices/LICENCE-Lexend.txt.
public enum Polices {
    static let fichiers = ["Lexend-Regular", "Lexend-SemiBold", "Lexend-Bold"]

    private static let enregistrement: Void = {
        for nom in fichiers {
            guard let url = Bundle.module.url(forResource: nom, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()

    /// À appeler une fois au lancement de l'app. Sans effet les fois suivantes.
    public static func enregistrer() {
        _ = enregistrement
    }

    /// `gras` suit le réglage « Texte en gras » du téléphone : chaque style monte d'une graisse.
    static func police(_ style: StyleDeTexte, gras: Bool) -> Font {
        enregistrer()
        let nom: String
        switch (style.estFort, gras) {
        case (false, false): nom = "Lexend-Regular"
        case (false, true), (true, false): nom = "Lexend-SemiBold"
        case (true, true): nom = "Lexend-Bold"
        }
        return .custom(nom, size: style.taille, relativeTo: style.relatifA)
    }
}

private struct PoliceDeStyle: ViewModifier {
    let style: StyleDeTexte
    @Environment(\.legibilityWeight) private var graisse

    func body(content: Content) -> some View {
        content.font(Polices.police(style, gras: graisse == .bold))
    }
}

extension View {
    /// Applique un style de texte de l'app.
    public func police(_ style: StyleDeTexte) -> some View {
        modifier(PoliceDeStyle(style: style))
    }
}
