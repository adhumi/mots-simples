import SwiftUI

/// Petit bouton d'écoute : une image et un mot. Devient « Arrêter » pendant sa lecture.
struct BoutonEcoute: View {
    /// Identifiant de la lecture, unique dans l'écran.
    let lecture: String
    let enonces: [Enonce]
    /// Ce que VoiceOver annonce : « Écouter le mot facture », « Écouter : Définition ».
    let libelleAccessible: String

    @Environment(LecteurVocal.self) private var lecteur

    var body: some View {
        let enCours = lecteur.estEnCours(lecture)
        Button {
            lecteur.basculer(lecture, enonces: enonces)
        } label: {
            Label(enCours ? Textes.arreter : Textes.ecouter, systemImage: enCours ? "stop.fill" : "speaker.wave.2.fill")
                .police(.note)
                .cibleMinimale()
        }
        .buttonStyle(.secondaire)
        .buttonBorderShape(.capsule)
        .tint(Jetons.Couleur.accent)
        .accessibilityLabel(enCours ? Textes.arreter : libelleAccessible)
        .accessibilityIdentifier("ecouter-\(lecture)")
    }
}

/// Barre flottante « Tout écouter », en bas de la fiche. Seul élément en verre de l'écran.
struct BarreToutEcouter: View {
    let enonces: [Enonce]
    static let lecture = "tout"

    @Environment(LecteurVocal.self) private var lecteur

    var body: some View {
        let enCours = lecteur.estEnCours(Self.lecture)
        Button {
            lecteur.basculer(Self.lecture, enonces: enonces)
        } label: {
            Label(enCours ? Textes.arreter : Textes.toutEcouter, systemImage: enCours ? "stop.fill" : "speaker.wave.2.fill")
                .police(.corpsFort)
                .frame(maxWidth: .infinity, minHeight: Jetons.Taille.ciblePrincipale)
        }
        .boutonFlottant()
        .frame(maxWidth: Jetons.Taille.largeurDeLecture)
        .padding(.horizontal, Jetons.Espace.m)
        .padding(.bottom, Jetons.Espace.s)
        .accessibilityIdentifier("tout-ecouter")
    }
}

/// Une phrase de la fiche. Elle est mise en évidence pendant que la voix la lit.
/// La mise en évidence ne tient pas à la couleur seule : la phrase prend aussi un trait à gauche.
struct Phrase: View {
    let enonce: Enonce
    var style: StyleDeTexte = .corps

    @Environment(LecteurVocal.self) private var lecteur

    var body: some View {
        let lue = lecteur.enonceEnCours == enonce.id
        Text(enonce.texte)
            .police(style)
            .foregroundStyle(Jetons.Couleur.texte)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, Jetons.Espace.xs)
            .padding(.horizontal, Jetons.Espace.s)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                lue ? Jetons.Couleur.surlignage : Color.clear,
                in: RoundedRectangle(cornerRadius: Jetons.Rayon.petit, style: .continuous)
            )
            .overlay(alignment: .leading) {
                if lue {
                    Capsule().fill(Jetons.Couleur.accent).frame(width: Jetons.Espace.xs)
                }
            }
    }
}

/// Choix de la vitesse de la voix : deux boutons, chacun avec une image et un mot.
struct ChoixDeVitesse: View {
    @Environment(LecteurVocal.self) private var lecteur

    var body: some View {
        VStack(alignment: .leading, spacing: Jetons.Espace.s) {
            Text(Textes.vitesseDeLaVoix)
                .police(.sousTitre)
                .foregroundStyle(Jetons.Couleur.texte)
                .accessibilityAddTraits(.isHeader)
            LigneOuColonne {
                bouton(.normale, titre: Textes.vitesseNormale, image: "hare.fill")
                bouton(.lente, titre: Textes.vitesseLente, image: "tortoise.fill")
            }
        }
        .carte()
    }

    private func bouton(_ vitesse: VitesseDeVoix, titre: String, image: String) -> some View {
        let choisie = lecteur.vitesse == vitesse
        return Button {
            lecteur.choisir(vitesse: vitesse)
        } label: {
            HStack(spacing: Jetons.Espace.s) {
                Image(systemName: image)
                Text(titre)
                if choisie { Image(systemName: "checkmark.circle.fill") }
            }
            .police(choisie ? .corpsFort : .corps)
            .frame(maxWidth: .infinity, minHeight: Jetons.Taille.cible)
        }
        .buttonStyle(.secondaire)
        .buttonBorderShape(.roundedRectangle(radius: Jetons.Rayon.bouton))
        .tint(Jetons.Couleur.accent)
        .accessibilityAddTraits(choisie ? .isSelected : [])
        .accessibilityIdentifier("vitesse-\(vitesse.rawValue)")
    }
}
