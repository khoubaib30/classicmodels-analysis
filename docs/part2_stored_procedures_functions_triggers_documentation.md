# Documentation - Procédures Stockées, Fonctions et Triggers (Part 2)

## Fichier : `database/queries/part2_stored_procedures_functions_triggers.sql`

Ce fichier contient des **procédures stockées**, **fonctions** et **triggers** pour automatiser des opérations métier dans la base de données ClassicModels.

---

## Important : Préparation de la base

Avant d'exécuter ce fichier, il crée automatiquement :
- Une table `orders_audit` pour l'historique des modifications de commandes
- Une colonne `customerStatus` dans la table `customers` pour le statut des clients

Ces modifications sont nécessaires pour le bon fonctionnement des triggers.


## 1. Procédure Stockée : Calcul Commission Employé

### Nom
`CalculateEmployeeCommission`

### Description
Calcule la commission d'un employé basée sur le total des ventes qu'il a générées pour ses clients sur une période donnée.

### Paramètres
- **IN `p_employeeNumber`** : Numéro de l'employé
- **IN `p_startDate`** : Date de début de la période
- **IN `p_endDate`** : Date de fin de la période
- **OUT `p_totalSales`** : Total des ventes (retourné)
- **OUT `p_commission`** : Montant de la commission (retourné)

### Taux de commission
5% du total des ventes (configurable dans la procédure)

### Utilisation
```sql
CALL CalculateEmployeeCommission(1165, '2003-01-01', '2003-12-31', @totalSales, @commission);
SELECT @totalSales AS total_ventes, @commission AS commission;
```

### Résultat
Affiche :
- Informations de l'employé
- Période analysée
- Total des ventes
- Taux de commission
- Montant de la commission

### Cas d'usage
- Calcul des commissions mensuelles/annuelles
- Reporting de performance des commerciaux
- Calcul des primes


## 2. Procédure Stockée : Gestion des Stocks

### Nom
`ManageStock`

### Description
Gère le stock d'un produit : vérifie la disponibilité, déduit la quantité commandée, et détermine le statut du stock après déduction.

### Paramètres
- **IN `p_productCode`** : Code du produit
- **IN `p_quantityToOrder`** : Quantité à commander
- **OUT `p_result`** : Message de résultat (retourné)
- **OUT `p_availableStock`** : Stock disponible après déduction (retourné)
- **OUT `p_stockStatus`** : Statut du stock (retourné)

### Seuils de stock
- **Stock minimum** : 20 unités
- **Seuil de réapprovisionnement** : 50 unités

### Statuts possibles
- **NORMAL** : Stock > 50 unités
- **FAIBLE** : Stock entre 20 et 50 unités
- **CRITIQUE** : Stock ≤ 20 unités
- **INSUFFISANT** : Stock insuffisant pour la commande
- **INEXISTANT** : Produit introuvable

### Utilisation
```sql
CALL ManageStock('S10_1678', 10, @result, @availableStock, @stockStatus);
SELECT @result AS message, @availableStock AS stock_disponible, @stockStatus AS statut;
```

### Résultat
Affiche :
- Code et nom du produit
- Message de résultat (succès ou erreur)
- Stock disponible après déduction
- Statut du stock
- Seuils de réapprovisionnement

### Cas d'usage
- Vérification de stock avant commande
- Gestion automatique des stocks
- Alertes de réapprovisionnement


## 3. Fonction : Customer Lifetime Value (CLV)

### Nom
`CustomerLifetimeValue`

### Description
Calcule la valeur totale qu'un client a générée depuis sa première commande (Customer Lifetime Value).

### Paramètres
- **IN `p_customerNumber`** : Numéro du client

### Retour
- **DECIMAL(10,2)** : Valeur totale des commandes du client (en dollars)

### Utilisation
```sql
SELECT CustomerLifetimeValue(141) AS customer_lifetime_value;
```

### Résultat
Retourne un nombre décimal représentant le CA total généré par le client.

### Cas d'usage
- Identification des clients les plus précieux
- Segmentation client basée sur la valeur
- Calcul de la valeur client pour le marketing


---

## 4. Triggers : Audit des Commandes

### Description
Trois triggers qui enregistrent automatiquement toutes les modifications (INSERT, UPDATE, DELETE) sur la table `orders` dans la table `orders_audit`.

### Triggers créés
1. **`orders_audit_insert`** : Déclenché après chaque INSERT
2. **`orders_audit_update`** : Déclenché après chaque UPDATE (seulement si le statut ou les commentaires changent)
3. **`orders_audit_delete`** : Déclenché après chaque DELETE

### Informations enregistrées
- `orderNumber` : Numéro de la commande
- `action_type` : Type d'action (INSERT, UPDATE, DELETE)
- `old_status` : Ancien statut (pour UPDATE/DELETE)
- `new_status` : Nouveau statut (pour INSERT/UPDATE)
- `changed_by` : Utilisateur qui a effectué la modification
- `change_date` : Date et heure de la modification
- `comments` : Commentaires de la commande

### Utilisation
Les triggers fonctionnent automatiquement. Pour consulter l'audit :

```sql
SELECT * FROM orders_audit ORDER BY change_date DESC LIMIT 10;
```

---

## 5. Trigger : Validation du Stock avant Commande

### Nom
`validate_stock_before_order`

### Description
Valide automatiquement que le stock est suffisant avant d'ajouter une ligne de commande (`orderdetails`).

### Fonctionnement
- Se déclenche **AVANT** chaque INSERT dans `orderdetails`
- Vérifie si `quantityInStock >= quantityOrdered`
- Si stock insuffisant : **bloque l'insertion** et affiche une erreur

### Message d'erreur
```
Stock insuffisant pour le produit [code]. Stock disponible: [X], Quantité demandée: [Y]
```

### Utilisation
Le trigger fonctionne automatiquement. Si vous essayez d'ajouter une ligne de commande avec une quantité supérieure au stock disponible, l'opération sera rejetée.

### Exemple d'erreur
```sql
-- Si le produit S10_1678 a seulement 5 unités en stock
INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach)
VALUES (10100, 'S10_1678', 10, 50.00);
--  ERREUR : Stock insuffisant pour le produit S10_1678. Stock disponible: 5, Quantité demandée: 10
```

### Cas d'usage
- Prévention des commandes impossibles à honorer
- Protection de l'intégrité des données
- Validation automatique des stocks

---

## 6. Trigger : Mise à Jour Statut Client

### Nom
`update_customer_status_after_order`

### Description
Met à jour automatiquement le statut du client dans la colonne `customerStatus` après chaque nouvelle commande livrée.

### Fonctionnement
- Se déclenche **APRÈS** chaque INSERT dans `orders`
- Calcule le nombre total de commandes livrées
- Calcule le montant total dépensé
- Détermine le statut selon les critères :
  - **VIP** : CA ≥ 150,000$ ET ≥ 10 commandes
  - **Régulier** : CA ≥ 50,000$ ET ≥ 5 commandes
  - **Actif** : ≥ 1 commande
  - **Inactif** : Aucune commande

### Utilisation
Le trigger fonctionne automatiquement. Pour voir les statuts des clients :

```sql
SELECT customerNumber, customerName, customerStatus 
FROM customers 
ORDER BY customerStatus;
```

### Cas d'usage
- Segmentation automatique des clients
- Identification des clients VIP en temps réel
- Mise à jour automatique du statut client


---

