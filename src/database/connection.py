import os
from typing import Optional

import mysql.connector
from mysql.connector import pooling
from dotenv import load_dotenv


# Charge automatiquement les variables définies dans un fichier .env (s'il existe).
load_dotenv()


class MySQLConnectionPool:
    """Pool de connexions MySQL simple basé sur mysql-connector-python."""

    def __init__(
        self,
        pool_name: str = "classicmodels_pool",
        pool_size: int = 5,
        host: Optional[str] = None,
        port: Optional[int] = None,
        user: Optional[str] = None,
        password: Optional[str] = None,
        database: Optional[str] = None,
    ) -> None:
        self._pool = pooling.MySQLConnectionPool(
            pool_name=pool_name,
            pool_size=pool_size,
            pool_reset_session=True,
            host=host or os.getenv("DB_HOST", "localhost"),
            port=port or int(os.getenv("DB_PORT", "3306")),
            user=user or os.getenv("DB_USER", "root"),
            password=password or os.getenv("DB_PASSWORD", ""),
            database=database or os.getenv("DB_NAME", "classicmodels"),
        )

    def get_connection(self):
        """Retourne une connexion MySQL depuis le pool."""
        return self._pool.get_connection()


pool = MySQLConnectionPool()


def fetch_dataframe(query: str, params: Optional[tuple] = None):
    """Exécute une requête SELECT et retourne un DataFrame pandas."""
    import pandas as pd

    conn = pool.get_connection()
    try:
        df = pd.read_sql(query, conn, params=params)
    finally:
        conn.close()
    return df

