import AVFoundation
import DictionaryCore
import SwiftUI
import VisionKit

/// Photographier un mot. La caméra reconnaît le texte sur l'appareil et met les mots en évidence.
/// Aucune image n'est enregistrée ni envoyée : VisionKit travaille en direct, en mémoire.
enum Camera {
    /// Faux sur un appareil sans caméra ou trop ancien : le bouton n'apparaît alors pas.
    @MainActor static var priseEnCharge: Bool { DataScannerViewController.isSupported }

    /// Demande l'autorisation au premier usage. Renvoie faux si elle est refusée.
    static func autorisation() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }
}

/// Le lecteur de texte de VisionKit, dans SwiftUI.
private struct LecteurDeTexte: UIViewControllerRepresentable {
    /// Appelé avec le texte du bloc touché.
    let auToucher: (String) -> Void

    func makeCoordinator() -> Coordinateur { Coordinateur(auToucher: auToucher) }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let lecteur = DataScannerViewController(
            recognizedDataTypes: [.text(languages: ["fr-FR"])],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        lecteur.delegate = context.coordinator
        try? lecteur.startScanning()
        return lecteur
    }

    func updateUIViewController(_ lecteur: DataScannerViewController, context: Context) {}

    static func dismantleUIViewController(_ lecteur: DataScannerViewController, coordinator: Coordinateur) {
        lecteur.stopScanning()
    }

    @MainActor
    final class Coordinateur: NSObject, DataScannerViewControllerDelegate {
        let auToucher: (String) -> Void

        init(auToucher: @escaping (String) -> Void) {
            self.auToucher = auToucher
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case .text(let texte) = item {
                auToucher(texte.transcript)
            }
        }
    }
}

/// L'écran de la caméra : une consigne, la caméra, puis le choix du mot.
struct PhotoView: View {
    /// Appelé quand la personne a choisi un mot.
    let auChoix: (MotReconnu) -> Void

    @Environment(Bibliotheque.self) private var bibliotheque
    @Environment(\.dismiss) private var fermer
    @State private var propositions: [MotReconnu] = []

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                LecteurDeTexte { texte in
                    let mots = bibliotheque.dictionnaire.motsReconnus(dans: texte)
                    if mots.count == 1, let seul = mots.first {
                        auChoix(seul)
                    } else {
                        propositions = mots
                    }
                }
                .ignoresSafeArea()

                if propositions.isEmpty {
                    Label(Textes.touchezUnMot, systemImage: "hand.tap.fill")
                        .police(.corpsFort)
                        .foregroundStyle(Jetons.Couleur.texte)
                        .padding(Jetons.Espace.m)
                        .background(Jetons.Couleur.carte, in: Capsule())
                        .padding(Jetons.Espace.m)
                } else {
                    choixDuMot
                }
            }
            .navigationTitle(Textes.prendreEnPhoto)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        fermer()
                    } label: {
                        Label(Textes.fermer, systemImage: "xmark")
                            .labelStyle(.titleAndIcon)
                    }
                    .accessibilityIdentifier("fermer-photo")
                }
            }
        }
    }

    /// Le bloc touché contient plusieurs mots : on demande lequel. Les mots du dictionnaire sont en premier.
    private var choixDuMot: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Jetons.Espace.s) {
                Text(Textes.quelMot)
                    .police(.sousTitre)
                    .foregroundStyle(Jetons.Couleur.texte)
                    .accessibilityAddTraits(.isHeader)
                ForEach(propositions) { mot in
                    Button {
                        auChoix(mot)
                    } label: {
                        Label(mot.fiche?.mot ?? mot.texte, systemImage: mot.fiche == nil ? "questionmark.circle" : "book.fill")
                            .police(mot.fiche == nil ? .corps : .corpsFort)
                            .frame(maxWidth: .infinity, minHeight: Jetons.Taille.cible, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: Jetons.Rayon.bouton))
                    .tint(Jetons.Couleur.accent)
                }
                Button {
                    propositions = []
                } label: {
                    Label(Textes.choisirUnAutreTexte, systemImage: "arrow.uturn.backward")
                        .police(.note)
                        .cibleMinimale()
                }
                .buttonStyle(.borderless)
                .tint(Jetons.Couleur.accent)
            }
            .padding(Jetons.Espace.m)
        }
        .frame(maxHeight: Jetons.Taille.choixDuMot)
        .background(Jetons.Couleur.carte, in: RoundedRectangle(cornerRadius: Jetons.Rayon.carte, style: .continuous))
        .padding(Jetons.Espace.m)
    }
}
