# 📊 Portfolio Financial Analytics

> **End-to-end data engineering pipeline for investment portfolio performance analysis vs. Ibovespa benchmark**

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📌 Overview

This project demonstrates a complete **data engineering and financial analytics pipeline** — from raw market data extraction to an interactive Power BI dashboard — applied to the Brazilian equity market.

The pipeline evaluates the performance of a multi-asset investment portfolio against the **Ibovespa (^BVSP)** benchmark, computing risk-adjusted metrics such as **Sharpe Ratio**, **rolling volatility**, and **drawdown**, enriched with Brazilian macroeconomic indicators (SELIC, CDI, IPCA) from the **Banco Central do Brasil API**.

This project was built as a portfolio piece showcasing the intersection of **data engineering skills** (Python, SQL, Star Schema modeling) and **financial domain knowledge** (CEA certification background).

---

## 🏗️ Architecture

```
┌─────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────┐
│   Data Sources      │────▶│  Extract & Transform  │────▶│  PostgreSQL (Star    │────▶│  Power BI        │
│                     │     │  (Python / Jupyter)   │     │  Schema)             │     │  Dashboard       │
│  • yfinance API     │     │                       │     │                      │     │                  │
│  • BCB API (macro)  │     │  • Feature engineering│     │  • fato_retornos_    │     │  • DAX measures  │
│    SELIC/CDI/IPCA   │     │  • Returns calc       │     │    diarios           │     │  • DirectQuery   │
│  • ^BVSP benchmark  │     │  • Rolling volatility │     │  • fato_retornos_    │     │  • KPI visuals   │
└─────────────────────┘     │  • Drawdown           │     │    acumulados        │     └──────────────────┘
                            │  • Sharpe Ratio        │     │  • dim_metricas_     │
                            └──────────────────────┘     │    risco             │
                                                          └──────────────────────┘
```

---

## 🚀 Features

- **Automated data extraction** from `yfinance` for Brazilian equities (VALE3, ITUB4, PETR4, etc.) and the Ibovespa index
- **Macroeconomic enrichment** via Banco Central do Brasil REST API (SELIC, CDI, IPCA rates)
- **Feature engineering**: daily returns, cumulative returns, 21-day rolling volatility (annualized), Sharpe Ratio, and drawdown from peak
- **Star Schema** data model in PostgreSQL with pre-calculated analytical views
- **Analytical SQL queries** with window functions (rolling stddev, running max for drawdown)
- **Power BI dashboard** with DirectQuery/Import hybrid and DAX measures for interactive analysis

---

## 📁 Project Structure

```
portfolio-financial-analytics/
│
├── extract_transform.ipynb      # Phase 1 – Data extraction, cleaning & feature engineering
├── load_postgres.ipynb          # Phase 2 – Load transformed data into PostgreSQL Star Schema
├── analytical_queries.sql       # Phase 2 – Analytical SQL queries & window functions
│
├── fato_retornos_diarios.csv    # Fact table: daily returns per asset
├── fato_retornos_acumulados.csv # Fact table: cumulative returns per asset
├── dim_metricas_risco.csv       # Dimension table: risk metrics (Sharpe, volatility, drawdown)
│
├── .gitignore
└── README.md
```

---

## 🗄️ Data Model (Star Schema)

```
                    ┌──────────────────────────┐
                    │   dim_metricas_risco      │
                    │──────────────────────────│
                    │  ativo (PK)               │
                    │  sharpe_ratio             │
                    │  volatilidade_anual       │
                    │  max_drawdown             │
                    │  retorno_total            │
                    └──────────┬───────────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                                         │
┌─────────▼──────────────┐           ┌──────────────▼──────────────┐
│  fato_retornos_diarios  │           │  fato_retornos_acumulados    │
│────────────────────────│           │────────────────────────────│
│  date                  │           │  date                       │
│  ativo                 │           │  ativo                      │
│  retorno_diario        │           │  retorno_acumulado          │
│  volatilidade_mov_21d  │           │  retorno_acumulado_pct      │
└────────────────────────┘           └─────────────────────────────┘
```

