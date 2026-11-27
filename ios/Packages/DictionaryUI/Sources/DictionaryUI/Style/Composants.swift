import SwiftUI

/// Carte blanche opaque à bordure légère. Le contenu à lire n'est jamais en verre.
private struct Carte: ViewModifier {
    @Environment(\.colorSchemeContrast) private var contraste

    func body(content: Content) -> some View {
        let forme = RoundedRectangle(cornerRadius: Jetons.Rayon.carte, style: .continuous)
        content
            .padding(Jetons.Espace.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Jetons.Couleur.carte, in: forme)
            .overlay(
                forme.strokeBorder(
                    contraste == .increased ? Jetons.Couleur.bordureForte : Jetons.Couleur.bordure,
                    lineWidth: contraste == .increased ? Jetons.Taille.bordureForte : Jetons.Taille.bordure
                )
            )
    }
}

/// Style des éléments flottants : Liquid Glass, ou rendu opaque
/// quand « Réduire la transparence » ou « Augmenter le contraste » est activé.
private struct BoutonFlottant: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var sansTransparence
    @Environment(\.colorSchemeContrast) private var contraste

    func body(content: Content) -> some View {
        if sansTransparence || contraste == .increased {
            content.buttonStyle(.borderedProminent)
        } else {
            content.buttonStyle(.glassProminent)
        }
    }
}

/// Fond d'écran teinté et largeur de lecture limitée, pour l'iPad.
private struct Ecran: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: Jetons.Taille.largeurDeLecture, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Jetons.Espace.m)
            .padding(.vertical, Jetons.Espace.l)
    }
}

/// Bouton secondaire : texte vert sur le fond d'une carte, bordure verte. Même dessin que sur le site.
/// Les couleurs viennent des jetons, donc leur contraste est connu et contrôlé : 6,47 pour 1 en clair.
struct BoutonSecondaire: ButtonStyle {
    @Environment(\.isEnabled) private var actif

    // « ButtonStyleConfiguration » en toutes lettres : le module a son propre type « Configuration ».
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        let forme = RoundedRectangle(cornerRadius: Jetons.Rayon.bouton, style: .continuous)
        configuration.label
            .foregroundStyle(Jetons.Couleur.accent)
            .padding(.horizontal, Jetons.Espace.m)
            .padding(.vertical, Jetons.Espace.xs)
            .background(configuration.isPressed ? Jetons.Couleur.imageNeutre : Jetons.Couleur.carte, in: forme)
            .overlay(forme.strokeBorder(Jetons.Couleur.accent, lineWidth: Jetons.Taille.bordureForte))
            .contentShape(forme)
            .opacity(actif ? 1 : 0.5)
    }
}

extension ButtonStyle where Self == BoutonSecondaire {
    static var secondaire: BoutonSecondaire { BoutonSecondaire() }
}

extension View {
    func carte() -> some View { modifier(Carte()) }

    func boutonFlottant() -> some View {
        modifier(BoutonFlottant())
            .buttonBorderShape(.capsule)
            .controlSize(.extraLarge)
            .tint(Jetons.Couleur.accent)
    }

    func miseEnPageDEcran() -> some View { modifier(Ecran()) }

    /// Cible tactile d'au moins 44 points dans les deux sens.
    func cibleMinimale() -> some View {
        frame(minWidth: Jetons.Taille.cible, minHeight: Jetons.Taille.cible)
    }
}

/// Range ses éléments en ligne, ou en colonne aux très grandes tailles de texte, pour ne rien couper.
struct LigneOuColonne<Contenu: View>: View {
    @Environment(\.dynamicTypeSize) private var tailleDuTexte
    private let contenu: Contenu

    init(@ViewBuilder contenu: () -> Contenu) {
        self.contenu = contenu()
    }

    var body: some View {
        if tailleDuTexte.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Jetons.Espace.s) { contenu }
        } else {
            HStack(alignment: .center, spacing: Jetons.Espace.s) { contenu }
        }
    }
}

/// Image d'une fiche. Tant que le pictogramme n'est pas choisi, une image neutre le remplace.
struct ImageDeFiche: View {
    let alt: String
    let taille: CGFloat
    /// Dans une liste, l'image est à côté du mot : elle n'apporte rien de plus à VoiceOver.
    var decorative = false

    var body: some View {
        RoundedRectangle(cornerRadius: taille >= Jetons.Taille.pictogramme ? Jetons.Rayon.carte : Jetons.Rayon.petit, style: .continuous)
            .fill(Jetons.Couleur.imageNeutre)
            .frame(width: taille, height: taille)
            .overlay(
                Image(systemName: taille >= Jetons.Taille.pictogramme ? "photo" : "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(taille / 4)
                    .foregroundStyle(Jetons.Couleur.texteSecondaire)
            )
            .accessibilityElement()
            .accessibilityLabel(alt)
            .accessibilityAddTraits(.isImage)
            .accessibilityHidden(decorative)
    }
}
