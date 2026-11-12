USE ExperimentLab_DB;

-- Total records
SELECT COUNT(*) AS Total_Records
FROM dbo.criteo_clean;

-- Check treatment distribution
SELECT
    treatment,
    COUNT(*) AS Total_Users
FROM dbo.criteo_clean
GROUP BY treatment;

-- Check conversion distribution
SELECT
    conversion,
    COUNT(*) AS Total_Conversions
FROM dbo.criteo_clean
GROUP BY conversion;

-- Check exposure distribution
SELECT
    exposure,
    COUNT(*) AS Total_Users
FROM dbo.criteo_clean
GROUP BY exposure;