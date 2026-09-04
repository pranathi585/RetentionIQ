import sqlite3
import pandas as pd
from pathlib import Path


# ============================================================
# RETENTIONIQ - CREATE SQLITE DATABASE
# ============================================================

# Main project folder
BASE_DIR = Path(__file__).resolve().parent.parent

# Folder containing cleaned CSV files
DATA_DIR = BASE_DIR / "Cleaned_Data"

# Folder for SQL database
SQL_DIR = BASE_DIR / "SQL"

# Create SQL folder if it doesn't already exist
SQL_DIR.mkdir(parents=True, exist_ok=True)

# SQLite database path
DB_PATH = SQL_DIR / "RetentionIQ.db"


# ============================================================
# CHECK THAT CLEANED DATA FOLDER EXISTS
# ============================================================

if not DATA_DIR.exists():
    raise FileNotFoundError(
        f"Cleaned_Data folder not found:\n{DATA_DIR}"
    )


# ============================================================
# CSV FILES → SQL TABLES
# ============================================================

tables = {
    "accounts": "accounts_cleaned.csv",
    "subscriptions": "subscriptions_cleaned.csv",
    "feature_usage": "feature_usage_cleaned.csv",
    "support_tickets": "support_tickets_cleaned.csv",
    "churn_events": "churn_events_cleaned.csv",
    "customer_analytics": "customer_analytics.csv"
}


# ============================================================
# CREATE DATABASE
# ============================================================

print("=" * 70)
print("RETENTIONIQ DATABASE CREATION")
print("=" * 70)

print(f"\nProject folder:")
print(BASE_DIR)

print(f"\nCleaned data folder:")
print(DATA_DIR)

print(f"\nDatabase:")
print(DB_PATH)


# Connect to SQLite
conn = sqlite3.connect(DB_PATH)


# ============================================================
# LOAD EACH CSV INTO SQLITE
# ============================================================

for table_name, filename in tables.items():

    file_path = DATA_DIR / filename

    # Check that CSV exists
    if not file_path.exists():
        conn.close()
        raise FileNotFoundError(
            f"\nMissing file:\n{file_path}"
        )

    # Read CSV
    df = pd.read_csv(file_path)

    # Write dataframe to SQLite
    df.to_sql(
        table_name,
        conn,
        if_exists="replace",
        index=False
    )

    print(
        f"Loaded {table_name:<20} "
        f"{len(df):>7,} rows"
    )


# ============================================================
# VERIFY TABLES
# ============================================================

print("\n" + "=" * 70)
print("DATABASE VERIFICATION")
print("=" * 70)

cursor = conn.cursor()

cursor.execute("""
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
    ORDER BY name
""")

created_tables = cursor.fetchall()

print("\nTables created:")

for table in created_tables:
    print(f"✓ {table[0]}")


# ============================================================
# CLOSE DATABASE
# ============================================================

conn.close()


print("\n" + "=" * 70)
print("SUCCESS")
print("=" * 70)

print("\nRetentionIQ SQLite database created successfully!")
print(f"\nDatabase location:\n{DB_PATH}")