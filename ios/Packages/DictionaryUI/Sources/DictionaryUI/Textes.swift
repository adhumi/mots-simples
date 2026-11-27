import Foundation

/// Tous les textes de l'interface, au même endroit, pour les relire d'une traite.
/// Vouvoiement, phrases courtes, mots de tous les jours.
/// Le catalogue de chaînes est Ressources/Localizable.xcstrings. Français seul en V1.
public enum Textes {
    // Accueil
    public static var nomDeLApp: String { String(localized: "Mots simples", bundle: .module) }
    public static var chercherUnMot: String { String(localized: "Chercher un mot", bundle: .module) }
    public static var ecrivezLeMot: String { String(localized: "Écrivez le mot", bundle: .module) }
    public static var exempleDeRecherche: String { String(localized: "Par exemple : facture", bundle: .module) }
    public static var effacer: String { String(localized: "Effacer", bundle: .module) }
    public static var vosDerniersMots: String { String(localized: "Vos derniers mots", bundle: .module) }
    public static var aucunDernierMot: String { String(localized: "Les mots que vous ouvrez s'affichent ici.", bundle: .module) }
    public static var resultats: String { String(localized: "Résultats", bundle: .module) }
    public static var dictionnaireVide: String { String(localized: "Le dictionnaire est vide pour le moment.", bundle: .module) }

    // Thèmes
    public static var voirLesThemes: String { String(localized: "Voir les thèmes", bundle: .module) }
    public static var lesThemes: String { String(localized: "Les thèmes", bundle: .module) }
    public static var choisissezUnTheme: String { String(localized: "Choisissez un thème.", bundle: .module) }
    public static var aucunMotDansLeTheme: String { String(localized: "Il n'y a pas encore de mot dans ce thème.", bundle: .module) }
    public static func nombreDeMots(_ nombre: Int) -> String {
        nombre == 1 ? String(localized: "1 mot", bundle: .module) : String(localized: "\(nombre) mots", bundle: .module)
    }

    // Mot absent
    public static var motAbsent: String { String(localized: "Ce mot n'est pas encore dans le dictionnaire.", bundle: .module) }
    public static var motsProches: String { String(localized: "Mots proches", bundle: .module) }

    // Écoute
    public static var ecouter: String { String(localized: "Écouter", bundle: .module) }
    public static var arreter: String { String(localized: "Arrêter", bundle: .module) }
    public static var toutEcouter: String { String(localized: "Tout écouter", bundle: .module) }
    public static func ecouterLeMot(_ mot: String) -> String { String(localized: "Écouter le mot \(mot)", bundle: .module) }
    public static func ecouterLeBloc(_ titre: String) -> String { String(localized: "Écouter : \(titre)", bundle: .module) }
    public static var vitesseDeLaVoix: String { String(localized: "Vitesse de la voix", bundle: .module) }
    public static var vitesseNormale: String { String(localized: "Normale", bundle: .module) }
    public static var vitesseLente: String { String(localized: "Lente", bundle: .module) }

    // Fiche
    public static var definition: String { String(localized: "Définition", bundle: .module) }
    public static var exemple: String { String(localized: "Exemple", bundle: .module) }
    public static var autreSens: String { String(localized: "Autre sens", bundle: .module) }
    public static var autresSens: String { String(localized: "Autres sens", bundle: .module) }
    public static var aNePasConfondre: String { String(localized: "À ne pas confondre", bundle: .module) }
    public static func aNePasConfondreAvec(_ mot: String) -> String { String(localized: "À ne pas confondre avec : \(mot).", bundle: .module) }
    public static var motsLies: String { String(localized: "Mots liés", bundle: .module) }
    public static func theme(_ nom: String) -> String { String(localized: "Thème : \(nom)", bundle: .module) }
    public static var ficheIntrouvable: String { String(localized: "Cette fiche n'existe plus.", bundle: .module) }

    // Statut
    public static var brouillonNonRelu: String { String(localized: "Brouillon non relu", bundle: .module) }
    public static var brouillonExplication: String { String(localized: "Ce texte n'est pas encore vérifié.", bundle: .module) }
    public static var pasEncoreValide: String { String(localized: "Pas encore validé", bundle: .module) }
    public static var pasEncoreValideExplication: String { String(localized: "Ce texte est vérifié. Il n'est pas encore testé avec des lecteurs.", bundle: .module) }
    public static var valide: String { String(localized: "Validé", bundle: .module) }
    public static func valideLe(_ date: String) -> String { String(localized: "Validé le \(date)", bundle: .module) }
}
