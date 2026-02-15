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

### 3. Configuration du fichier .env

**Qu'est-ce qu'un fichier .env ?**

Un fichier `.env` (environment variables) est un fichier de configuration qui stocke des variables d'environnement sensibles (comme les identifiants de base de données) en dehors du code source. Cela permet de :
- **Sécuriser les credentials** : éviter de les exposer dans le code versionné
- **Faciliter la configuration** : chaque développeur peut avoir ses propres paramètres
- **Respecter les bonnes pratiques** : séparer la configuration du code

**Création du fichier .env :**

1. Créez un fichier nommé `.env` à la racine du projet
2. Copiez le template ci-dessous et remplissez les valeurs selon votre configuration MySQL :

```env
# Configuration de la base de données MySQL
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=votre_mot_de_passe
DB_NAME=classicmodels
```


### 4. Installation des dépendances Python

Dans un terminal ouvert à la racine du projet :

```bash
python -m venv .venv
.venv\Scripts\activate  
pip install -r requirements.txt
```

### 5. Structure du projet 

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

### 6. Exécution des scripts

#### 6.1. Exécution des scripts Python de visualisation

Les scripts Python génèrent automatiquement des graphiques sauvegardés dans le dossier `visualizations/`.

**Scripts disponibles :**
- `src/analysis/part1_visualizations.py` : Visualisations de base (comptages, revenus par gamme, top employés, etc.)
- `src/analysis/part3_visualizations.py` : Visualisations avancées (évolution des ventes, analyses temporelles, etc.)

**Méthode 1 : Exécution directe depuis la racine du projet**

Assurez-vous que votre environnement virtuel est activé, puis :

```bash
python -m src.analysis.part1_visualizations
python -m src.analysis.part3_visualizations

```
**Résultat :** Les graphiques sont automatiquement sauvegardés dans le dossier `visualizations/` (créé automatiquement si nécessaire).

#### 6.2. Exécution des requêtes SQL

Les fichiers SQL contiennent des requêtes d'analyse et peuvent être exécutés de plusieurs façons.

**Fichiers disponibles :**
- `database/queries/part1_eda.sql` : Analyse exploratoire de données (comptages, statistiques de base)
- `database/queries/part2_advanced_queries.sql` : Requêtes avancées (jointures complexes, agrégations)
- `database/queries/part2_stored_procedures_functions_triggers.sql` : Procédures stockées, fonctions et triggers

**Méthode 1 : MySQL Workbench (recommandé pour débutants)**

1. Ouvrez MySQL Workbench
2. Connectez-vous à votre serveur MySQL
3. Sélectionnez la base de données `classicmodels`
4. Ouvrez le fichier SQL (`File > Open SQL Script`)
5. Exécutez le script (`Query > Execute` ou `Ctrl+Shift+Enter`)


**Note :** Les fichiers SQL peuvent contenir plusieurs requêtes séparées par des points-virgules. Vous pouvez les exécuter toutes d'un coup ou une par une selon vos besoins.

#### 6.3. Exécution des notebooks Jupyter

Pour les analyses interactives et avancées, utilisez les notebooks Jupyter  puis ouvrez les notebooks dans le dossier `notebooks/` :
- `part4_correlation_analysis.ipynb` : Analyse de corrélations
- `part4_rfm_analysis.ipynb` : Analyse RFM
- `part4_basket_analysis.ipynb` : Analyse des paniers
- `part4_employee_performance.ipynb` : Analyse de performance des employés
- `part4_temporal_trends_analysis.ipynb` : Analyse des tendances temporelles


