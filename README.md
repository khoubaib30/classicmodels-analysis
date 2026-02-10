## Projet ClassicModels - Analyse SQL & Python

Ce dépôt contient un projet d'analyse de la base MySQL **ClassicModels** en SQL et Python.

### 1. Pré-requis

- MySQL Server et MySQL Workbench installés
- Python 3.10+ installé

### 2. Installation de la base ClassicModels

1. Téléchargez l'archive depuis le site officiel MySQL Tutorial :  
   `https://www.mysqltutorial.org/getting-started-with-mysql/mysql-sample-database/`
2. Importez le fichier `mysqlsampledatabase.sql` dans MySQL (via MySQL Workbench ou en ligne de commande).
3. Vérifiez que la base `classicmodels` est créée et accessible.

### 3. Installation des dépendances Python

Dans un terminal ouvert à la racine du projet :

```bash
python -m venv .venv
.venv\Scripts\activate  # sous Windows
pip install -r requirements.txt
```

### 4. Structure du projet (à respecter)

- `database/`
  - `schema/` : scripts liés au schéma (import, EER, etc.)
  - `queries/` : requêtes d'analyse, procédures stockées, fonctions, triggers
- `src/`
  - `database/` : code de connexion MySQL, pool de connexions
  - `analysis/` : scripts d'analyses et visualisations
  - `exports/` : scripts d'export (CSV/Excel, etc.)
- `notebooks/` : notebooks Jupyter pour les analyses avancées
- `visualizations/` : graphiques sauvegardés (PNG, HTML)
- `docs/` : documentation complémentaire
- `reports/` : rapports finaux (PDF, slides, etc.)
- `config/` : fichiers de configuration (ne pas versionner les credentials)

### 5. Exécution des scripts

Les instructions détaillées d'exécution de chaque script (SQL et Python) seront documentées au fur et à mesure dans ce fichier et/ou dans `docs/`.

