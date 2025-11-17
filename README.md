# Talent Matching Intelligence System
This project builds a complete end-to-end system for identifying employee success patterns, generating a weighted Success Score, and performing candidate-to-role matching using SQL algorithm.

---

## Project Overview

The goal of this project is to:
- Identify what differentiates top performers
- Build a weighted Success Score based on normalized features
- Develop an automated SQL matching algorithm (TV → TGV → Final Match)
- Produce objective, scalable, data-driven talent insights

Main components include:
- Data preparation and normalization
- Success pattern discovery (correlation analysis)
- Success Score formula development
- Benchmarking top performers
- SQL matching engine

---

## Project Structure  
├── data_raw/ # Original datasets  
│  
├── data_clean/ # Cleaned dataset  
│  
├── data_master/ # Integrated dataset (df_master)  
│  
├── python/  
│ ├── talentmatch_00_data_preparation.ipynb  
│ ├── talentmatch_01_EDA.ipynb  
│  
├── sql/  
│ ├── 01-success_score.sql  
│ ├── 02-talent_benchmark.sql  
│ ├── 03-tv_variables.sql  
│ ├── 04-talent_matching.sql  
│  
├── README.md

---

## Setup Instructions

This project runs in two environments:  
**(A) Python** for data cleaning & formula building  
**(B) Supabase/PostgreSQL** for scoring & matching automation

---

## A. Python Setup (Data Prep + EDA)

### 1. Create a new notebook environment  
Use Jupyter Notebook or Google Colab.

### 2. Import raw data  
Import all the .csv files in the data_raw directory

### 3. Run `talentmatch_00_data_preparation.ipynb`  
Output: Cleaned dataset  

### 4. Create a new notebook  
Start a fresh notebook for analysis.

### 5. Import cleaned data
Import all the .csv files from the 3rd step output

### 6. Run `talentmatch_01_EDA.ipynb`  
**Output:**  
- Success pattern analysis  
- Correlation-based weights  
- Final Success Score Formula  
- `df_master` 

---

## B. 🗄️ Supabase / PostgreSQL Setup (Scoring + Matching)  

### 1. Import `df_master` into Supabase  
Upload as the main table.  

### 2. Run all SQL scripts sequentially:

1. `01-success_score`  
   → Calculates Success Score using final weights

2. `02-talent_benchmarks.sql`  
   → Create table and fill it with benchmark talent IDs (top performers)   

3. `03-tv_variables.sql`  
   → Loads Talent Variable configuration (TV & TGV)  

4. `04-talent_matching.sql`  
   → Generates TV Match %, TGV Match %, and Final Match %

**Final Output:** Complete talent-to-role matching table.

---
