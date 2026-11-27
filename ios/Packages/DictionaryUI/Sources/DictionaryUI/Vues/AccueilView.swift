import DictionaryCore
import SwiftUI

/// Accueil : chercher un mot. L'app s'ouvre ici, sans rien demander.
struct AccueilView: View {
    @Environment(Bibliotheque.self) private var bibliotheque
    @Environment(Aiguillage.self) private var aiguillage
    @State private var requete = ""
    @FocusState private var champActif: Bool

    private var requeteUtile: Bool {
        Normalisation.normaliser(requete).count >= IndexDeRecherche.longueurMinimale
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Jetons.Espace.l) {
                Text(Textes.chercherUnMot)
                    .police(.grandTitre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .accessibilityAddTraits(.isHeader)

                champDeRecherche

                if bibliotheque.dictionnaire.fiches.isEmpty {
                    message(Textes.dictionnaireVide)
                } else if requeteUtile {
                    resultats
                } else {
                    derniersMots
                }
            }
            .miseEnPageDEcran()
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Jetons.Couleur.fond)
        // Bouton flottant, en verre : le seul chemin vers les thèmes. Pas de barre d'onglets.
        .safeAreaInset(edge: .bottom) {
            if !champActif && !bibliotheque.dictionnaire.fiches.isEmpty {
                Button {
                    aiguillage.allerA(.themes)
                } label: {
                    Label(Textes.voirLesThemes, systemImage: "square.grid.2x2.fill")
                        .police(.corpsFort)
                        .frame(maxWidth: .infinity, minHeight: Jetons.Taille.ciblePrincipale)
                }
                .boutonFlottant()
                .frame(maxWidth: Jetons.Taille.largeurDeLecture)
                .padding(.horizontal, Jetons.Espace.m)
                .padding(.bottom, Jetons.Espace.s)
                .accessibilityIdentifier("voir-les-themes")
            }
        }
        .navigationTitle(Textes.nomDeLApp)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var champDeRecherche: some View {
        VStack(alignment: .leading, spacing: Jetons.Espace.s) {
            Text(Textes.ecrivezLeMot)
                .police(.corpsFort)
                .foregroundStyle(Jetons.Couleur.texte)
                .accessibilityHidden(true)
            HStack(spacing: Jetons.Espace.s) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Jetons.Couleur.accent)
                    .accessibilityHidden(true)
                TextField(Textes.exempleDeRecherche, text: $requete)
                    .police(.sousTitre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .focused($champActif)
                    .accessibilityLabel(Textes.ecrivezLeMot)
                    .accessibilityIdentifier("champ-recherche")
                    .frame(minHeight: Jetons.Taille.ciblePrincipale)
            }
            .padding(.horizontal, Jetons.Espace.m)
            .background(Jetons.Couleur.carte, in: RoundedRectangle(cornerRadius: Jetons.Rayon.bouton, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Jetons.Rayon.bouton, style: .continuous)
                    .strokeBorder(Jetons.Couleur.bordureForte, lineWidth: Jetons.Taille.bordureForte)
            )
            if !requete.isEmpty {
                Button {
                    requete = ""
                    champActif = true
                } label: {
                    Label(Textes.effacer, systemImage: "xmark.circle.fill")
                        .police(.note)
                        .cibleMinimale()
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(Jetons.Couleur.accent)
                .accessibilityIdentifier("effacer")
            }
        }
    }

    @ViewBuilder
    private var resultats: some View {
        let trouves = bibliotheque.dictionnaire.chercher(requete)
        if trouves.isEmpty {
            MotAbsentView(requete: requete)
        } else {
            ListeDeMots(titre: Textes.resultats, fiches: trouves, liste: "resultats")
        }
    }

    @ViewBuilder
    private var derniersMots: some View {
        let derniers = bibliotheque.derniersMots
        if derniers.isEmpty {
            VStack(alignment: .leading, spacing: Jetons.Espace.s) {
                Text(Textes.vosDerniersMots)
                    .police(.titre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .accessibilityAddTraits(.isHeader)
                message(Textes.aucunDernierMot)
            }
        } else {
            ListeDeMots(titre: Textes.vosDerniersMots, fiches: derniers, liste: "derniers")
        }
    }

    private func message(_ texte: String) -> some View {
        Text(texte)
            .police(.corps)
            .foregroundStyle(Jetons.Couleur.texteSecondaire)
            .fixedSize(horizontal: false, vertical: true)
            .carte()
    }
}

/// Le mot cherché n'a pas de fiche. On le dit simplement et on propose des mots proches.
struct MotAbsentView: View {
    let requete: String
    @Environment(Bibliotheque.self) private var bibliotheque

    var body: some View {
        VStack(alignment: .leading, spacing: Jetons.Espace.l) {
            Label {
                Text(Textes.motAbsent)
                    .police(.corpsFort)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(Jetons.Couleur.accent)
            }
            .carte()
            .accessibilityIdentifier("mot-absent")

            let proches = bibliotheque.dictionnaire.motsProches(de: requete)
            if !proches.isEmpty {
                ListeDeMots(titre: Textes.motsProches, fiches: proches, liste: "proches")
            }
        }
    }
}
