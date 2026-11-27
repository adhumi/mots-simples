import DictionaryCore
import SwiftUI

/// La grille des huit thèmes : pour trouver un mot sans savoir l'écrire.
struct ThemesView: View {
    @Environment(Bibliotheque.self) private var bibliotheque
    @Environment(Aiguillage.self) private var aiguillage

    private let colonnes = [GridItem(.adaptive(minimum: Jetons.Taille.caseDeTheme), spacing: Jetons.Espace.s)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Jetons.Espace.l) {
                Text(Textes.lesThemes)
                    .police(.grandTitre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .accessibilityAddTraits(.isHeader)
                Text(Textes.choisissezUnTheme)
                    .police(.corps)
                    .foregroundStyle(Jetons.Couleur.texteSecondaire)

                LazyVGrid(columns: colonnes, spacing: Jetons.Espace.s) {
                    ForEach(bibliotheque.dictionnaire.themes) { theme in
                        caseDeTheme(theme)
                    }
                }
            }
            .miseEnPageDEcran()
        }
        .background(Jetons.Couleur.fond)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func caseDeTheme(_ theme: Theme) -> some View {
        let nombre = bibliotheque.dictionnaire.fiches(duTheme: theme.slug).count
        return Button {
            // La liste remplace la grille : depuis la liste, « Retour » ramène à l'accueil, comme depuis la grille.
            aiguillage.ouvrir(.theme(theme.slug))
        } label: {
            VStack(alignment: .leading, spacing: Jetons.Espace.s) {
                Image(systemName: Jetons.Theme.image(theme.slug))
                    .resizable()
                    .scaledToFit()
                    .frame(width: Jetons.Taille.imageDeTheme, height: Jetons.Taille.imageDeTheme)
                    .foregroundStyle(Jetons.Theme.couleur(theme.slug))
                    .accessibilityHidden(true)
                Text(theme.nom)
                    .police(.sousTitre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(Textes.nombreDeMots(nombre))
                    .police(.note)
                    .foregroundStyle(Jetons.Couleur.texteSecondaire)
            }
            .frame(maxWidth: .infinity, minHeight: Jetons.Taille.ciblePrincipale, alignment: .topLeading)
            .carte()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("theme-\(theme.slug)")
    }
}

/// Les mots d'un thème, chacun avec son bouton d'écoute.
struct ThemeView: View {
    let slug: String
    @Environment(Bibliotheque.self) private var bibliotheque
    @Environment(LecteurVocal.self) private var lecteur

    var body: some View {
        let dictionnaire = bibliotheque.dictionnaire
        let fiches = dictionnaire.fiches(duTheme: slug)
        ScrollView {
            VStack(alignment: .leading, spacing: Jetons.Espace.l) {
                Label {
                    Text(dictionnaire.nomDuTheme(slug))
                        .police(.grandTitre)
                        .foregroundStyle(Jetons.Couleur.texte)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: Jetons.Theme.image(slug))
                        .foregroundStyle(Jetons.Theme.couleur(slug))
                }
                .accessibilityAddTraits(.isHeader)

                if fiches.isEmpty {
                    Text(Textes.aucunMotDansLeTheme)
                        .police(.corps)
                        .foregroundStyle(Jetons.Couleur.texteSecondaire)
                        .carte()
                } else {
                    Text(Textes.nombreDeMots(fiches.count))
                        .police(.note)
                        .foregroundStyle(Jetons.Couleur.texteSecondaire)
                    ForEach(fiches) { fiche in
                        LigneDeMot(fiche: fiche, liste: "theme")
                    }
                }
            }
            .miseEnPageDEcran()
        }
        .background(Jetons.Couleur.fond)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { lecteur.arreter() }
    }
}
