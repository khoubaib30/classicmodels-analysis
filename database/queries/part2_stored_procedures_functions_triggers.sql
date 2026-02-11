/*
  PARTIE 2 - PROCÉDURES STOCKÉES, FONCTIONS ET TRIGGERS
*/
-- TABLE D'AUDIT POUR LE TRIGGER (nécessaire pour stocker l'historique)
CREATE TABLE IF NOT EXISTS orders_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    orderNumber INT NOT NULL,
    action_type VARCHAR(10) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    old_status VARCHAR(15),
    new_status VARCHAR(15),
    changed_by VARCHAR(100),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comments TEXT
);

-- AJOUT COLONNE STATUS DANS CUSTOMERS (pour le trigger de statut)
ALTER TABLE customers 
ADD COLUMN customerStatus VARCHAR(20) DEFAULT 'Inactif';

-- 1) PROCÉDURE STOCKÉE : CALCUL COMMISSION EMPLOYÉ
DELIMITER $$

DROP PROCEDURE IF EXISTS CalculateEmployeeCommission$$

CREATE PROCEDURE CalculateEmployeeCommission(
    IN p_employeeNumber INT,
    IN p_startDate DATE,
    IN p_endDate DATE,
    OUT p_totalSales DECIMAL(10,2),
    OUT p_commission DECIMAL(10,2)
)
BEGIN
    DECLARE commission_rate DECIMAL(5,2) DEFAULT 0.05; -- 5% de commission par défaut
    
    -- Calculer le total des ventes pour l'employé dans la période
    SELECT COALESCE(SUM(od.quantityOrdered * od.priceEach), 0)
    INTO p_totalSales
    FROM employees e
    JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
    JOIN orders o ON o.customerNumber = c.customerNumber
    JOIN orderdetails od ON od.orderNumber = o.orderNumber
    WHERE e.employeeNumber = p_employeeNumber
      AND o.orderDate BETWEEN p_startDate AND p_endDate
      AND o.status = 'Shipped';
    
    -- Calculer la commission (5% du total des ventes)
    SET p_commission = p_totalSales * commission_rate;
    
    -- Afficher les résultats
    SELECT 
        e.employeeNumber,
        CONCAT(e.firstName, ' ', e.lastName) AS employee_name,
        e.jobTitle,
        p_startDate AS start_date,
        p_endDate AS end_date,
        p_totalSales AS total_sales,
        commission_rate AS commission_rate,
        p_commission AS commission_amount
    FROM employees e
    WHERE e.employeeNumber = p_employeeNumber;
END$$

DELIMITER ;

-- 2) PROCÉDURE STOCKÉE : GESTION STOCKS
DELIMITER $$

DROP PROCEDURE IF EXISTS ManageStock$$

CREATE PROCEDURE ManageStock(
    IN p_productCode VARCHAR(15),
    IN p_quantityToOrder INT,
    OUT p_result VARCHAR(100),
    OUT p_availableStock INT,
    OUT p_stockStatus VARCHAR(20)
)
BEGIN
    DECLARE current_stock INT;
    DECLARE reorder_level INT DEFAULT 50; -- Seuil de réapprovisionnement
    DECLARE min_stock INT DEFAULT 20; -- Stock minimum
    
    -- Récupérer le stock actuel
    SELECT quantityInStock INTO current_stock
    FROM products
    WHERE productCode = p_productCode;
    
    -- Vérifier si le produit existe
    IF current_stock IS NULL THEN
        SET p_result = 'ERREUR: Produit introuvable';
        SET p_availableStock = 0;
        SET p_stockStatus = 'INEXISTANT';
    ELSE
        SET p_availableStock = current_stock;
        
        -- Vérifier si on peut satisfaire la commande
        IF current_stock >= p_quantityToOrder THEN
            -- Mettre à jour le stock
            UPDATE products
            SET quantityInStock = quantityInStock - p_quantityToOrder
            WHERE productCode = p_productCode;
            
            SET p_availableStock = current_stock - p_quantityToOrder;
            SET p_result = CONCAT('Stock mis à jour: ', p_quantityToOrder, ' unités déduites');
            
            -- Déterminer le statut du stock après déduction
            IF (current_stock - p_quantityToOrder) <= min_stock THEN
                SET p_stockStatus = 'CRITIQUE';
            ELSEIF (current_stock - p_quantityToOrder) <= reorder_level THEN
                SET p_stockStatus = 'FAIBLE';
            ELSE
                SET p_stockStatus = 'NORMAL';
            END IF;
        ELSE
            SET p_result = CONCAT('ERREUR: Stock insuffisant. Disponible: ', current_stock, ', Demandé: ', p_quantityToOrder);
            SET p_stockStatus = 'INSUFFISANT';
        END IF;
    END IF;
    
    -- Afficher les résultats
    SELECT 
        p.productCode,
        p.productName,
        p_result AS result_message,
        p_availableStock AS available_stock,
        p_stockStatus AS stock_status,
        reorder_level AS reorder_level,
        min_stock AS min_stock
    FROM products p
    WHERE p.productCode = p_productCode;
END$$

DELIMITER ;

-- ============================================
-- 3) FONCTION : CUSTOMER LIFETIME VALUE (CLV)
-- ============================================
DELIMITER $$

DROP FUNCTION IF EXISTS CustomerLifetimeValue$$

