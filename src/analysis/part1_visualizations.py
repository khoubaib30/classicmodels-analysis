from pathlib import Path

import matplotlib.pyplot as plt
import seaborn as sns

from src.database.connection import fetch_dataframe


PROJECT_ROOT = Path(__file__).resolve().parents[2]
VIS_DIR = PROJECT_ROOT / "visualizations"
VIS_DIR.mkdir(parents=True, exist_ok=True)


def plot_entity_counts() -> None:
    """Bar chart: nombre de clients, employés, bureaux, commandes, produits, gammes."""
    labels = []
    values = []

    queries = [
        ("Clients", "SELECT COUNT(*) AS value FROM customers"),
        ("Employés", "SELECT COUNT(*) AS value FROM employees"),
        ("Bureaux", "SELECT COUNT(*) AS value FROM offices"),
        ("Commandes", "SELECT COUNT(*) AS value FROM orders"),
        ("Produits", "SELECT COUNT(*) AS value FROM products"),
        ("Gammes", "SELECT COUNT(*) AS value FROM productlines"),
    ]

    for label, query in queries:
        df = fetch_dataframe(query)
        labels.append(label)
        values.append(int(df["value"].iloc[0]))

    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(8, 5))
    sns.barplot(x=labels, y=values, palette="Blues_d")
    plt.title("Volumes par entité")
    plt.ylabel("Nombre")
    plt.xlabel("")
    plt.tight_layout()
    plt.savefig(VIS_DIR / "part1_entity_counts.png")
    plt.close()


def plot_customers_by_country(top_n: int = 15) -> None:
    """Bar chart: répartition géographique des clients (top N pays)."""
    query = """
        SELECT country, COUNT(*) AS nb_clients
        FROM customers
        GROUP BY country
        ORDER BY nb_clients DESC
    """
    df = fetch_dataframe(query)
    df_top = df.head(top_n)

    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(10, 6))
    sns.barplot(
        data=df_top,
        x="nb_clients",
        y="country",
        palette="viridis",
    )
    plt.title(f"Répartition des clients par pays (top {top_n})")
    plt.xlabel("Nombre de clients")
    plt.ylabel("Pays")
    plt.tight_layout()
    plt.savefig(VIS_DIR / "part1_clients_by_country.png")
    plt.close()


def plot_orders_by_status() -> None:
    """Bar chart: répartition des commandes par statut avec pourcentages."""
    query = """
        SELECT status, COUNT(*) AS nb_commandes
        FROM orders
        GROUP BY status
        ORDER BY nb_commandes DESC
    """
    df = fetch_dataframe(query)
    total = df["nb_commandes"].sum()
    df["pct"] = df["nb_commandes"] / total * 100

    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(8, 5))
    ax = sns.barplot(
        data=df,
        x="status",
        y="nb_commandes",
        palette="Set2",
    )

    for p, pct in zip(ax.patches, df["pct"]):
        ax.annotate(
            f"{pct:.1f}%",
            (p.get_x() + p.get_width() / 2.0, p.get_height()),
            ha="center",
            va="bottom",
            fontsize=9,
        )

    plt.title("Répartition des commandes par statut")
    plt.xlabel("Statut")
    plt.ylabel("Nombre de commandes")
    plt.tight_layout()
    plt.savefig(VIS_DIR / "part1_orders_by_status.png")
    plt.close()


def plot_top10_products() -> None:
    """Bar chart: top 10 produits les plus vendus (en quantité)."""
    query = """
        SELECT
          p.productCode,
          p.productName,
          SUM(od.quantityOrdered) AS total_qty
        FROM orderdetails AS od
        JOIN products AS p
          ON p.productCode = od.productCode
        GROUP BY
          p.productCode,
          p.productName
        ORDER BY
          total_qty DESC
        LIMIT 10
    """
    df = fetch_dataframe(query)

    # On tronque un peu le nom pour l'affichage
    df["label"] = df["productCode"] + " - " + df["productName"].str.slice(0, 20)

    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(10, 6))
    sns.barplot(
        data=df,
        x="total_qty",
        y="label",
        palette="magma",
    )
    plt.title("Top 10 produits les plus vendus (en quantité)")
    plt.xlabel("Quantité totale vendue")
    plt.ylabel("Produit")
    plt.tight_layout()
    plt.savefig(VIS_DIR / "part1_top10_products.png")
    plt.close()


