-- ------------------------------------------------------
-- NOTE: DO NOT REMOVE OR ALTER ANY LINE FROM THIS SCRIPT
-- ------------------------------------------------------

select 'Query 00' as '';
-- Show execution context
select current_date(), current_time(), user(), database();
-- Conform to standard group by constructs
set session sql_mode = 'ONLY_FULL_GROUP_BY';

-- Write the SQL queries that return the information below:
-- Ecrire les requêtes SQL retournant les informations ci-dessous:

select 'Query 01' as '';
-- The countries of residence the supplier had to ship products to in 2014
-- Les pays de résidence où le fournisseur a dû envoyer des produits en 2014
SELECT DISTINCT c.residence
FROM customers c
JOIN orders o ON c.cid = o.cid
WHERE o.odate >= '2014-01-01' AND c.residence IS NOT NULL;


select 'Query 02' as '';
-- For each known country of origin, its name, the number of products from that country, their lowest price, their highest price
-- Pour chaque pays d'orgine connu, son nom, le nombre de produits de ce pays, leur plus bas prix, leur plus haut prix
SELECT
    origin AS "Country origin",
    COUNT(*) AS "Number of product",
    MIN(price) AS "Lowest price",
    MAX(price) AS "Highest price"
FROM products
GROUP BY origin;


