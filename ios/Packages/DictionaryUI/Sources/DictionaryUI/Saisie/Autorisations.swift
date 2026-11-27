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
            .buttonStyle(.secondaire)
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
            Label(titre, systemImage: image)
                .police(.corpsFort)
                .frame(maxWidth: .infinity, minHeight: Jetons.Taille.ciblePrincipale)
        }
        .buttonStyle(.secondaire)
        .buttonBorderShape(.roundedRectangle(radius: Jetons.Rayon.bouton))
        .tint(Jetons.Couleur.accent)
        .accessibilityIdentifier(identifiant)
    }
}
