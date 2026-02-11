from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

from src.database.connection import fetch_dataframe

VIS_DIR = Path(__file__).resolve().parents[2] / "visualizations"
VIS_DIR.mkdir(parents=True, exist_ok=True)

sns.set_style("whitegrid")
plt.rcParams["figure.figsize"] = (12, 6)
plt.rcParams["font.size"] = 10


def plot_sales_evolution_monthly() -> None:
    query = """
    SELECT 
        DATE_FORMAT(o.orderDate, '%Y-%m') AS month,
        SUM(od.quantityOrdered * od.priceEach) AS total_sales
    FROM orders o
    JOIN orderdetails od ON od.orderNumber = o.orderNumber
    WHERE o.status = 'Shipped'
    GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m')
    ORDER BY month;
    """
    
    df = fetch_dataframe(query)
    df['month'] = pd.to_datetime(df['month'])
    df = df.sort_values('month')
    
    plt.figure(figsize=(16, 8))
    plt.plot(df['month'], df['total_sales'], marker='o', linewidth=2.5, markersize=10, 
             color='#2E86AB', markerfacecolor='white', markeredgewidth=2, markeredgecolor='#2E86AB')
    plt.fill_between(df['month'], df['total_sales'], alpha=0.2, color='#2E86AB')
    
    for idx, row in df.iterrows():
        plt.annotate(f'${row["total_sales"]:,.0f}', 
                    (row['month'], row['total_sales']),
                    textcoords="offset points", xytext=(0,10), ha='center', fontsize=8)
    
    z = np.polyfit(range(len(df)), df['total_sales'], 1)
    p = np.poly1d(z)
    plt.plot(df['month'], p(range(len(df))), "--", color='#A23B72', linewidth=2, alpha=0.7, label='Tendance')
    
    plt.title('Évolution temporelle des ventes par mois', fontsize=16, fontweight='bold', pad=20)
    plt.xlabel('Mois', fontsize=12)
    plt.ylabel('Chiffre d\'affaires ($)', fontsize=12)
    plt.grid(True, alpha=0.3, linestyle='--')
    plt.xticks(df['month'], [d.strftime('%Y-%m') for d in df['month']], rotation=45, ha='right')
    plt.legend()
    plt.tight_layout()
    
    output_path = VIS_DIR / "part3_sales_evolution_monthly.png"
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()


def plot_sales_evolution_quarterly() -> None:
    query = """
    SELECT 
        YEAR(o.orderDate) AS year,
        QUARTER(o.orderDate) AS quarter,
        SUM(od.quantityOrdered * od.priceEach) AS total_sales
    FROM orders o
    JOIN orderdetails od ON od.orderNumber = o.orderNumber
    WHERE o.status = 'Shipped'
    GROUP BY YEAR(o.orderDate), QUARTER(o.orderDate)
    ORDER BY year, quarter;
    """
    
    df = fetch_dataframe(query)
    df['quarter_label'] = df['year'].astype(str) + '-Q' + df['quarter'].astype(str)
    
    plt.figure(figsize=(14, 7))
    bars = plt.bar(df['quarter_label'], df['total_sales'], color='#06A77D', alpha=0.8, edgecolor='black', linewidth=1.2)
    
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2., height,
                f'${height:,.0f}',
                ha='center', va='bottom', fontsize=9, fontweight='bold')
    
    plt.title('Évolution temporelle des ventes par trimestre', fontsize=16, fontweight='bold', pad=20)
    plt.xlabel('Trimestre', fontsize=12)
    plt.ylabel('Chiffre d\'affaires ($)', fontsize=12)
    plt.xticks(rotation=45)
    plt.grid(True, alpha=0.3, axis='y', linestyle='--')
    plt.tight_layout()
    
    output_path = VIS_DIR / "part3_sales_evolution_quarterly.png"
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()


def main() -> None:
    plot_sales_evolution_monthly()
    plot_sales_evolution_quarterly()


if __name__ == "__main__":
    main()