select 'Query 03' as '';
-- For each customer and each product, the customer's name, the product's name, the total amount (total price) ordered by the customer for that product,
-- sorted by customer name (alphabetical order), then by total amount ordered (highest value first), then by product id (ascending order)
-- Par client et par produit, le nom du client, le nom du produit, le montant total (prix total) de ce produit commandé par le client, 
-- trié par nom de client (ordre alphabétique), puis par montant total commandé (plus grance valeur d'abord), puis par id de produit (croissant)
SELECT
    C.cname AS "Customer name",
    P.pid AS "ID Product",
    SUM(O.quantity * P.price) AS "order total price"
FROM customers C
JOIN orders O ON C.cid = O.cid
JOIN products P ON O.pid = P.pid
GROUP BY C.cname, P.pid
ORDER BY
    C.cname ASC,
    SUM(O.quantity * P.price) DESC,
    P.pid ASC;


select 'Query 04' as '';
-- The customers who only ordered products originating from their country
-- Les clients n'ayant commandé que des produits provenant de leur pays
SELECT DISTINCT C.cname AS "customer"
FROM customers C
JOIN orders O ON C.cid = O.cid
JOIN products P ON O.pid = P.pid AND C.residence = P.origin;

select 'Query 05' as '';
-- The customers who ordered only products originating from foreign countries 
-- Les clients n'ayant commandé que des produits provenant de pays étrangers
SELECT DISTINCT C.cname AS "customer"
FROM customers C
JOIN orders O ON C.cid = O.cid
JOIN products P ON O.pid = P.pid AND (C.residence IS NULL OR c.residence != P.origin);

select 'Query 06' as '';
-- The difference between 'USA' residents' per-order average quantity and 'France' residents' (USA - France)
-- La différence entre quantité moyenne par commande des clients résidant aux 'USA' et celle des clients résidant en 'France' (USA - France)
SELECT
    'USA' AS "Country",
    AVG(CASE WHEN C.residence = 'USA' THEN O.quantity ELSE NULL END) AS "AVG USA",
    'France' AS "Country",
    AVG(CASE WHEN C.residence = 'France' THEN O.quantity ELSE NULL END) AS "AVG France",
    AVG(CASE WHEN C.residence = 'USA' THEN O.quantity ELSE NULL END) - AVG(CASE WHEN C.residence = 'France' THEN O.quantity ELSE NULL END) AS "Difference"
FROM customers C
JOIN orders O ON C.cid = O.cid;


select 'Query 07' as '';
-- The products ordered throughout 2014, i.e. ordered each month of that year
-- Les produits commandés tout au long de 2014, i.e. commandés chaque mois de cette année
SELECT P.pid, P.pname
FROM products P
WHERE NOT EXISTS (
    SELECT M.month
    FROM (
        SELECT DISTINCT MONTH(odate) AS month
        FROM orders
        WHERE YEAR(odate) = 2014
    ) M
    LEFT JOIN (
        SELECT DISTINCT MONTH(odate) AS month, O.pid
        FROM orders O
        WHERE YEAR(odate) = 2014
    ) MO ON M.month = MO.month AND P.pid = MO.pid
    WHERE MO.month IS NULL
);

select 'Query 08' as '';
-- The customers who ordered all the products that cost less than $5
-- Les clients ayant commandé tous les produits de moins de $5
SELECT C.cname AS "Customer Name"
FROM customers AS C
WHERE NOT EXISTS (
        SELECT P.pid
        FROM products AS P
        WHERE P.price < 5
        EXCEPT
        SELECT O.pid
        FROM orders AS O
        WHERE O.cid = C.cid
    );

select 'Query 09' as '';
-- The customers who ordered the greatest number of common products. Display 3 columns: cname1, cname2, number of common products, with cname1 < cname2
-- Les clients ayant commandé le grand nombre de produits commums. Afficher 3 colonnes : cname1, cname2, nombre de produits communs, avec cname1 < cname2
SELECT
    C1.cname AS cname1,
    C2.cname AS cname2,
    COUNT(DISTINCT O1.pid) AS "number of common products"
FROM customers C1
JOIN customers C2 ON C1.cid < C2.cid
JOIN orders O1 ON C1.cid = O1.cid
JOIN orders O2 ON C2.cid = O2.cid AND O1.pid = O2.pid
GROUP BY cname1, cname2
ORDER BY "number of common products" DESC;

select 'Query 10' as '';
-- The customers who ordered the largest number (total quantity) of products
-- Les clients ayant commandé le plus grand nombre (quantité totale) de produits
SELECT
    C.cname AS "Customer Name",
    SUM(O.quantity) AS "Total Amount of product"
FROM customers C
JOIN orders O ON C.cid = O.cid
GROUP BY C.cname
ORDER BY "Total Amount of product" DESC;

select 'Query 11' as '';
-- The products ordered by all the customers living in 'France'
-- Les produits commandés par tous les clients vivant en 'France'
SELECT P.pname AS "Product Name"
FROM products P
WHERE
    NOT EXISTS (
        SELECT DISTINCT C.cid
        FROM customers AS C
        WHERE C.residence = 'France'
        EXCEPT
        SELECT DISTINCT O.cid
        FROM orders AS O
        WHERE O.pid = P.pid
    );

select 'Query 12' as '';
-- The customers who live in the same country customers named 'Smith' live in (customers 'Smith' not shown in the result)
-- Les clients résidant dans les mêmes pays que les clients nommés 'Smith' (en excluant les Smith de la liste affichée)
SELECT DISTINCT
    C.cname AS "Customer Name"
FROM customers C
JOIN customers Smith ON C.residence = Smith.residence AND Smith.cname = 'Smith'
WHERE C.cname != 'Smith';

select 'Query 13' as '';
-- The customers who ordered the largest total amount (total price) in 2014
-- Les clients ayant commandé pour le plus grand montant total (prix total) sur 2014 
SELECT
    C.cname AS "Customer Name",
    SUM(O.quantity * P.price) AS "Total Amount Ordered in 2014"
FROM customers C
JOIN orders O ON C.cid = O.cid
JOIN products P ON O.pid = P.pid
WHERE YEAR(O.odate) = 2014
GROUP BY C.cname
ORDER BY "Total Amount Ordered in 2014" DESC;

select 'Query 14' as '';
-- The products with the largest per-order average amount (price) 
-- Les produits dont le montant (prix) moyen par commande est le plus élevé
SELECT
    P.pname AS "Product name",
    AVG(O.quantity * P.price) AS "price avg per Commande"
FROM products P
JOIN orders O ON P.pid = O.pid
GROUP BY P.pname;

select 'Query 15' as '';
-- The products ordered by the customers living in 'USA'
-- Les produits commandés par les clients résidant aux 'USA'
SELECT DISTINCT P.pname AS "product name"
FROM products P
JOIN orders O ON P.pid = O.pid
JOIN customers C ON O.cid = C.cid
WHERE C.residence = "USA";

select 'Query 16' as '';
-- The pairs of customers who ordered the same product en 2014, and that product. Display 3 columns: cname1, cname2, pname, with cname1 < cname2
-- Les paires de client ayant commandé le même produit en 2014, et ce produit. Afficher 3 colonnes : cname1, cname2, pname, avec cname1 < cname2
SELECT DISTINCT
    C1.cname AS cname1,
    C2.cname AS cname2,
    P.pname AS pname
FROM customers C1
JOIN customers C2 ON C1.cid < C2.cid
JOIN orders O1 ON C1.cid = O1.cid
JOIN orders O2 ON C2.cid = O2.cid AND O1.pid = O2.pid
JOIN products P ON O1.pid = P.pid
WHERE YEAR(O1.odate) = 2014
ORDER BY cname1, cname2, pname;

select 'Query 17' as '';
-- The products whose price is greater than all products from 'India'
-- Les produits plus chers que tous les produits d'origine 'India'
SELECT P1.pname AS "Product name"
FROM products P1
WHERE P1.price > ALL (SELECT P2.price 
                      FROM products P2
                      WHERE P2.origin = 'India');

select 'Query 18' as '';
-- The products ordered by the smallest number of customers (products never ordered are excluded)
-- Les produits commandés par le plus petit nombre de clients (les produits jamais commandés sont exclus)
SELECT
    P.pname AS "Product name",
    P.pid AS "Product ID",
    COUNT(DISTINCT O.cid) AS "N°customers"
FROM products P
JOIN orders O ON P.pid = O.pid
GROUP BY P.pname,P.pid
HAVING COUNT(DISTINCT O.cid) > 0
ORDER BY "N°customers" ASC
LIMIT 1;

select 'Query 19' as '';
-- For all countries listed in tables products or customers, including unknown countries: the name of the country, the number of customers living in this country, the number of products originating from that country
-- Pour chaque pays listé dans les tables products ou customers, y compris les pays inconnus : le nom du pays, le nombre de clients résidant dans ce pays, le nombre de produits provenant de ce pays 
SELECT
    COALESCE(C.residence, P.origin) AS "country",
    COUNT(DISTINCT C.cid) AS "N°Customers",
    COUNT(DISTINCT P.pid) AS "N°Products"
FROM customers C
LEFT JOIN products P ON C.residence = P.origin
GROUP BY COALESCE(C.residence, P.origin)
UNION
SELECT
    COALESCE(C.residence, P.origin) AS "country",
    COUNT(DISTINCT C.cid) AS "N°Customers",
    COUNT(DISTINCT P.pid) AS "N°Products"
FROM customers C
RIGHT JOIN products P ON C.residence = P.origin
GROUP BY COALESCE(C.residence, P.origin)
ORDER BY "country";