---

## 📈 Key Metrics Computed

| Metric | Description | Method |
|---|---|---|
| **Daily Return** | Day-over-day percentage change | `pct_change()` |
| **Cumulative Return** | Compounded total return from start | `(1 + r).cumprod() - 1` |
| **Rolling Volatility** | 21-day annualized standard deviation | `STDDEV_POP` window function × √252 |
| **Sharpe Ratio** | Risk-adjusted return vs. CDI (risk-free) | `(Rp - Rf) / σp` |
| **Drawdown** | Decline from historical peak | Running MAX window function |

---

## 🔧 Setup & Installation

### Prerequisites

- Python 3.10+
- PostgreSQL 15+
- Power BI Desktop (for dashboard)

### 1. Clone the repository

```bash
git clone https://github.com/ric-moreno/portfolio-financial-analytics.git
cd portfolio-financial-analytics
```

### 2. Create a virtual environment and install dependencies

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

> **Key libraries:** `yfinance`, `pandas`, `numpy`, `psycopg2`, `python-dotenv`, `requests`

### 3. Configure environment variables

Create a `.env` file in the project root (never commit this file):

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=financial_analytics
DB_USER=your_user
DB_PASSWORD=your_password
```

### 4. Set up the PostgreSQL database

```sql
CREATE DATABASE financial_analytics;
CREATE SCHEMA financial_analytics;
```

### 5. Run the notebooks in order

```
1. extract_transform.ipynb   → Extracts, cleans, and engineers features
2. load_postgres.ipynb       → Creates schema and loads data into PostgreSQL
```

### 6. Run analytical queries

Open `analytical_queries.sql` in your SQL client (DBeaver, pgAdmin, etc.) to explore the pre-built window function queries for drawdown and rolling volatility analysis.

---

## 📊 Power BI Dashboard

The dashboard connects to PostgreSQL via **DirectQuery** (for real-time data) with an **Import** layer for computed aggregations.

**DAX Measures included:**

```dax
-- Cumulative Return
Retorno Acumulado = CALCULATE(SUM(fato_retornos_acumulados[retorno_acumulado_pct]))

-- Annualized Volatility
Volatilidade Anual = AVERAGE(fato_retornos_diarios[volatilidade_mov_21d]) * SQRT(252)

-- Sharpe Ratio
Sharpe Ratio = DIVIDE([Retorno Acumulado] - [CDI_Acumulado], [Volatilidade Anual])

-- Alpha vs Ibovespa
Alpha = [Retorno_Portfolio] - [Retorno_BVSP]
```

---

## 🧠 Financial Context

This project is contextualized in the **Brazilian capital market**:

- **Benchmark:** Ibovespa (^BVSP) — the main Brazilian equity index
- **Risk-free rate:** CDI / SELIC — used as the risk-free rate for Sharpe Ratio (sourced from BCB API)
- **Inflation:** IPCA — used for real return adjustment
- **Assets analyzed:** Blue-chip Brazilian equities (VALE3, ITUB4, PETR4, BBAS3, etc.)

> This domain expertise is informed by a **CEA (Certificação de Especialista em Investimentos ANBIMA)** background, ensuring the financial metrics are correctly interpreted and applied.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Data Extraction | Python, `yfinance`, BCB REST API |
| Transformation | `pandas`, `numpy`, Jupyter Notebooks |
| Storage | PostgreSQL 15 (Star Schema) |
| Analytical SQL | Window functions, CTEs, pre-calculated views |
| Visualization | Power BI (DirectQuery + DAX) |
| Version Control | Git / GitHub |

---

## 👤 Author

**Ricardo Moreno**
Data Analyst | Financial Analytics | CEA — ANBIMA

[![GitHub](https://img.shields.io/badge/GitHub-ric--moreno-181717?style=flat&logo=github)](https://github.com/ric-moreno)
