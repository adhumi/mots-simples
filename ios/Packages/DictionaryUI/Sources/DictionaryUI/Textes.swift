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

    // Chercher en parlant
    public static var direLeMot: String { String(localized: "Dire le mot", bundle: .module) }
    public static var jEcoute: String { String(localized: "Je vous écoute. Dites le mot.", bundle: .module) }
    public static var microRefuse: String { String(localized: "Le micro est coupé pour cette app. Pour dire un mot, ouvrez les réglages et activez le micro et la reconnaissance vocale.", bundle: .module) }
    public static var dicteeIndisponible: String { String(localized: "Votre téléphone ne peut pas écouter pour le moment. Vous pouvez écrire le mot.", bundle: .module) }
    public static var ouvrirLesReglages: String { String(localized: "Ouvrir les réglages", bundle: .module) }

    // Photographier un mot
    public static var prendreEnPhoto: String { String(localized: "Prendre en photo", bundle: .module) }
    public static var touchezUnMot: String { String(localized: "Montrez le texte, puis touchez un mot.", bundle: .module) }
    public static var quelMot: String { String(localized: "Quel mot voulez-vous ?", bundle: .module) }
    public static var choisirUnAutreTexte: String { String(localized: "Choisir un autre texte", bundle: .module) }
    public static var fermer: String { String(localized: "Fermer", bundle: .module) }
    public static var cameraRefusee: String { String(localized: "La caméra est coupée pour cette app. Pour prendre un mot en photo, ouvrez les réglages et activez la caméra.", bundle: .module) }

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

    // Partager
    public static var partager: String { String(localized: "Partager", bundle: .module) }

    // Aide et à propos
    public static var aideEtAPropos: String { String(localized: "Aide et à propos", bundle: .module) }
    public static var aideCommentTitre: String { String(localized: "Comment ça marche ?", bundle: .module) }
    public static var aideComment1: String { String(localized: "Écrivez un mot que vous ne comprenez pas.", bundle: .module) }
    public static var aideComment2: String { String(localized: "Vous pouvez aussi dire le mot, ou le prendre en photo.", bundle: .module) }
    public static var aideComment3: String { String(localized: "Touchez le mot pour lire son explication.", bundle: .module) }
    public static var aideComment4: String { String(localized: "Touchez « Tout écouter » pour entendre l'explication.", bundle: .module) }
    public static var ecouterUnEssai: String { String(localized: "Écouter un essai de la voix", bundle: .module) }
    public static var essaiDeVoix: String { String(localized: "Voici la voix à cette vitesse.", bundle: .module) }
    public static var aideAttentionTitre: String { String(localized: "Attention", bundle: .module) }
    public static var aideAttention1: String { String(localized: "Le dictionnaire explique des mots.", bundle: .module) }
    public static var aideAttention2: String { String(localized: "Il ne remplace pas un médecin. Il ne remplace pas un conseiller.", bundle: .module) }
    public static var aideViePriveeTitre: String { String(localized: "Votre vie privée", bundle: .module) }
    public static var aideViePrivee1: String { String(localized: "L'app ne garde aucune information sur vous.", bundle: .module) }
    public static var aideViePrivee2: String { String(localized: "Vos derniers mots restent sur votre téléphone.", bundle: .module) }
    public static var aideViePrivee3: String { String(localized: "La caméra et le micro servent seulement à trouver un mot. Rien n'est enregistré.", bundle: .module) }
    public static var aideViePrivee4: String { String(localized: "Si vous demandez un mot, seul le mot est envoyé.", bundle: .module) }
    public static var aideTextesTitre: String { String(localized: "D'où viennent les explications ?", bundle: .module) }
    public static var aideTextes1: String { String(localized: "Un ordinateur écrit un premier texte. C'est un brouillon.", bundle: .module) }
    public static var aideTextes2: String { String(localized: "Une personne vérifie le texte avec une source officielle.", bundle: .module) }
    public static var aideTextes3: String { String(localized: "Des personnes concernées lisent le texte. Si elles le comprennent, il est validé.", bundle: .module) }
    public static var aideQuiTitre: String { String(localized: "Qui a fait l'app ?", bundle: .module) }
    public static var aideQui1: String { String(localized: "Adrien Humilière fait ce dictionnaire.", bundle: .module) }
    public static var aideQui2: String { String(localized: "L'app est gratuite. Il n'y a pas de publicité et pas de compte.", bundle: .module) }
    public static var aideCreditsTitre: String { String(localized: "Merci", bundle: .module) }
    public static var creditPictogrammes: String { String(localized: "Pictogrammes : Sergio Palao, ARASAAC, Gouvernement d'Aragon. Licence Creative Commons BY-NC-SA.", bundle: .module) }
    public static var creditPolice: String { String(localized: "Police Lexend. Licence SIL Open Font License.", bundle: .module) }
    public static var creditLicences: String { String(localized: "Textes sous licence Creative Commons BY-NC-SA 4.0. Code sous licence MIT.", bundle: .module) }
    public static func versions(app: String, contenu: String) -> String { String(localized: "Version de l'app : \(app). Contenu du \(contenu).", bundle: .module) }

    // Siri et Raccourcis
    public static var motAbsentPourSiri: String { String(localized: "Ce mot n'est pas encore dans le dictionnaire.", bundle: .module) }

    // Demander un mot
    public static var demanderCeMot: String { String(localized: "Demander ce mot", bundle: .module) }
    public static func seulLeMotPart(_ mot: String) -> String { String(localized: "Seul le mot « \(mot) » est envoyé. Nous ne savons pas qui vous êtes.", bundle: .module) }
    public static var rienDePersonnel: String { String(localized: "N'envoyez pas votre nom. N'envoyez rien de personnel.", bundle: .module) }
    public static var demandeEnvoyee: String { String(localized: "Merci. Le mot est envoyé.", bundle: .module) }
    public static var demandeEnAttente: String { String(localized: "Il n'y a pas d'internet. Le mot partira plus tard, tout seul.", bundle: .module) }
    public static var demandeEnCours: String { String(localized: "Le mot part…", bundle: .module) }

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
