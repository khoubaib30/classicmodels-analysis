/*
  PARTIE 2 - REQUÊTES SQL AVANCÉES
*/
-- 1) Analyse des ventes avec WINDOW FUNCTIONS, Ventes par mois avec rang, moyenne mobile 3 mois, pourcentage du total.
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.orderDate, '%Y-%m') AS mois,
        SUM(od.quantityOrdered * od.priceEach) AS montant
    FROM orders o
    JOIN orderdetails od ON od.orderNumber = o.orderNumber
    WHERE o.status = 'Shipped'
    GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m')
)
SELECT
    mois,
    montant,
    SUM(montant) OVER (ORDER BY mois) AS cumul_ventes,
    AVG(montant) OVER (
        ORDER BY mois
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moyenne_mobile_3_mois,
    ROUND(montant / SUM(montant) OVER () * 100, 2) AS pct_du_total,
    RANK() OVER (ORDER BY montant DESC) AS rang_mois
FROM monthly_sales
ORDER BY mois;

-- 2) Hiérarchie organisationnelle avec CTE RÉCURSIF (version simplifiée)

WITH RECURSIVE hierarchy AS (
    SELECT
        e.employeeNumber,
        e.lastName,
        e.firstName,
        e.reportsTo,
        e.jobTitle,
        0 AS niveau
    FROM employees e
    WHERE e.reportsTo IS NULL

    UNION ALL

    -- Niveaux suivants
    SELECT
        e.employeeNumber,
        e.lastName,
        e.firstName,
        e.reportsTo,
        e.jobTitle,
        h.niveau + 1 AS niveau
    FROM employees e
    JOIN hierarchy h
      ON e.reportsTo = h.employeeNumber
)
SELECT
    employeeNumber,
    lastName,
    firstName,
    jobTitle,
    reportsTo,
    niveau
FROM hierarchy
ORDER BY
    niveau,
    reportsTo,
    employeeNumber;
    
-- 3) Segmentation clients VIP avec JOINTURES MULTIPLES 
SELECT c.customerNumber, c.customerName, c.country, CONCAT(e.firstName, ' ', e.lastName) AS sales_rep, o2.city AS office_city, SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires,
    COUNT(DISTINCT o.orderNumber) AS nb_commandes,
    CASE
        WHEN SUM(od.quantityOrdered * od.priceEach) >= 150000 THEN 'VIP'
        WHEN SUM(od.quantityOrdered * od.priceEach) BETWEEN 50000 AND 149999 THEN 'Régulier'
        ELSE 'Petit client'
    END AS segment
FROM customers c
LEFT JOIN employees e ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN offices o2 ON o2.officeCode = e.officeCode
JOIN orders o ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON od.orderNumber = o.orderNumber
GROUP BY c.customerNumber, c.customerName, c.country, sales_rep, office_city
ORDER BY chiffre_affaires DESC;
    
-- 4) Analyse temporelle avec SOUS-REQUÊTES CORRÉLÉES
SELECT c.customerNumber, c.customerName,
    (SELECT MIN(o1.orderDate)
     FROM orders o1
     WHERE o1.customerNumber = c.customerNumber) AS premiere_commande,
    (SELECT MAX(o2.orderDate)
     FROM orders o2
     WHERE o2.customerNumber = c.customerNumber) AS derniere_commande,
    CASE
        WHEN (SELECT MIN(o1.orderDate)
              FROM orders o1
              WHERE o1.customerNumber = c.customerNumber) IS NULL
            THEN 'Jamais commandé'
        WHEN TIMESTAMPDIFF(
                 MONTH,
                 (SELECT MIN(o1.orderDate)
                  FROM orders o1
                  WHERE o1.customerNumber = c.customerNumber),
                 (SELECT MAX(o3.orderDate) FROM orders o3)
             ) <= 6
            THEN 'Nouveau'
        ELSE 'Ancien'
    END AS type_client,
    CASE
        WHEN (SELECT MAX(o2.orderDate)
              FROM orders o2
              WHERE o2.customerNumber = c.customerNumber) IS NULL
            THEN 'Jamais commandé'
        WHEN TIMESTAMPDIFF(
                 MONTH,
                 (SELECT MAX(o2.orderDate)
                  FROM orders o2
                  WHERE o2.customerNumber = c.customerNumber),
                 (SELECT MAX(o3.orderDate) FROM orders o3)
             ) <= 6
            THEN 'Retenu'
        ELSE 'Perdu'
    END AS statut_retention
 FROM customers c
 ORDER BY premiere_commande; 


-- 5) Rapport PIVOT : ventes par gamme de produits et par trimestre
SELECT pl.productLine,
SUM(CASE WHEN QUARTER(o.orderDate) = 1 THEN od.quantityOrdered * od.priceEach ELSE 0 END) AS ventes_T1,
SUM(CASE WHEN QUARTER(o.orderDate) = 2 THEN od.quantityOrdered * od.priceEach ELSE 0 END) AS ventes_T2,
SUM(CASE WHEN QUARTER(o.orderDate) = 3 THEN od.quantityOrdered * od.priceEach ELSE 0 END) AS ventes_T3,
SUM(CASE WHEN QUARTER(o.orderDate) = 4 THEN od.quantityOrdered * od.priceEach ELSE 0 END) AS ventes_T4,
SUM(od.quantityOrdered * od.priceEach) AS ventes_annuelles
FROM orderdetails od
JOIN orders o ON o.orderNumber = od.orderNumber
JOIN products p ON p.productCode = od.productCode
JOIN productlines pl ON pl.productLine = p.productLine
GROUP BY
    pl.productLine
ORDER BY
    ventes_annuelles DESC;

