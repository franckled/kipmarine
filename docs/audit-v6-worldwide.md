# KipMarine V6 — audit initial et feuille de route mondiale

Date de l'audit : 2026-10-19
Branche de travail : `work/v6-global-navigation-audit`
Base de travail : `repair/ios-xcode-project`

## Constat initial

- Application Flutter structurée autour de fournisseurs d'état, avec des écrans distincts pour navigation, carte, mouillage, journal, boussole et marées.
- La version déclarée dans `pubspec.yaml` est `1.0.0+4`. À comparer avec la version effectivement distribuée avant toute livraison.
- La carte utilise `flutter_map` et définit une position de repli en Corse lorsque le GPS n'a pas encore fourni de position. Cette position de repli ne doit jamais être présentée comme la position réelle du bateau.
- L'écran des marées ne calcule pas actuellement de prédictions : il propose une liste courte de ports français et ouvre le site du SHOM. Il faut remplacer la liste fixe par une recherche mondiale et choisir une source dont les droits autorisent l'usage envisagé.
- La rose des vents a déjà deux modes. En mode Cras, elle garde le Nord en haut et affiche une ligne fondée sur le COG GPS. En mode boussole, la rose tourne à partir du capteur magnétique du téléphone. La validation doit vérifier les conventions d'angle, le comportement en mouvement et l'absence de données capteur.
- Le thème utilise actuellement des couleurs statiques partagées et l'application n'expose pas encore de sélection complète clair/sombre/automatique dans `MaterialApp`.

## Correction effectuée dans cette branche

- Correction de l'affectation des paramètres iOS/macOS dans `LocationService.getNavigationStream`. Une déclaration locale `final settings` masquait la variable externe et empêchait de configurer correctement le paramètre utilisé par le flux GPS. La variable externe est désormais affectée.

## Feuille de route proposée

### P0 — fiabilité et sécurité
1. Exécuter `flutter analyze`, `flutter test` et un build iOS sur l'environnement Flutter réel.
2. Vérifier le flux GPS iOS et Android, les permissions, la précision, la fraîcheur des positions et les erreurs de disponibilité.
3. Vérifier l'alarme de mouillage en arrière-plan et les cas de perte de GPS.
4. S'assurer que les positions de démonstration ou de repli sont explicitement distinguées des données GPS réelles.

### P1 — base mondiale
1. Définir un modèle commun de données géographiques et des interfaces de fournisseurs.
2. Ajouter la recherche de lieux et la sélection de coordonnées, sans liste de ports codée en dur.
3. Comparer les sources météo marines mondiales : couverture réelle, variables disponibles, limites géographiques, quotas, coût, attribution et droit d'usage commercial.
4. Évaluer séparément les modèles de marée mondiaux et leur précision près des côtes. Ne pas présenter une sortie globale comme une prédiction portuaire validée sans vérification.
5. Documenter les limites de couverture et les données indisponibles, sans inventer de valeurs.

### P2 — expérience utilisateur
1. Implémenter les thèmes clair, sombre et système, avec choix manuel ou automatique.
2. Appliquer la palette marine turquoise/corail de façon cohérente à tous les écrans.
3. Ajouter une page « À propos » affichant le créateur, l'année de création et la version issue des métadonnées de build.
4. Améliorer l'état de chargement GPS et rendre explicite la précision/ancienneté du dernier relevé.

## Critères de validation avant fusion

- Les tests automatisés et l'analyse statique passent dans un environnement Flutter approprié.
- Les données GPS réelles sont distinguées des valeurs de repli.
- Les sources externes et leurs licences sont documentées.
- Aucun horaire ou niveau de marée fictif n'est affiché comme une donnée réelle.
- Les tests sur appareil sont effectués pour GPS, capteurs, mouillage et comportement en arrière-plan.
- La fusion et la publication restent soumises à validation humaine.

## Limites de cet audit

Cet audit est fondé sur les fichiers consultés dans GitHub. Il ne constitue pas une validation sur iPhone ou en mer. Les tests et builds ne sont pas déclarés réussis tant qu'ils n'ont pas été exécutés et observés.
