import SwiftUI
import UIKit

/// Jetons de style : toutes les couleurs, rayons, espacements et tailles de l'app.
/// Aucune vue ne porte de valeur en dur.
public enum Jetons {
    public enum Couleur {
        /// Fond teinté de tous les écrans.
        public static let fond = dynamique(clair: 0xEEF6F0, sombre: 0x0F1A14)
        /// Fond opaque des cartes de contenu.
        public static let carte = dynamique(clair: 0xFFFFFF, sombre: 0x1B2A22)
        /// Bordure légère des cartes. Décorative : la carte se détache aussi par sa couleur.
        public static let bordure = dynamique(clair: 0xC9DDD0, sombre: 0x35493E)
        /// Bordure du mode « Augmenter le contraste » et des champs de saisie : 3 pour 1 au moins sur le fond.
        public static let bordureForte = dynamique(clair: 0x4F6B5A, sombre: 0xA9C4B4)
        /// Vert calme : boutons et liens.
        public static let accent = dynamique(clair: 0x1F6B45, sombre: 0x7FD6A4)
        public static let surAccent = dynamique(clair: 0xFFFFFF, sombre: 0x0B1F14)
        public static let texte = dynamique(clair: 0x15231B, sombre: 0xF1F7F3)
        public static let texteSecondaire = dynamique(clair: 0x44584C, sombre: 0xB9CCBF)
        /// Fond de la phrase en cours de lecture.
        public static let surlignage = dynamique(clair: 0xFFE9A8, sombre: 0x5C4A00)
        /// Bandeau « Brouillon non relu ».
        public static let alerteFond = dynamique(clair: 0xFFF1D6, sombre: 0x4A3200)
        public static let alerteTexte = dynamique(clair: 0x5F3B00, sombre: 0xFFDFA3)
        /// Fond neutre de l'image qui remplace un pictogramme absent.
        public static let imageNeutre = dynamique(clair: 0xDDEDE2, sombre: 0x26392F)

        static func dynamique(clair: UInt32, sombre: UInt32) -> Color {
            Color(UIColor { traits in
                UIColor(hex: traits.userInterfaceStyle == .dark ? sombre : clair)
            })
        }
    }

    /// Couleur et image de chaque thème. Le nom du thème est toujours écrit à côté : jamais la couleur seule.
    public enum Theme {
        public static func couleur(_ slug: String) -> Color {
            switch slug {
            case "argent": Couleur.dynamique(clair: 0x1F6B45, sombre: 0x7FD6A4)
            case "sante": Couleur.dynamique(clair: 0xA3324A, sombre: 0xF3A3B4)
            case "logement": Couleur.dynamique(clair: 0x8A4B10, sombre: 0xF0B987)
            case "travail": Couleur.dynamique(clair: 0x1D5C96, sombre: 0x9CC8F2)
            case "papiers": Couleur.dynamique(clair: 0x5B4A9E, sombre: 0xC3B8F5)
            case "justice": Couleur.dynamique(clair: 0x6B5A12, sombre: 0xE3D184)
            case "transports": Couleur.dynamique(clair: 0x0F6A70, sombre: 0x86D5DB)
            case "vie-quotidienne": Couleur.dynamique(clair: 0x8C3A7A, sombre: 0xEBA9DC)
            default: Couleur.accent
            }
        }

        /// Symbole SF du thème.
        public static func image(_ slug: String) -> String {
            switch slug {
            case "argent": "eurosign.circle.fill"
            case "sante": "cross.case.fill"
            case "logement": "house.fill"
            case "travail": "briefcase.fill"
            case "papiers": "doc.text.fill"
            case "justice": "building.columns.fill"
            case "transports": "bus.fill"
            case "vie-quotidienne": "basket.fill"
            default: "tag.fill"
            }
        }
    }

    public enum Rayon {
        public static let carte: CGFloat = 24
        public static let bouton: CGFloat = 20
        public static let petit: CGFloat = 12
    }

    public enum Espace {
        public static let xs: CGFloat = 4
        public static let s: CGFloat = 8
        public static let m: CGFloat = 16
        public static let l: CGFloat = 24
        public static let xl: CGFloat = 32
    }

    public enum Taille {
        /// Cible tactile minimale.
        public static let cible: CGFloat = 44
        /// Diamètre visible du petit bouton d'écoute. Sa zone de toucher reste de 44 points.
        public static let boutonDEcoute: CGFloat = 30
        /// Taille du haut-parleur dans ce bouton.
        public static let imageDuBoutonDEcoute: CGFloat = 14
        /// Cible visée pour les actions principales.
        public static let ciblePrincipale: CGFloat = 60
        public static let pictogramme: CGFloat = 140
        /// Largeur minimale d'une case de la grille des thèmes.
        public static let caseDeTheme: CGFloat = 150
        public static let imageDeTheme: CGFloat = 40
        /// Hauteur maximale du choix du mot, par-dessus la caméra.
        public static let choixDuMot: CGFloat = 360
        public static let vignette: CGFloat = 52
        public static let bordure: CGFloat = 1
        public static let bordureForte: CGFloat = 2
        /// Largeur maximale du contenu, pour l'iPad.
        public static let largeurDeLecture: CGFloat = 640
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
