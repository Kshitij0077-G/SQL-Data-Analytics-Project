# 📊 SQL-Data-Analytics-Project

## 🚀 Overview

This project demonstrates a complete **Data Analytics workflow using SQL**, where raw data is transformed into meaningful insights through structured querying and analytical techniques.

Instead of treating queries as isolated tasks, the project follows a **logical, step-by-step analytical progression**, where each query builds upon the previous one—mirroring how real-world data analysts approach problem-solving.

---
![Data Analytics Roadmap](docs/data-analytics.png)

---

## 📂 The Analytical Workflow

**1. Data Exploration (Discovery Phase):**
  Understanding the dataset's structure and boundaries before performing deeper calculations.
  - Environment Setup: Configured core database environments and schema layouts (Gold_Schema.sql).
  - Structural Auditing: Executed baseline integrity verifications for database dimensions and measures (Check for dimension and measure.sql).
  - Data Profiling: Explored data fields, date boundaries, magnitudes, and structural item positions (Database Exploration.sql, Date Exploration.sql, Dimensions Exploration.sql, Measure Exploration.sql, Magnitude Analysis.sql, Ranking Analysis.sql).

**2. Performance & Contribution Analysis:**
  Evaluating how different products, categories, and business units drive revenue.
  - Sector Performance: Evaluated core driving sales metrics across distinct business sectors (Performance Analysis.sql).
  - Revenue Share: Calculated the part-to-whole percentage contributions of each product category to total sales (Part-to-Whole.sql).

**3. Trend & Growth Analysis:**
Introducing the time dimension to monitor business progression and momentum over time.
- Time-Series Tracking: Modeled daily and monthly sales performance to identify shifts and business trends over time (Change_over_time_Analysis.sql).
- Cumulative Metrics: Applied rolling windows to calculate running totals and track ongoing growth progression (Cumulative_Analysis.sql).

**4. Customer Segmentation:**
Applying conditional business logic to organize rows into meaningful target groups.
- Value Brackets: Used conditional logic to segment customer datasets into distinct value groups based on purchase metrics (Data_Segmentation_Analysis.sql).

**5. Consolidated Executive Reporting:**
Bringing the entire analytical journey together into a clean summary for decision-making.
- Final Summaries: Compiled multi-layer analysis scripts into production-ready reporting views built around business customers and products (Customers_Reporting.sql, Product_Reporting.sql).

---

## 🎯 What You Will Learn

By exploring this workflow, you will see how to:
* **Audit & Profile Data:** Efficiently map out and understand an unfamiliar database structure.
* **Write Analytical Queries:** Master window functions to calculate running totals, rankings, and percentage shares.
* **Apply Business Logic:** Use conditional statements to segment data and answer complex business questions.
* **Build Executive Summaries:** Translate raw business problems into clean, structured reporting metrics.

---

## 🧠 Core Competencies & Skills Demonstrated

* **Analytical Thinking:** Translating multi-step business problems into structured SQL solutions.
* **Advanced Querying:** Heavy usage of Window Functions, multi-level Aggregations, and conditional `CASE` statements.
* **Data Lifecycle Flow:** Moving cleanly from initial data exploration to final executive-level reporting layers.

---

## 🛠️ Technology Used
* **Languages & Frameworks:** T-SQL / SQL Server
* **Environment & Tools:** Relational Database Concepts, Git, GitHub

---
## 📂 Project Structure
```
SQL-Data-Analytics-Project/
│
├── datasets/                            # Cleaned transactional & dimensional datasets
│   └── files/
│       ├── dim_customers.csv            # Customer dimensional data
│       ├── dim_products.csv             # Product metadata and catalog
│       └── fact_sales.csv               # Central core sales transactions table
│
├── docs/                                # Media assets and documentation
│   └── data-analytics.png               # The analytical lifecycle roadmap image
│
└── scripts/                             # Complete database & analytical development scripts
    ├── Create_Schema/
    │   └── Gold_Schema.sql              # Final schema configuration script
    │
    ├── Data Analysis/
    │   ├── EDA/                         # Phase 1: Exploratory Data Analysis
    │   │   ├── Database Exploration.sql
    │   │   ├── Date Exploration.sql
    │   │   ├── Dimensions Exploration.sql
    │   │   ├── Magnitude Analysis.sql
    │   │   ├── Measure Exploration.sql
    │   │   └── Ranking Analysis.sql
    │   │
    │   ├── Advanced Analytics/          # Phases 2-5: Window functions & business logic
    │   │   ├── Change_over_time_Analysis.sql
    │   │   ├── Cumulative_Analysis.sql
    │   │   ├── Data_Segmentation_Analysis.sql
    │   │   ├── Part-to-Whole.sql        # Percentage share/contribution queries
    │   │   └── Performance Analysis.sql
    │   │
    │   └── Reporting/                   # Phase 6: Final executive metrics
    │       ├── Customers_Reporting.sql
    │       └── Product_Reporting.sql
    │
    └── Dimension and Measure/
        └── Check for dimension and measure.sql
```
## 💼 Use Case

This project simulates a real-world scenario where a data analyst:

* Understands business data
* Performs analysis using SQL
* Generates insights for decision-making
* Builds structured and reusable queries

It is ideal for anyone preparing for **Data Analyst roles** and looking to showcase practical SQL skills.

---

## 🧠 Conclusion

This project demonstrates how SQL can be used to solve real-world analytical problems by:

* Structuring raw data into meaningful insights
* Applying step-by-step analytical thinking
* Using queries to answer business-driven questions

It highlights the practical role of SQL in turning data into actionable decisions.

---

## 🛡️ License
This project is licensed under the MIT License. You are free to use, modify, and share this project with proper attribution.

## 🔎 About Me
Hi, I’m **Kshitij Gudekar** — a former **Data Analyst** expanding my expertise in **Data Engineering**.
This project connects both roles by using the clean tables from my previous data warehouse project. My goal was to complete the data lifecycle: taking those engineered datasets and using analytical SQL to build out business logic, track trends, and create final summaries.
