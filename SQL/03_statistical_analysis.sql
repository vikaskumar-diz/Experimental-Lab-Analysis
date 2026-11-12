USE ExperimentLab_DB;
GO

CREATE OR ALTER VIEW dbo.vw_statistical_analysis
AS

WITH GroupStats AS
(
    SELECT
        treatment,
        COUNT_BIG(*) AS Total_Observations,
        SUM(CASE WHEN conversion = 1 THEN 1 ELSE 0 END) AS Total_Conversions
    FROM dbo.criteo_clean
    GROUP BY treatment
),

Rates AS
(
    SELECT
        MAX(CASE WHEN treatment = 1 THEN Total_Observations END) AS Treatment_Total,
        MAX(CASE WHEN treatment = 0 THEN Total_Observations END) AS Control_Total,

        MAX(CASE WHEN treatment = 1 THEN Total_Conversions END) AS Treatment_Conversions,
        MAX(CASE WHEN treatment = 0 THEN Total_Conversions END) AS Control_Conversions
    FROM GroupStats
),

RateCalculations AS
(
    SELECT
        *,
        CAST(Treatment_Conversions AS FLOAT) / NULLIF(Treatment_Total, 0) AS Treatment_Rate,
        CAST(Control_Conversions AS FLOAT) / NULLIF(Control_Total, 0) AS Control_Rate
    FROM Rates
),

StatsCalc AS
(
    SELECT
        *,
        Treatment_Rate - Control_Rate AS Absolute_Lift,

        SQRT(
            Treatment_Rate * (1 - Treatment_Rate) / Treatment_Total
            +
            Control_Rate * (1 - Control_Rate) / Control_Total
        ) AS Standard_Error
    FROM RateCalculations
),

ConfidenceInterval AS
(
    SELECT
        *,
        Absolute_Lift - 1.96 * Standard_Error AS CI_Lower,
        Absolute_Lift + 1.96 * Standard_Error AS CI_Upper
    FROM StatsCalc
)

SELECT
    Treatment_Total,
    Control_Total,
    Treatment_Conversions,
    Control_Conversions,
    Treatment_Rate,
    Control_Rate,
    Absolute_Lift,
    Standard_Error,
    CI_Lower,
    CI_Upper,

    Absolute_Lift / NULLIF(Standard_Error, 0) AS Z_Statistic,

    CASE
        WHEN CI_Lower > 0 OR CI_Upper < 0
            THEN 'Significant'
        ELSE 'Not Significant'
    END AS Significance_Status

FROM ConfidenceInterval;
GO