def plot_top5_customers() -> None:
    """Bar chart: top 5 clients par chiffre d'affaires."""
    query = """
        SELECT
          c.customerNumber,
          c.customerName,
          SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires
        FROM customers c
        JOIN orders o ON o.customerNumber = c.customerNumber
        JOIN orderdetails od ON od.orderNumber = o.orderNumber
        GROUP BY c.customerNumber, c.customerName
        ORDER BY chiffre_affaires DESC
        LIMIT 5
    """
    df = fetch_dataframe(query)

    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(8, 5))
    sns.barplot(
        data=df,
        x="chiffre_affaires",
        y="customerName",
        palette="cubehelix",
    )
    plt.title("Top 5 clients par chiffre d'affaires")
    plt.xlabel("Chiffre d'affaires")
    plt.ylabel("Client")
    plt.tight_layout()
    plt.savefig(VIS_DIR / "part1_top5_customers.png")
    plt.close()


def plot_revenue_by_product_line() -> None:
    """Bar chart: chiffre d'affaires par gamme de produits."""
    query = """
        SELECT
          pl.productLine,
          SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires
        FROM orderdetails od
        JOIN products p ON p.productCode = od.productCode
        JOIN productlines pl ON pl.productLine = p.productLine
        GROUP BY pl.productLine
        ORDER BY chiffre_affaires DESC
    """
    df = fetch_dataframe(query)

    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(9, 5))
    sns.barplot(
        data=df,
        x="chiffre_affaires",
        y="productLine",
        palette="coolwarm",
    )
    plt.title("Chiffre d'affaires par gamme de produits")
    plt.xlabel("Chiffre d'affaires")
    plt.ylabel("Gamme de produits")
    plt.tight_layout()
    plt.savefig(VIS_DIR / "part1_revenue_by_product_line.png")
    plt.close()


def plot_sales_distribution() -> None:
    """Histogramme des montants de commande avec indication du panier moyen et du total des ventes."""
    query = """
        SELECT
            orderNumber,
            SUM(quantityOrdered * priceEach) AS order_total
        FROM orderdetails
        GROUP BY orderNumber
    """
    df = fetch_dataframe(query)

    total_sales = df["order_total"].sum()
    avg_cart = df["order_total"].mean()

    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(9, 5))
    sns.histplot(df["order_total"], bins=30, kde=False, color="skyblue")
    plt.axvline(avg_cart, color="red", linestyle="--", label=f"Panier moyen ≈ {avg_cart:,.0f}")

    plt.title(f"Distribution des montants de commande\nTotal des ventes ≈ {total_sales:,.0f}")
    plt.xlabel("Montant de la commande")
    plt.ylabel("Nombre de commandes")
    plt.legend()
    plt.tight_layout()
    plt.savefig(VIS_DIR / "part1_sales_distribution.png")
    plt.close()


def plot_top_employees(n: int = 5) -> None:
    """Bar chart: top N employés par chiffre d'affaires."""
    query = f"""
        SELECT
          e.employeeNumber,
          e.lastName,
          e.firstName,
          e.jobTitle,
          SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires
        FROM employees e
        JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
        JOIN orders o ON o.customerNumber = c.customerNumber
        JOIN orderdetails od ON od.orderNumber = o.orderNumber
        GROUP BY e.employeeNumber, e.lastName, e.firstName, e.jobTitle
        ORDER BY chiffre_affaires DESC
        LIMIT {n}
    """
    df = fetch_dataframe(query)
    df["employee"] = df["firstName"] + " " + df["lastName"]

    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(8, 5))
    sns.barplot(
        data=df,
        x="chiffre_affaires",
        y="employee",
        palette="Greens",
    )
    plt.title(f"Top {n} employés par chiffre d'affaires")
    plt.xlabel("Chiffre d'affaires")
    plt.ylabel("Employé")
    plt.tight_layout()
    plt.savefig(VIS_DIR / "part1_top_employees.png")
    plt.close()


def main() -> None:
    """Génère tous les graphiques de la Partie 1 et les enregistre dans visualizations/."""
    plot_entity_counts()
    plot_customers_by_country()
    plot_orders_by_status()
    plot_top10_products()
    plot_top5_customers()
    plot_revenue_by_product_line()
    plot_sales_distribution()
    plot_top_employees()


if __name__ == "__main__":
    main()

