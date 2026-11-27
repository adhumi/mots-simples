import DictionaryCore
import SwiftUI

/// La fiche d'un mot. Toutes les fiches ont la même mise en page, dans le même ordre :
/// image, mot, thème, définition, exemple, autres sens, à ne pas confondre, mots liés, statut.
struct FicheView: View {
    let slug: String

    @Environment(Bibliotheque.self) private var bibliotheque
    @Environment(LecteurVocal.self) private var lecteur

    var body: some View {
        Group {
            if let fiche = bibliotheque.dictionnaire.fiche(slug: slug) {
                contenu(fiche)
            } else {
                Text(Textes.ficheIntrouvable)
                    .police(.corps)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .carte()
                    .miseEnPageDEcran()
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .background(Jetons.Couleur.fond)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { lecteur.arreter() }
    }

    private func contenu(_ fiche: Fiche) -> some View {
        let dictionnaire = bibliotheque.dictionnaire
        let lecture = LectureDeFiche(fiche: fiche)
        let lies = dictionnaire.motsLies(de: fiche)

        return ScrollView {
            VStack(alignment: .leading, spacing: Jetons.Espace.m) {
                if fiche.statut == .brouillon {
                    BandeauDeStatut(fiche: fiche)
                }

                enTete(fiche, lecture: lecture)

                Bloc(titre: Textes.definition, lecture: "definition", enonces: lecture.definition) {
                    ForEach(lecture.definition, id: \.id) { Phrase(enonce: $0) }
                }

                Bloc(titre: Textes.exemple, lecture: "exemple", enonces: lecture.exemple) {
                    ForEach(lecture.exemple, id: \.id) { Phrase(enonce: $0) }
                }

                if !fiche.autresSens.isEmpty {
                    Bloc(
                        titre: fiche.autresSens.count > 1 ? Textes.autresSens : Textes.autreSens,
                        lecture: "sens",
                        enonces: lecture.autresSens
                    ) {
                        ForEach(lecture.autresSens, id: \.id) { enonce in
                            if enonce.id.hasSuffix("-0") && enonce.id != "sens-0-0" {
                                Divider().overlay(Jetons.Couleur.bordure)
                            }
                            Phrase(enonce: enonce)
                        }
                    }
                }

                if let confusion = fiche.aNePasConfondre {
                    Bloc(titre: Textes.aNePasConfondre, lecture: "confusion", enonces: lecture.aNePasConfondre) {
                        // Un lien seulement si le mot a sa fiche. Sinon, son nom seul.
                        if dictionnaire.fiche(slug: confusion.mot) != nil {
                            NavigationLink(value: Destination.fiche(confusion.mot)) {
                                Label(confusion.nomAffiche, systemImage: "arrow.right.circle.fill")
                                    .police(.corpsFort)
                                    .cibleMinimale()
                            }
                            .tint(Jetons.Couleur.accent)
                        } else {
                            Text(confusion.nomAffiche)
                                .police(.corpsFort)
                                .foregroundStyle(Jetons.Couleur.texte)
                                .padding(.horizontal, Jetons.Espace.s)
                        }
                        ForEach(lecture.aNePasConfondre.dropFirst(), id: \.id) { Phrase(enonce: $0) }
                    }
                }

                if !lies.isEmpty {
                    ListeDeMots(titre: Textes.motsLies, fiches: lies, liste: "lies")
                        .padding(.top, Jetons.Espace.s)
                }

                if fiche.statut != .brouillon {
                    BandeauDeStatut(fiche: fiche)
                }

                ChoixDeVitesse()
            }
            .miseEnPageDEcran()
        }
        .safeAreaInset(edge: .bottom) {
            BarreToutEcouter(enonces: lecture.tout)
        }
        .navigationTitle(fiche.mot)
        .onAppear {
            lecteur.arreter()
            bibliotheque.aConsulte(fiche)
        }
    }

    private func enTete(_ fiche: Fiche, lecture: LectureDeFiche) -> some View {
        VStack(alignment: .leading, spacing: Jetons.Espace.m) {
            ImageDeFiche(alt: fiche.pictogramme.alt, taille: Jetons.Taille.pictogramme)
                .frame(maxWidth: .infinity, alignment: .center)
            LigneOuColonne {
                Text(fiche.mot)
                    .police(.grandTitre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("fiche-mot")
                Spacer(minLength: Jetons.Espace.s)
                BoutonEcoute(lecture: "mot", enonces: lecture.mot, libelleAccessible: Textes.ecouterLeMot(fiche.mot))
            }
            Label(Textes.theme(bibliotheque.dictionnaire.nomDuTheme(fiche.theme)), systemImage: "tag.fill")
                .police(.note)
                .foregroundStyle(Jetons.Couleur.texteSecondaire)
        }
        .carte()
    }
}

/// Un bloc de la fiche : un titre, son bouton d'écoute, puis le texte.
private struct Bloc<Contenu: View>: View {
    let titre: String
    let lecture: String
    let enonces: [Enonce]
    @ViewBuilder let contenu: () -> Contenu

    var body: some View {
        VStack(alignment: .leading, spacing: Jetons.Espace.s) {
            LigneOuColonne {
                Text(titre)
                    .police(.sousTitre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: Jetons.Espace.s)
                BoutonEcoute(lecture: lecture, enonces: enonces, libelleAccessible: Textes.ecouterLeBloc(titre))
            }
            contenu()
        }
        .carte()
    }
}

/// Statut de la fiche : une image, un mot, une phrase. Jamais la couleur seule.
struct BandeauDeStatut: View {
    let fiche: Fiche

    var body: some View {
        let textes = self.textes
        HStack(alignment: .top, spacing: Jetons.Espace.s) {
            Image(systemName: textes.image)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Jetons.Espace.xs) {
                Text(textes.titre).police(.corpsFort)
                if let explication = textes.explication {
                    Text(explication).police(.note)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(fiche.statut == .brouillon ? Jetons.Couleur.alerteTexte : Jetons.Couleur.texteSecondaire)
        .padding(Jetons.Espace.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            fiche.statut == .brouillon ? Jetons.Couleur.alerteFond : Jetons.Couleur.carte,
            in: RoundedRectangle(cornerRadius: Jetons.Rayon.bouton, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("statut-\(fiche.statut.rawValue)")
    }

    private var textes: (image: String, titre: String, explication: String?) {
        switch fiche.statut {
        case .brouillon:
            return ("exclamationmark.triangle.fill", Textes.brouillonNonRelu, Textes.brouillonExplication)
        case .relu:
            return ("hourglass", Textes.pasEncoreValide, Textes.pasEncoreValideExplication)
        case .valide:
            if let date = fiche.valideLe.flatMap(Self.dateLisible) {
                return ("checkmark.seal.fill", Textes.valideLe(date), nil)
            }
            return ("checkmark.seal.fill", Textes.valide, nil)
        }
    }

    /// « 2026-12-03 » devient « 3 décembre 2026 ».
    static func dateLisible(_ iso: String) -> String? {
        let lecture = DateFormatter()
        lecture.calendar = Calendar(identifier: .gregorian)
        lecture.locale = Locale(identifier: "en_US_POSIX")
        lecture.timeZone = TimeZone(identifier: "UTC")
        lecture.dateFormat = "yyyy-MM-dd"
        guard let date = lecture.date(from: iso) else { return nil }
        let ecriture = DateFormatter()
        ecriture.locale = Locale(identifier: "fr_FR")
        ecriture.timeZone = TimeZone(identifier: "UTC")
        ecriture.dateStyle = .long
        return ecriture.string(from: date)
    }
}
