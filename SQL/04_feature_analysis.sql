USE ExperimentLab_DB;
GO

CREATE OR ALTER VIEW dbo.vw_feature_analysis
AS

WITH FeatureValues AS
(
    SELECT
        c.treatment,
        v.Feature,
        v.FeatureValue
    FROM dbo.criteo_clean c
    CROSS APPLY
    (
        VALUES
        ('f0',  TRY_CONVERT(FLOAT, c.f0)),
        ('f1',  TRY_CONVERT(FLOAT, c.f1)),
        ('f2',  TRY_CONVERT(FLOAT, c.f2)),
        ('f3',  TRY_CONVERT(FLOAT, c.f3)),
        ('f4',  TRY_CONVERT(FLOAT, c.f4)),
        ('f5',  TRY_CONVERT(FLOAT, c.f5)),
        ('f6',  TRY_CONVERT(FLOAT, c.f6)),
        ('f7',  TRY_CONVERT(FLOAT, c.f7)),
        ('f8',  TRY_CONVERT(FLOAT, c.f8)),
        ('f9',  TRY_CONVERT(FLOAT, c.f9)),
        ('f10', TRY_CONVERT(FLOAT, c.f10)),
        ('f11', TRY_CONVERT(FLOAT, c.f11))
    ) v(Feature, FeatureValue)
    WHERE v.FeatureValue IS NOT NULL
),

GroupStats AS
(
    SELECT
        Feature,
        treatment,
        AVG(FeatureValue) AS Mean_Value,
        STDEV(FeatureValue) AS Std_Dev
    FROM FeatureValues
    GROUP BY Feature, treatment
),

Comparison AS
(
    SELECT
        Feature,
        MAX(CASE WHEN treatment = 1 THEN Mean_Value END) AS Treatment_Mean,
        MAX(CASE WHEN treatment = 0 THEN Mean_Value END) AS Control_Mean,
        MAX(CASE WHEN treatment = 1 THEN Std_Dev END) AS Treatment_SD,
        MAX(CASE WHEN treatment = 0 THEN Std_Dev END) AS Control_SD
    FROM GroupStats
    GROUP BY Feature
)

SELECT
    Feature,
    Treatment_Mean,
    Control_Mean,
    Treatment_SD,
    Control_SD,
    (Treatment_Mean - Control_Mean) /
    NULLIF(
        SQRT(
            (POWER(Treatment_SD, 2) + POWER(Control_SD, 2)) / 2.0
        ),
        0
    ) AS SMD,
    CASE
        WHEN ABS(
            (Treatment_Mean - Control_Mean) /
            NULLIF(
                SQRT(
                    (POWER(Treatment_SD, 2) + POWER(Control_SD, 2)) / 2.0
                ),
                0
            )
        ) < 0.10
        THEN 'Balanced'
        ELSE 'Imbalanced'
    END AS Balance_Status
FROM Comparison;
GO

SELECT * FROM dbo.vw_feature_analysis;