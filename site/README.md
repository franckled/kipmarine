# Site officiel KipMarine

Site vitrine statique, responsive et sans dépendance externe.

## Aperçu local
Ouvrir `index.html` dans un navigateur.

## Publication avec GitHub Pages
Le workflow `.github/workflows/kipmarine-pages.yml` publie automatiquement le contenu du dossier `site/` à chaque push sur la branche `main`.

Pour l'activer :
1. Fusionner la branche `site/official-website` dans `main`.
2. Dans GitHub, ouvrir **Settings → Pages**.
3. Choisir **GitHub Actions** comme source de déploiement.
4. Après le premier déploiement, l'adresse du site sera affichée dans **Settings → Pages**.

## À personnaliser avant publication
- Ajouter l'URL publique App Store et Google Play lorsqu'elles sont définitives.
- Ajouter une adresse de contact publique.
- Vérifier et mettre à jour la politique de confidentialité pour qu'elle corresponde exactement aux traitements de données de la version publiée.
- Vérifier les fonctionnalités décrites sur le site avec la version distribuée de l'application.

Le site ne charge aucune police, image ou bibliothèque depuis un service tiers : les illustrations principales sont dessinées en SVG/CSS directement dans la page.
