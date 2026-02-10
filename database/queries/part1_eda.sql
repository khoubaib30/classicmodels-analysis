/*
  PARTIE 1 - ANALYSE EXPLORATOIRE DE LA BASE ClassicModels
*/

-- 1) Combien de clients, employés, bureaux, commandes, produits, et gammes de produits ?

-- Nombre de clients
SELECT COUNT(*) AS nb_clients
FROM customers;

-- Nombre d'employés
SELECT COUNT(*) AS nb_employes
FROM employees;

-- Nombre de bureaux
SELECT COUNT(*) AS nb_bureaux
FROM offices;

-- Nombre de commandes
SELECT COUNT(*) AS nb_commandes
FROM orders;

-- Nombre de produits
SELECT COUNT(*) AS nb_produits
FROM products;

-- Nombre de gammes de produits
SELECT COUNT(*) AS nb_gammes_produits
FROM productlines;


-- 2) Répartition géographique des clients
SELECT country, COUNT(*) AS nb_clients
FROM customers
GROUP BY country
ORDER BY nb_clients DESC;


-- 3) commandes par statut (shipped, cancelled, etc.) ?
SELECT status, COUNT(*) AS nb_commandes
FROM orders
GROUP BY status
ORDER BY nb_commandes DESC;


-- 4) montant total des ventes et le panier moyen 
SELECT
    SUM(order_total) AS montant_total_ventes,
    AVG(order_total) AS panier_moyen
FROM (
    SELECT
        orderNumber,
        SUM(quantityOrdered * priceEach) AS order_total
    FROM orderdetails
    GROUP BY orderNumber
) AS commandes;


-- 5) Les 10 produits les plus vendus (en quantité)
SELECT p.productCode, p.productName, SUM(od.quantityOrdered) AS total_qty
FROM orderdetails AS od
JOIN products AS p ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName
ORDER BY total_qty DESC
LIMIT 10;


-- 6) 5 meilleurs clients (par chiffre d'affaires) 
SELECT c.customerNumber, c.customerName, SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires
FROM customers c
JOIN orders o ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON od.orderNumber = o.orderNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY chiffre_affaires DESC
LIMIT 5;


-- 7) employé avec le plus de ventes ?
SELECT e.employeeNumber, e.lastName, e.firstName, e.jobTitle, SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires
FROM employees e
JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON od.orderNumber = o.orderNumber
GROUP BY e.employeeNumber, e.lastName, e.firstName, e.jobTitle
ORDER BY chiffre_affaires DESC
LIMIT 1;

-- 8) la gamme de produits la plus rentable ?
SELECT pl.productLine, SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires
FROM orderdetails od
JOIN products p ON p.productCode = od.productCode
JOIN productlines pl ON pl.productLine = p.productLine
GROUP BY pl.productLine
ORDER BY chiffre_affaires DESC
LIMIT 1;

