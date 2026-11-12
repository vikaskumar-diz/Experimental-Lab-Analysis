USE ExperimentLab_DB;
GO

-- =============================================
-- EXPERIMENTLAB
-- 02: EXPERIMENT KPI ANALYSIS
-- =============================================

-- STEP 1: Calculate overall experiment statistics

WITH GroupSummary AS
(
    SELECT
        treatment,

        COUNT_BIG(*) AS Total_Observations,

        SUM(CAST(conversion AS BIGINT))
            AS Total_Conversions,

        SUM(CAST(visit AS BIGINT))
            AS Total_Visits,

        SUM(CAST(exposure AS BIGINT))
            AS Total_Exposures

    FROM dbo.criteo_clean

    GROUP BY treatment
),

-- STEP 2: Calculate treatment and control metrics

KPI AS
(
    SELECT

        SUM(CASE WHEN treatment = 1
            THEN Total_Observations ELSE 0 END)
            AS Treatment_Observations,

        SUM(CASE WHEN treatment = 0
            THEN Total_Observations ELSE 0 END)
            AS Control_Observations,

        SUM(CASE WHEN treatment = 1
            THEN Total_Conversions ELSE 0 END)
            AS Treatment_Conversions,

        SUM(CASE WHEN treatment = 0
            THEN Total_Conversions ELSE 0 END)
            AS Control_Conversions,

        SUM(CASE WHEN treatment = 1
            THEN Total_Visits ELSE 0 END)
            AS Treatment_Visits,

        SUM(CASE WHEN treatment = 0
            THEN Total_Visits ELSE 0 END)
            AS Control_Visits,

        SUM(CASE WHEN treatment = 1
            THEN Total_Exposures ELSE 0 END)
            AS Treatment_Exposures

    FROM GroupSummary
),

-- STEP 3: Calculate conversion and visit rates

Rates AS
(
    SELECT
        *,

        CAST(Treatment_Conversions AS FLOAT)
            / NULLIF(Treatment_Observations, 0)
            AS Treatment_Conversion_Rate,

        CAST(Control_Conversions AS FLOAT)
            / NULLIF(Control_Observations, 0)
            AS Control_Conversion_Rate,

        CAST(Treatment_Visits AS FLOAT)
            / NULLIF(Treatment_Observations, 0)
            AS Treatment_Visit_Rate,

        CAST(Control_Visits AS FLOAT)
            / NULLIF(Control_Observations, 0)
            AS Control_Visit_Rate,

        CAST(Treatment_Exposures AS FLOAT)
            / NULLIF(Treatment_Observations, 0)
            AS Treatment_Exposure_Rate

    FROM KPI
)

-- STEP 4: Display final business KPIs

SELECT

    Treatment_Observations
        AS Treatment_Total,

    Control_Observations
        AS Control_Total,

    Treatment_Observations + Control_Observations
        AS Total_Observations,

    Treatment_Conversions,
    Control_Conversions,

    ROUND(Treatment_Conversion_Rate * 100, 4)
        AS Treatment_Conversion_Percent,

    ROUND(Control_Conversion_Rate * 100, 4)
        AS Control_Conversion_Percent,

    ROUND(
        (Treatment_Conversion_Rate -
         Control_Conversion_Rate) * 100,
        4
    ) AS Absolute_Lift_Percentage_Points,

    ROUND(
        (
            (Treatment_Conversion_Rate -
             Control_Conversion_Rate)
            / NULLIF(Control_Conversion_Rate, 0)
        ) * 100,
        4
    ) AS Relative_Lift_Percent,

    ROUND(
        (Treatment_Conversion_Rate -
         Control_Conversion_Rate)
        * Treatment_Observations,
        2
    ) AS Estimated_Incremental_Conversions,

    Treatment_Visits,
    Control_Visits,

    ROUND(Treatment_Visit_Rate * 100, 4)
        AS Treatment_Visit_Percent,

    ROUND(Control_Visit_Rate * 100, 4)
        AS Control_Visit_Percent,

    ROUND(Treatment_Exposure_Rate * 100, 4)
        AS Treatment_Exposure_Percent

FROM Rates;
GO