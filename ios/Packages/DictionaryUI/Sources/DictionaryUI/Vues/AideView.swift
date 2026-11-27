import SwiftUI

/// Aide et à propos : un écran simple, sans action obligatoire.
struct AideView: View {
    @Environment(Bibliotheque.self) private var bibliotheque
    @Environment(LecteurVocal.self) private var lecteur
    @Environment(\.configuration) private var configuration

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Jetons.Espace.m) {
                Text(Textes.aideEtAPropos)
                    .police(.grandTitre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .accessibilityAddTraits(.isHeader)

                section(Textes.aideCommentTitre, image: "questionmark.circle.fill", phrases: [
                    Textes.aideComment1, Textes.aideComment2, Textes.aideComment3, Textes.aideComment4,
                ])

                VStack(alignment: .leading, spacing: Jetons.Espace.s) {
                    ChoixDeVitesse()
                    BoutonEcoute(
                        lecture: "essai-de-voix",
                        enonces: [Enonce(id: "essai-de-voix", texte: Textes.essaiDeVoix)],
                        libelleAccessible: Textes.ecouterUnEssai
                    )
                }

                section(Textes.aideAttentionTitre, image: "exclamationmark.triangle.fill", phrases: [
                    Textes.aideAttention1, Textes.aideAttention2,
                ])

                section(Textes.aideViePriveeTitre, image: "lock.fill", phrases: [
                    Textes.aideViePrivee1, Textes.aideViePrivee2, Textes.aideViePrivee3, Textes.aideViePrivee4,
                ])

                section(Textes.aideTextesTitre, image: "checkmark.seal.fill", phrases: [
                    Textes.aideTextes1, Textes.aideTextes2, Textes.aideTextes3,
                ])

                section(Textes.aideQuiTitre, image: "person.fill", phrases: [
                    Textes.aideQui1, Textes.aideQui2,
                ])

                section(Textes.aideCreditsTitre, image: "heart.fill", phrases: [
                    Textes.creditPictogrammes, Textes.creditPolice, Textes.creditLicences,
                ])

                Text(Textes.versions(app: configuration.versionDeLApp, contenu: bibliotheque.dictionnaire.paquet.genereLe))
                    .police(.note)
                    .foregroundStyle(Jetons.Couleur.texteSecondaire)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .miseEnPageDEcran()
        }
        .background(Jetons.Couleur.fond)
        .navigationTitle(Textes.aideEtAPropos)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { lecteur.arreter() }
    }

    private func section(_ titre: String, image: String, phrases: [String]) -> some View {
        VStack(alignment: .leading, spacing: Jetons.Espace.s) {
            Label {
                Text(titre)
                    .police(.sousTitre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: image)
                    .foregroundStyle(Jetons.Couleur.accent)
            }
            .accessibilityAddTraits(.isHeader)
            ForEach(phrases, id: \.self) { phrase in
                Text(phrase)
                    .police(.corps)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .carte()
    }
}
