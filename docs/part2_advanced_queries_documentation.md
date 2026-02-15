# Documentation - Requêtes SQL Avancées (Part 2)

## Fichier : `database/queries/part2_advanced_queries.sql`

Ce fichier contient des requêtes SQL avancées utilisant des techniques complexes pour analyser les données de ClassicModels.

---

## 1. Analyse des ventes avec Window Functions

### Description
Cette requête utilise les **Window Functions** (fonctions de fenêtre) pour analyser les ventes mensuelles avec des calculs avancés.

### Fonctionnalités
- **Cumul des ventes** : Somme progressive des ventes mois par mois
- **Moyenne mobile 3 mois** : Moyenne glissante sur 3 mois consécutifs
- **Pourcentage du total** : Contribution de chaque mois au total annuel
- **Rang des mois** : Classement des mois par montant de ventes

### Utilisation
Exécutez la requête complète dans MySQL Workbench ou via la ligne de commande.

### Résultat attendu
Un tableau avec les colonnes :
- `mois` : Mois au format YYYY-MM
- `montant` : Montant des ventes du mois
- `cumul_ventes` : Cumul des ventes depuis le début
- `moyenne_mobile_3_mois` : Moyenne mobile sur 3 mois
- `pct_du_total` : Pourcentage du total annuel
- `rang_mois` : Rang du mois (1 = meilleur mois)

---

## 2. Hiérarchie organisationnelle avec CTE Récursif

### Description
Cette requête utilise un **CTE (Common Table Expression) récursif** pour reconstruire la hiérarchie complète des employés dans l'organisation.

### Fonctionnalités
- Identifie les employés au sommet de la hiérarchie (ceux qui n'ont pas de manager)
- Parcourt récursivement tous les niveaux de management
- Calcule le niveau hiérarchique de chaque employé (0 = PDG, 1 = directeur, etc.)

### Utilisation
Exécutez la requête complète. Elle affiche tous les employés avec leur position dans la hiérarchie.

### Résultat attendu
Un tableau avec :
- `employeeNumber` : Numéro de l'employé
- `lastName`, `firstName` : Nom et prénom
- `jobTitle` : Poste
- `reportsTo` : Numéro du manager
- `niveau` : Niveau hiérarchique (0, 1, 2, ...)


---

## 3. Segmentation clients VIP

### Description
Cette requête effectue une **segmentation des clients** en fonction de leur chiffre d'affaires total, avec des jointures multiples pour enrichir les données.

### Fonctionnalités
- Jointure avec les employés (sales rep) et les bureaux
- Calcul du chiffre d'affaires total par client
- Segmentation automatique :
  - **VIP** : CA ≥ 150,000$
  - **Régulier** : CA entre 50,000$ et 149,999$
  - **Petit client** : CA < 50,000$

### Utilisation
Exécutez la requête pour obtenir la liste complète des clients avec leur segment.

### Résultat attendu
Un tableau avec :
- `customerNumber`, `customerName`, `country` : Informations client
- `sales_rep` : Nom du commercial assigné
- `office_city` : Ville du bureau du commercial
- `chiffre_affaires` : CA total du client
- `nb_commandes` : Nombre de commandes
- `segment` : Segment (VIP, Régulier, Petit client)

### Tri
Les résultats sont triés par chiffre d'affaires décroissant pour identifier rapidement les meilleurs clients.

---

## 4. Analyse temporelle avec sous-requêtes corrélées

### Description
Cette requête utilise des **sous-requêtes corrélées** pour analyser le comportement temporel des clients.

### Fonctionnalités
- **Date de première commande** : Quand le client a commandé pour la première fois
- **Date de dernière commande** : Dernière commande du client
- **Type de client** :
  - **Nouveau** : Client depuis moins de 6 mois
  - **Ancien** : Client depuis plus de 6 mois
  - **Jamais commandé** : Client sans commande
- **Statut de rétention** :
  - **Retenu** : Dernière commande il y a moins de 6 mois
  - **Perdu** : Dernière commande il y a plus de 6 mois
  - **Jamais commandé** : Aucune commande

### Utilisation
Exécutez la requête pour analyser la base client et identifier les clients à risque.

### Résultat attendu
Un tableau avec :
- `customerNumber`, `customerName` : Informations client
- `premiere_commande` : Date de la première commande
- `derniere_commande` : Date de la dernière commande
- `type_client` : Nouveau / Ancien / Jamais commandé
- `statut_retention` : Retenu / Perdu / Jamais commandé

### Tri
Les résultats sont triés par date de première commande pour voir l'évolution de la base client.

---

## 5. Rapport PIVOT : Ventes par gamme et trimestre

### Description
Cette requête crée un **tableau croisé dynamique (PIVOT)** pour analyser les ventes par gamme de produits et par trimestre.

### Fonctionnalités
- Agrégation des ventes par gamme de produits
- Répartition trimestrielle (T1, T2, T3, T4)
- Calcul du total annuel par gamme

### Utilisation
Exécutez la requête pour obtenir une vue d'ensemble des performances par gamme et par période.

### Résultat attendu
Un tableau avec :
- `productLine` : Nom de la gamme de produits
- `ventes_T1`, `ventes_T2`, `ventes_T3`, `ventes_T4` : Ventes par trimestre
- `ventes_annuelles` : Total annuel

### Tri
Les résultats sont triés par ventes annuelles décroissantes pour identifier les gammes les plus performantes.

