import sqlite3
import pandas as pd
from pathlib import Path


# ============================================================
# RETENTIONIQ - RUN SQL ANALYSIS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent

DB_PATH = BASE_DIR / "SQL" / "RetentionIQ.db"

SQL_FILE = BASE_DIR / "SQL" / "churn_analysis.sql"


# Check database exists
if not DB_PATH.exists():
    raise FileNotFoundError(
        f"Database not found:\n{DB_PATH}"
    )


# Check SQL file exists
if not SQL_FILE.exists():
    raise FileNotFoundError(
        f"SQL file not found:\n{SQL_FILE}"
    )


# Connect to database
conn = sqlite3.connect(DB_PATH)


# Read SQL file
with open(SQL_FILE, "r", encoding="utf-8") as file:
    sql_script = file.read()


# Split SQL file into individual queries
queries = [
    query.strip()
    for query in sql_script.split(";")
    if query.strip()
]


print("=" * 70)
print("RETENTIONIQ SQL ANALYSIS")
print("=" * 70)


# Run each query
for number, query in enumerate(queries, start=1):

    print("\n" + "=" * 70)
    print(f"QUERY {number}")
    print("=" * 70)

    try:
        result = pd.read_sql_query(
            query,
            conn
        )

        print(result.to_string(index=False))

    except Exception as error:
        print("ERROR:")
        print(error)


# Close database connection
conn.close()


print("\n" + "=" * 70)
print("SQL ANALYSIS COMPLETE")
print("=" * 70)