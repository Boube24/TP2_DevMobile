Rapport : TP2 Dev Mobile
Matricules :
24013
24012
24019
24020

Lien du projet GitHub : https://github.com/Boube24/TP2_DevMobile.git

 

1. Introduction
   Ce rapport présente le travail effectué dans le cadre du deuxième Travaux Pratiques (TP2) de Développement Mobile, portant sur la création d'une application Bloc-Notes avec le framework Flutter. L'objectif principal de ce TP était de concevoir une application complète permettant de gérer des notes personnelles (CRUD : Créer, Lire, Modifier, Supprimer) tout en explorant deux paradigmes fondamentaux de la gestion d'état dans Flutter : l'approche locale avec setState et l'approche globale avec le package Provider.
2. Architecture de l'Application
   L'application est structurée autour de quatre écrans principaux :
   • Page d'Accueil (HomePage) : Affiche la liste des notes sous forme de cartes.
   • Page de Création/Modification (CreateNotePage) : Formulaire de saisie.
   • Page de Détail (DetailNotePage) : Affichage complet et options CRUD.
   • Persistance des données : Gestion via SQLite (DbService).
3. Partie 1 : Gestion d'état avec setState
   L'écran HomePage garde la liste des notes dans son état local. Quand une note est ajoutée, modifiée ou supprimée, on appelle SQLite puis on recharge la liste en utilisant setState() pour rafraîchir l'écran.
4. Partie 2 : Gestion d'état avec Provider
   On sort la logique dans un service NoteService (ChangeNotifier). L'UI ne gère plus la liste elle-même mais s'abonne au service.
5. Comparaison des deux approches
   Caractéristique setState Provider
   Localisation Interne au Widget Service externe
   Maintenance Difficile (grand projet) Facile (séparation)
   Performance Reconstruit tout Rebuild ciblé
   Évolutivité Limitée Élevée (Scalable)
6. Conclusion
   Le TP2 a démontré que bien que setState soit suffisant pour des interactions simples, Provider est indispensable pour des applications professionnelles. La séparation des préoccupations rend le code plus propre et plus facile à faire évoluer.
