ExperimentLab — Advertising Experimentation & Uplift Analytics

An end-to-end data analytics project to measure the impact of digital advertising on user conversions.

Project Overview

ExperimentLab analyzes an advertising experiment to understand whether users assigned to an advertising treatment convert more often than users in a control group.

Business Question

Does advertising improve conversion, and how strong is the evidence?

Dataset

- Source: Criteo Uplift Prediction Dataset
- Original size: Approximately 13.98 million rows
- Cleaned data: 12.72 million rows
- Key fields: Treatment, conversion, visit, exposure, and 12 anonymized features.

Technology Stack

- Python & DuckDB — large-data cleaning and preparation
- SQL Server — data storage and analytical queries
- Power BI — interactive dashboards
- Jupyter Notebook — analysis and exploration

Project Workflow

1. Acquire the raw dataset.
2. Clean and validate data using Python and DuckDB.
3. Load the prepared data into SQL Server.
4. Create SQL views for experiment KPIs and statistical analysis.
5. Build interactive Power BI dashboards.

Key Findings

Metric| Result
Treatment conversion rate| 0.3440%
Control conversion rate| 0.1984%
Absolute lift| +0.1456 percentage points
Relative lift| +73.38%
Balanced features| 12 / 12

Results describe the prepared analytical sample and should be interpreted alongside the experiment design and statistical assumptions.

Power BI Dashboards

1. Executive Overview — overall experiment performance.
2. Advertising Effectiveness — exposure and visit behaviour.
3. Statistical Evidence — significance and feature balance.
4. Uplift & Targeting — planned audience-level treatment-effect analysis.

Limitations

The dataset does not include customer identifiers, timestamps, advertising costs, or revenue. Therefore, customer-level tracking, time trends, CPA, ROAS, and profit cannot be calculated from these data.

Future Improvements

- Complete the Uplift & Targeting dashboard.
- Develop and evaluate uplift models.
- Add dashboard screenshots and reproducible setup instructions.

---

ExperimentLab demonstrates a large-scale analytics workflow, from raw data preparation to SQL analysis and interactive business reporting.