CREATE FUNCTION CustomerLifetimeValue(p_customerNumber INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE clv DECIMAL(10,2);
    
    -- Calculer la valeur totale des commandes du client
    SELECT COALESCE(SUM(od.quantityOrdered * od.priceEach), 0)
    INTO clv
    FROM customers c
    JOIN orders o ON o.customerNumber = c.customerNumber
    JOIN orderdetails od ON od.orderNumber = o.orderNumber
    WHERE c.customerNumber = p_customerNumber
      AND o.status = 'Shipped';
    
    RETURN clv;
END$$

DELIMITER ;

-- ============================================
-- 4) TRIGGER : AUDIT ORDERS
-- ============================================
DELIMITER $$

DROP TRIGGER IF EXISTS orders_audit_insert$$
DROP TRIGGER IF EXISTS orders_audit_update$$
DROP TRIGGER IF EXISTS orders_audit_delete$$

-- Trigger pour INSERT
CREATE TRIGGER orders_audit_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_audit (
        orderNumber,
        action_type,
        new_status,
        changed_by,
        comments
    ) VALUES (
        NEW.orderNumber,
        'INSERT',
        NEW.status,
        USER(),
        NEW.comments
    );
END$$

-- Trigger pour UPDATE
CREATE TRIGGER orders_audit_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status OR OLD.comments != NEW.comments THEN
        INSERT INTO orders_audit (
            orderNumber,
            action_type,
            old_status,
            new_status,
            changed_by,
            comments
        ) VALUES (
            NEW.orderNumber,
            'UPDATE',
            OLD.status,
            NEW.status,
            USER(),
            NEW.comments
        );
    END IF;
END$$

-- Trigger pour DELETE
CREATE TRIGGER orders_audit_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_audit (
        orderNumber,
        action_type,
        old_status,
        changed_by,
        comments
    ) VALUES (
        OLD.orderNumber,
        'DELETE',
        OLD.status,
        USER(),
        OLD.comments
    );
END$$

DELIMITER ;

-- ============================================
-- 5) TRIGGER : VALIDATION STOCK
-- ============================================
DELIMITER $$

DROP TRIGGER IF EXISTS validate_stock_before_order$$

CREATE TRIGGER validate_stock_before_order
BEFORE INSERT ON orderdetails
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    DECLARE error_message VARCHAR(255);
    
    -- Récupérer le stock disponible
    SELECT quantityInStock INTO available_stock
    FROM products
    WHERE productCode = NEW.productCode;
    
    -- Vérifier si le stock est suffisant
    IF available_stock < NEW.quantityOrdered THEN
        SET error_message = CONCAT(
            'Stock insuffisant pour le produit ', 
            NEW.productCode, 
            '. Stock disponible: ', 
            available_stock, 
            ', Quantité demandée: ', 
            NEW.quantityOrdered
        );
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = error_message;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- 6) TRIGGER : MISE À JOUR STATUT CLIENT
-- ============================================
DELIMITER $$

DROP TRIGGER IF EXISTS update_customer_status_after_order$$

CREATE TRIGGER update_customer_status_after_order
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE total_orders INT;
    DECLARE total_spent DECIMAL(10,2);
    DECLARE customer_status VARCHAR(20);
    
    -- Compter le nombre total de commandes du client
    SELECT COUNT(*) INTO total_orders
    FROM orders
    WHERE customerNumber = NEW.customerNumber
      AND status = 'Shipped';
    
    -- Calculer le montant total dépensé
    SELECT COALESCE(SUM(od.quantityOrdered * od.priceEach), 0) INTO total_spent
    FROM orders o
    JOIN orderdetails od ON od.orderNumber = o.orderNumber
    WHERE o.customerNumber = NEW.customerNumber
      AND o.status = 'Shipped';
    
    -- Déterminer le statut basé sur le nombre de commandes et le montant
    IF total_spent >= 150000 AND total_orders >= 10 THEN
        SET customer_status = 'VIP';
    ELSEIF total_spent >= 50000 AND total_orders >= 5 THEN
        SET customer_status = 'Régulier';
    ELSEIF total_orders >= 1 THEN
        SET customer_status = 'Actif';
    ELSE
        SET customer_status = 'Inactif';
    END IF;
    
    -- Mettre à jour directement la colonne customerStatus dans la table customers
    UPDATE customers
    SET customerStatus = customer_status
    WHERE customerNumber = NEW.customerNumber;
END$$

DELIMITER ;

-- ============================================
-- EXEMPLES D'UTILISATION
-- ============================================

-- Exemple 1: Calculer la commission d'un employé
-- CALL CalculateEmployeeCommission(1165, '2003-01-01', '2003-12-31', @totalSales, @commission);

-- Exemple 2: Gérer le stock d'un produit
-- CALL ManageStock('S10_1678', 10, @result, @availableStock, @stockStatus);

-- Exemple 3: Calculer la valeur lifetime d'un client
-- SELECT CustomerLifetimeValue(141) AS customer_lifetime_value;

-- Exemple 4: Voir l'audit des commandes
-- SELECT * FROM orders_audit ORDER BY change_date DESC LIMIT 10;

-- Exemple 5: Voir le statut des clients
-- SELECT customerNumber, customerName, customerStatus FROM customers ORDER BY customerStatus;
