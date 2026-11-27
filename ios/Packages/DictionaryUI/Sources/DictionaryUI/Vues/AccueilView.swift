import DictionaryCore
import SwiftUI

/// Accueil : chercher un mot. L'app s'ouvre ici, sans rien demander.
struct AccueilView: View {
    @Environment(Bibliotheque.self) private var bibliotheque
    @Environment(Aiguillage.self) private var aiguillage
    @Environment(LecteurVocal.self) private var lecteur
    @Environment(\.configuration) private var configuration
    @State private var requete = ""
    @FocusState private var champActif: Bool
    @State private var dictee = DicteeVocale()
    @State private var cameraOuverte = false
    @State private var cameraRefusee = false

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

                if !configuration.modeReduit {
                    autresFaconsDeChercher
                }

                if bibliotheque.dictionnaire.fiches.isEmpty {
                    message(Textes.dictionnaireVide)
                } else if requeteUtile {
                    resultats
                } else {
                    derniersMots
                }

                if !configuration.modeReduit && !requeteUtile {
                    BoutonDAction(titre: Textes.aideEtAPropos, image: "questionmark.circle.fill", identifiant: "aide") {
                        aiguillage.allerA(.aide)
                    }
                }
            }
            .miseEnPageDEcran()
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Jetons.Couleur.fond)
        // Le texte qui défile sous le bouton flottant ne se lit pas au travers : le bord du défilement est net.
        .scrollEdgeEffectStyle(.hard, for: .bottom)
        // Bouton flottant, en verre : le seul chemin vers les thèmes. Pas de barre d'onglets.
        .safeAreaBar(edge: .bottom) {
            if !champActif && !configuration.modeReduit && !bibliotheque.dictionnaire.fiches.isEmpty {
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
        // Siri ou un lien a demandé un mot sans fiche : il arrive dans la recherche.
        .onChange(of: aiguillage.rechercheDemandee, initial: true) { _, demande in
            if let demande {
                requete = demande
                aiguillage.rechercheDemandee = nil
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
                // Le texte d'exemple prend la couleur secondaire de l'app : le gris du système est trop pâle.
                // Le champ passe à la ligne aux grandes tailles de texte, au lieu de couper le mot.
                TextField(
                    Textes.exempleDeRecherche,
                    text: $requete,
                    prompt: Text(Textes.exempleDeRecherche).foregroundStyle(Jetons.Couleur.texteSecondaire),
                    axis: .vertical
                )
                    .lineLimit(1...3)
                    // « Rechercher » range le clavier : les résultats prennent tout l'écran.
                    .onSubmit { champActif = false }
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

    /// Chercher en parlant ou en prenant une photo. Chaque autorisation est demandée au premier usage seulement.
    @ViewBuilder
    private var autresFaconsDeChercher: some View {
        VStack(alignment: .leading, spacing: Jetons.Espace.s) {
            LigneOuColonne {
                BoutonDAction(
                    titre: dictee.etat == .ecoute ? Textes.arreter : Textes.direLeMot,
                    image: dictee.etat == .ecoute ? "stop.fill" : "mic.fill",
                    identifiant: "dire-le-mot"
                ) {
                    champActif = false
                    lecteur.arreter()
                    Task { await dictee.basculer() }
                }
                // Sur un appareil sans caméra ou sans prise en charge, le bouton n'apparaît pas.
                if Camera.priseEnCharge {
                    BoutonDAction(titre: Textes.prendreEnPhoto, image: "camera.fill", identifiant: "prendre-en-photo") {
                        champActif = false
                        lecteur.arreter()
                        dictee.arreter()
                        Task {
                            if await Camera.autorisation() {
                                cameraRefusee = false
                                cameraOuverte = true
                            } else {
                                cameraRefusee = true
                            }
                        }
                    }
                }
            }

            switch dictee.etat {
            case .ecoute:
                Label(Textes.jEcoute, systemImage: "waveform")
                    .police(.corpsFort)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .carte()
            case .refusee:
                AideAutorisation(texte: Textes.microRefuse)
            case .indisponible:
                AideAutorisation(texte: Textes.dicteeIndisponible)
            case .repos:
                EmptyView()
            }
            if cameraRefusee {
                AideAutorisation(texte: Textes.cameraRefusee)
            }
        }
        .onChange(of: dictee.texte) { _, entendu in
            if !entendu.isEmpty { requete = entendu }
        }
        .onDisappear { dictee.arreter() }
        .fullScreenCover(isPresented: $cameraOuverte) {
            PhotoView { mot in
                cameraOuverte = false
                if let fiche = mot.fiche {
                    requete = ""
                    aiguillage.allerA(.fiche(fiche.slug))
                } else {
                    // Pas de fiche : le mot arrive dans la recherche, qui affiche « Mot absent » et les mots proches.
                    requete = mot.texte
                }
            }
            .environment(bibliotheque)
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

extension MotAbsentView {
    /// « Demander ce mot ». Seul le mot part. Le texte ne peut pas partir s'il contient autre chose que des lettres.
    @ViewBuilder
    fileprivate var demande: some View {
        if demandes.disponible, let mot = Demande.nettoyer(requete) {
            VStack(alignment: .leading, spacing: Jetons.Espace.s) {
                switch demandes.etat(pour: mot) {
                case .envoye:
                    Label(Textes.demandeEnvoyee, systemImage: "checkmark.circle.fill")
                        .police(.corpsFort)
                        .foregroundStyle(Jetons.Couleur.texte)
                        .accessibilityIdentifier("demande-envoyee")
                case .enAttente:
                    Label(Textes.demandeEnAttente, systemImage: "clock.fill")
                        .police(.corpsFort)
                        .foregroundStyle(Jetons.Couleur.texte)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("demande-en-attente")
                case .envoi:
                    Label(Textes.demandeEnCours, systemImage: "paperplane.fill")
                        .police(.corpsFort)
                        .foregroundStyle(Jetons.Couleur.texte)
                case nil:
                    Text(Textes.seulLeMotPart(mot))
                        .police(.corps)
                        .foregroundStyle(Jetons.Couleur.texte)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(Textes.rienDePersonnel)
                        .police(.corpsFort)
                        .foregroundStyle(Jetons.Couleur.texte)
                        .fixedSize(horizontal: false, vertical: true)
                    BoutonDAction(titre: Textes.demanderCeMot, image: "paperplane.fill", identifiant: "demander-ce-mot") {
                        Task { await demandes.demander(mot) }
                    }
                }
            }
            .carte()
        }
    }
}

/// Le mot cherché n'a pas de fiche. On le dit simplement et on propose des mots proches.
struct MotAbsentView: View {
    let requete: String
    @Environment(Bibliotheque.self) private var bibliotheque
    @Environment(ServiceDeDemandes.self) private var demandes
    @Environment(\.configuration) private var configuration

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

            if !configuration.modeReduit {
                demande
            }

            let proches = bibliotheque.dictionnaire.motsProches(de: requete)
            if !proches.isEmpty {
                ListeDeMots(titre: Textes.motsProches, fiches: proches, liste: "proches")
            }
        }
    }
}
