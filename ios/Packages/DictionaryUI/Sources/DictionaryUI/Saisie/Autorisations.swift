import SwiftUI
import UIKit

/// Message affiché quand une autorisation a été refusée : il dit quoi faire, sans rien bloquer.
/// Le bouton de la fonction reste en place. Le reste de l'app marche comme avant.
struct AideAutorisation: View {
    let texte: String

    var body: some View {
        VStack(alignment: .leading, spacing: Jetons.Espace.s) {
            Label {
                Text(texte)
                    .police(.corps)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Jetons.Couleur.accent)
            }
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(Textes.ouvrirLesReglages, systemImage: "gearshape.fill")
                    .police(.note)
                    .cibleMinimale()
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .tint(Jetons.Couleur.accent)
        }
        .carte()
    }
}

/// Bouton d'action de l'accueil : une image et un mot, sur toute la largeur.
struct BoutonDAction: View {
    let titre: String
    let image: String
    let identifiant: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // L'image est centrée en hauteur sur tout le texte, même quand il tient sur plusieurs lignes.
            // Une étiquette standard aligne l'image sur la première ligne seulement.
            HStack(alignment: .center, spacing: Jetons.Espace.s) {
                Image(systemName: image)
                    .accessibilityHidden(true)
                Text(titre)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .police(.corpsFort)
            .frame(maxWidth: .infinity, minHeight: Jetons.Taille.ciblePrincipale, alignment: .center)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: Jetons.Rayon.bouton))
        .tint(Jetons.Couleur.accent)
        .accessibilityIdentifier(identifiant)
    }
}
