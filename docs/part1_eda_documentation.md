Partie 1 – Analyse exploratoire de ClassicModels  
Ce document commente les requêtes du fichier `database/queries/part1_eda.sql`.  

1. Volumes de base (clients, employés, bureaux, commandes, produits, gammes)

On commence par compter les grandes entités du modèle : clients, employés, bureaux, commandes, produits et gammes de produits.  
Chaque requête fait un simple `COUNT(*)` sur la table concernée.  
Cela donne une première idée de la taille de la base et du périmètre à analyser.



2. Répartition géographique des clients

Ici on s’intéresse à **où** se trouvent les clients.  
On regroupe les lignes de la table `customers` par pays (`country`) et on compte le nombre de clients dans chaque pays.  
Le tri décroissant permet de voir tout de suite quels sont les marchés les plus importants.



3. Commandes par statut

Cette requête regarde la table `orders` et compte combien de commandes se trouvent dans chaque statut : `Shipped`, `Cancelled`, `On Hold`, etc.  
Ça aide à repérer d’éventuels problèmes opérationnels (trop d’annulés, beaucoup de commandes en attente, …).


4. Montant total des ventes et panier moyen

Le chiffre d’affaires n’est pas stocké directement, il faut le reconstruire.  
On calcule d’abord, pour chaque commande, la somme `quantityOrdered * priceEach` sur `orderdetails` : c’est le **montant de la commande**.  
Ensuite on additionne tous ces montants pour obtenir le **total des ventes**, puis on en fait la moyenne pour estimer le **panier moyen**.


5. Top 10 des produits les plus vendus (en quantité)

On joint `orderdetails` avec `products` pour retrouver le nom et le code de chaque produit.  
On additionne les quantités commandées (`SUM(quantityOrdered)`) pour chaque produit, puis on trie du plus vendu au moins vendu.  
Les 10 premières lignes du résultat correspondent aux produits qui sortent le plus en volume.


6. Top 5 des meilleurs clients (chiffre d’affaires)

On part des clients (`customers`), qu’on relie à leurs commandes (`orders`), puis aux lignes de commande (`orderdetails`).  
Comme pour les ventes totales, on calcule pour chaque client la somme `quantityOrdered * priceEach`, ce qui donne le **chiffre d’affaires généré par ce client**.  
On trie par montant décroissant et on garde les 5 premiers : ce sont les clients “VIP” en termes de revenu.



7. Employé qui a réalisé le plus de ventes

Chaque client peut avoir un commercial référent (`salesRepEmployeeNumber`).  
On crédite donc à cet employé l’ensemble des ventes réalisées par ses clients (même calcul de chiffre d’affaires qu’au-dessus).  
Après agrégation par employé, on trie par montant décroissant et on retient celui qui a généré le plus de ventes.


8. Gamme de produits la plus rentable

On remonte de `orderdetails` vers `products`, puis vers `productlines` pour savoir à quelle **gamme** appartient chaque vente.  
On somme à nouveau `quantityOrdered * priceEach`, cette fois en regroupant par `productLine`.  
La gamme en tête du classement est celle qui génère le plus de chiffre d’affaires et qu’on peut considérer comme la plus rentable à ce stade de l’analyse.



