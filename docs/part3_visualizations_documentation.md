# Documentation - Script de Visualisations Avancées (Part 3)

## Fichier : `src/analysis/part3_visualizations.py`

Ce script Python génère automatiquement des graphiques avancés pour analyser les données de ClassicModels. Les visualisations sont sauvegardées dans le dossier `visualizations/`.

---

## Vue d'ensemble

Le script contient **8 fonctions de visualisation** qui génèrent différents types de graphiques :
- Graphiques temporels (évolution des ventes)
- Cartes géographiques (répartition clients et ventes)
- Graphiques de comparaison (gammes, produits, clients)
- Analyses de stock

---

## Exécution

```bash
# Depuis la racine du projet (avec environnement virtuel activé)
python -m src.analysis.part3_visualizations
```

### Résultat
Tous les graphiques sont automatiquement générés et sauvegardés dans `visualizations/`.

---

## Fonctions de visualisation

### 1. `plot_sales_evolution_monthly()`

**Description** : Graphique linéaire montrant l'évolution des ventes mois par mois.

**Type de graphique** : Ligne avec zone remplie + ligne de tendance

**Fichier généré** : `part3_sales_evolution_monthly.png`

**Informations affichées** :
- Montant des ventes par mois
- Cumul des ventes (ligne de tendance)
- Annotations avec les montants exacts

**Utilisation métier** :
- Identifier les tendances saisonnières
- Détecter les mois exceptionnels (pics ou baisses)
- Analyser l'évolution globale des ventes

---

### 2. `plot_sales_evolution_quarterly()`

**Description** : Graphique en barres montrant les ventes par trimestre.

**Type de graphique** : Barres verticales

**Fichier généré** : `part3_sales_evolution_quarterly.png`

**Informations affichées** :
- Montant des ventes par trimestre (Q1, Q2, Q3, Q4)
- Labels avec les montants exacts sur chaque barre

**Utilisation métier** :
- Comparer les performances trimestrielles
- Identifier les trimestres les plus performants
- Analyser la saisonnalité annuelle

---

### 3. `plot_geographic_customers()`

**Description** : Carte choroplèthe (carte géographique colorée) montrant la répartition des clients par pays.

**Type de graphique** : Carte interactive (Plotly)

**Fichiers générés** :
- `part3_geographic_customers.html` (interactif)
- `part3_geographic_customers.png` (image statique, si possible)

**Informations affichées** :
- Nombre de clients par pays
- Carte colorée selon la densité de clients
- Tooltips au survol avec le nombre exact de clients

**Utilisation métier** :
- Identifier les marchés géographiques principaux
- Visualiser la présence géographique de l'entreprise
- Décider où concentrer les efforts marketing

---

### 4. `plot_geographic_sales()`

**Description** : Carte choroplèthe montrant la répartition des ventes (chiffre d'affaires) par pays.

**Type de graphique** : Carte interactive (Plotly)

**Fichiers générés** :
- `part3_geographic_sales.html` (interactif)
- `part3_geographic_sales.png` (image statique, si possible)

**Informations affichées** :
- Chiffre d'affaires par pays
- Carte colorée selon le montant des ventes
- Tooltips au survol avec le CA exact

**Utilisation métier** :
- Identifier les marchés les plus rentables
- Comparer la performance géographique
- Décider des investissements par région

---

### 5. `plot_sales_by_product_line()`

**Description** : Graphique comparatif montrant les ventes par gamme de produits (CA et quantité).

**Type de graphique** : Deux graphiques en barres horizontales côte à côte

**Fichier généré** : `part3_sales_by_product_line.png`

**Informations affichées** :
- **Graphique gauche** : Chiffre d'affaires par gamme
- **Graphique droit** : Quantité vendue par gamme
- Labels avec les valeurs exactes

**Utilisation métier** :
- Identifier les gammes les plus performantes
- Comparer CA vs quantité (certaines gammes peuvent avoir un CA élevé avec peu de quantité)
- Analyser la stratégie produit

---

### 6. `plot_top10_products()`

**Description** : Graphique en barres horizontales montrant les 10 produits les plus vendus en quantité.

**Type de graphique** : Barres horizontales

**Fichier généré** : `part3_top10_products.png`

**Informations affichées** :
- Top 10 des produits par quantité vendue
- Nom complet du produit
- Quantité exacte sur chaque barre

**Utilisation métier** :
- Identifier les best-sellers
- Analyser les produits phares
- Optimiser le stock des produits populaires

---

### 7. `plot_stock_analysis()`

**Description** : Analyse complète de l'état des stocks avec 3 graphiques.

**Type de graphique** : 3 graphiques côte à côte (camembert, barres groupées, barres horizontales)

**Fichier généré** : `part3_stock_analysis.png`

**Informations affichées** :
- **Graphique 1 (camembert)** : Répartition globale (Normal, Faible, Rupture)
- **Graphique 2 (barres groupées)** : Répartition par gamme de produits
- **Graphique 3 (barres horizontales)** : Top 5 produits avec le stock le plus faible

**Seuils** :
- **Rupture** : Stock = 0
- **Faible** : Stock < 50 unités
- **Normal** : Stock ≥ 50 unités

**Utilisation métier** :
- Identifier les produits en rupture de stock
- Détecter les produits à réapprovisionner
- Analyser l'état des stocks par gamme
- Prévenir les ruptures de stock

---

### 8. `plot_revenue_by_customers()`

**Description** : Analyse des revenus par client avec focus sur le Top 10.

**Type de graphique** : 2 graphiques côte à côte (camembert + barres horizontales)

**Fichier généré** : `part3_revenue_by_customers.png`

**Informations affichées** :
- **Graphique 1 (camembert)** : Répartition du CA (Top 10 vs Autres clients)
- **Graphique 2 (barres horizontales)** : Top 10 clients avec leur CA exact
- Statistiques détaillées (pourcentages, montants)

**Utilisation métier** :
- Identifier les clients les plus précieux
- Analyser la concentration du CA (80/20)
- Cibler les clients VIP pour des actions marketing
- Comprendre la distribution de la valeur client

---
