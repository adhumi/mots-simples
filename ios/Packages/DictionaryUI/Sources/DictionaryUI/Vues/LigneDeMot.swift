import DictionaryCore
import SwiftUI

/// Un mot dans une liste : son image et son nom ouvrent la fiche, un bouton à part le prononce.
struct LigneDeMot: View {
    let fiche: Fiche
    /// Préfixe de l'identifiant de lecture, pour distinguer deux listes du même écran.
    var liste = "liste"

    var body: some View {
        LigneOuColonne {
            NavigationLink(value: Destination.fiche(fiche.slug)) {
                HStack(spacing: Jetons.Espace.m) {
                    ImageDeFiche(alt: fiche.pictogramme.alt, taille: Jetons.Taille.vignette, decorative: true)
                    Text(fiche.mot)
                        .police(.sousTitre)
                        .foregroundStyle(Jetons.Couleur.texte)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: Jetons.Espace.s)
                    Image(systemName: "chevron.right")
                        .fontWeight(.bold)
                        .foregroundStyle(Jetons.Couleur.accent)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: Jetons.Taille.ciblePrincipale)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("mot-\(fiche.slug)")

            BoutonEcoute(
                lecture: "\(liste):\(fiche.slug)",
                enonces: [Enonce(id: "\(liste):\(fiche.slug)", texte: fiche.motADire)],
                libelleAccessible: Textes.ecouterLeMot(fiche.mot)
            )
        }
        .carte()
    }
}

/// Une liste de mots sous un titre.
struct ListeDeMots: View {
    let titre: String
    let fiches: [Fiche]
    var liste = "liste"

    var body: some View {
        VStack(alignment: .leading, spacing: Jetons.Espace.s) {
            Text(titre)
                .police(.titre)
                .foregroundStyle(Jetons.Couleur.texte)
                .accessibilityAddTraits(.isHeader)
            ForEach(fiches) { fiche in
                LigneDeMot(fiche: fiche, liste: liste)
            }
        }
    }
}
