import duckdb
from pathlib import Path

# STEP 1: Locate the main project folder
project_folder = Path(__file__).resolve().parent.parent

# STEP 2: Define raw and processed dataset paths
raw_path = project_folder / "Data" / "Raw" / "criteo_dataset.csv"

output_folder = project_folder / "Data" / "Processed"
output_folder.mkdir(parents=True, exist_ok=True)

output_path = output_folder / "clean_dataset.csv"

# STEP 3: Connect to DuckDB
con = duckdb.connect()

print("Starting dataset cleaning...")

# STEP 4: Read the raw dataset
raw_file_sql = str(raw_path).replace("\\", "/").replace("'", "''")

con.execute(f"""
    CREATE VIEW raw_data AS
    SELECT *
    FROM read_csv_auto('{raw_file_sql}')
""")

print("Raw dataset loaded successfully.")

# STEP 5: Verify required columns
required_columns = [
    "f0", "f1", "f2", "f3", "f4", "f5",
    "f6", "f7", "f8", "f9", "f10", "f11",
    "treatment", "conversion", "visit", "exposure"
]

actual_columns = [
    row[0] for row in con.execute("DESCRIBE raw_data").fetchall()
]

missing_columns = set(required_columns) - set(actual_columns)

if missing_columns:
    raise ValueError(f"Missing required columns: {missing_columns}")

print("Column validation completed.")

# STEP 6: Count original records
original_rows = con.execute("""
    SELECT COUNT(*) FROM raw_data
""").fetchone()[0]

print("Original rows:", original_rows)

# STEP 7: Remove exact duplicate records
con.execute("""
    CREATE VIEW unique_data AS
    SELECT DISTINCT *
    FROM raw_data
""")

unique_rows = con.execute("""
    SELECT COUNT(*) FROM unique_data
""").fetchone()[0]

print("Rows after duplicate removal:", unique_rows)
print("Duplicates removed:", original_rows - unique_rows)

# STEP 8: Validate experimental and outcome columns
con.execute("""
    CREATE VIEW valid_data AS
    SELECT *
    FROM unique_data
    WHERE treatment IN (0, 1)
      AND exposure IN (0, 1)
      AND visit IN (0, 1)
      AND conversion IN (0, 1)
""")

valid_rows = con.execute("""
    SELECT COUNT(*) FROM valid_data
""").fetchone()[0]

print("Rows after validation:", valid_rows)
print("Invalid rows removed:", unique_rows - valid_rows)

# STEP 9: Handle missing and infinite feature values
feature_columns = [f"f{i}" for i in range(12)]

clean_features = []

for column in feature_columns:

    clean_features.append(f"""
        CASE
            WHEN {column} IS NULL OR NOT isfinite({column})
            THEN (
                SELECT median({column})
                FROM valid_data
                WHERE {column} IS NOT NULL
                  AND isfinite({column})
            )
            ELSE {column}
        END AS {column}
    """)

feature_sql = ", ".join(clean_features)

# STEP 10: Create cleaned dataset
con.execute(f"""
    CREATE TABLE cleaned_data AS
    SELECT
        {feature_sql},
        treatment,
        conversion,
        visit,
        exposure
    FROM valid_data
""")

print("Feature cleaning completed.")

# STEP 11: Check remaining missing values
print("\nMissing values after cleaning:")

for column in feature_columns:

    missing = con.execute(f"""
        SELECT COUNT(*)
        FROM cleaned_data
        WHERE {column} IS NULL
    """).fetchone()[0]

    print(f"{column}: {missing}")

# STEP 12: Check final dataset size
final_rows = con.execute("""
    SELECT COUNT(*) FROM cleaned_data
""").fetchone()[0]

print("\nFinal cleaned rows:", final_rows)
print("Final columns:", len(required_columns))

# STEP 13: Save cleaned dataset
if output_path.exists():
    output_path.unlink()

output_file_sql = str(output_path).replace("\\", "/").replace("'", "''")

con.execute(f"""
    COPY cleaned_data
    TO '{output_file_sql}'
    (HEADER, DELIMITER ',')
""")

print("\nCleaning completed successfully!")
print("Clean dataset saved at:", output_path)

# STEP 14: Close database connection
con.close()

print("DuckDB connection closed.")