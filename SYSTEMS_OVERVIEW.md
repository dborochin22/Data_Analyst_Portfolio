# Systems Overview

How the pieces of this portfolio fit together: the tools, the data flow in each project, and how to rebuild everything from the raw sources.

## 1. Repository at a glance

```mermaid
flowchart LR
    root["Data_Analyst_Portfolio"]
    root --> r["README.md<br/>landing page: skills, project index"]
    root --> l["LICENSE<br/>MIT"]
    root --> p1["project-01-netflix-content-analysis"]
    root --> p2["project-02-classic-models-sales-analysis"]

    p1 --> p1r["README.md<br/>case study"]
    p1 --> p1raw["data/raw/<br/>Kaggle source CSV"]
    p1 --> p1c["data/cleaned/<br/>Excel-cleaned CSVs, wide format"]
    p1 --> p1s["sql/<br/>01-04 long tables, 05-06 analysis"]
    p1 --> p1o["outputs/<br/>.pbix + screenshots"]

    p2 --> p2r["README.md<br/>case study"]
    p2 --> p2d["data/classicmodels_script.sql<br/>creates and loads the database"]
    p2 --> p2s["sql/<br/>01 exploration, 02 Power BI view"]
    p2 --> p2o["outputs/<br/>.pbix + screenshots"]
```

Each project is self-contained. Nothing is shared between them except the conventions below.

## 2. Technology stack

| Layer | Tool | Role |
|-------|------|------|
| Cleaning | Excel | Split multi-value columns, fix shifted rows, mark `NULL`s (Project 1) |
| Storage / modeling | MySQL | Schemas, unpivoted tables, views (both projects) |
| Presentation | Power BI Desktop | Dashboards, DAX measures, slicers, bookmarks (both projects) |
| Verification | Python (ad hoc) | Independent check of Project 1 row counts |
| Publishing | Git / GitHub | Version control, case-study READMEs, MIT license |

## 3. Project 1: Netflix Content Analysis

**Question:** Which audiences does the catalog serve most heavily, and which genres define each?

### Data flow

```mermaid
flowchart TD
    A["Kaggle netflix_titles.csv<br/>8,807 rows"] -->|"Excel: split duration, fix 3 shifted rows,<br/>split multi-value columns, mark NULLs"| B["data/cleaned/*.csv<br/>main table + cast, directors, countries,<br/>listed_in, description (wide format)"]
    B -->|"load into MySQL schema netflix_data"| C["sql/01-04<br/>UNION-unpivot each wide table"]
    C --> D1["netflix_listed_in<br/>19,323 rows"]
    C --> D2["netflix_directors<br/>6,977 rows"]
    C --> D3["countries_released<br/>10,012 rows"]
    C --> D4["netflix_cast<br/>64,124 rows"]
    D1 & D2 & D3 & D4 --> E["sql/05-06<br/>titles added per year, audience share by rating"]
    E --> F["Power BI: Netflix_Dataset.pbix<br/>Catalog overview + Title lookup"]
```

### Data model

All tables join on `show_id` (one title row to many rows in each long table).

```mermaid
erDiagram
    netflix_titles_clean ||--|| description : has
    netflix_titles_clean ||--o{ netflix_listed_in : "tagged with"
    netflix_titles_clean ||--o{ netflix_directors : "directed by"
    netflix_titles_clean ||--o{ countries_released : "released in"
    netflix_titles_clean ||--o{ netflix_cast : features
```

| Table | Grain | Key columns |
|-------|-------|-------------|
| `netflix_titles_clean` | One row per title | `show_id`, type, title, date added, release year, rating, duration, `Duration_type` |
| `netflix_listed_in` | Title × genre | `show_id`, `category` |
| `netflix_directors` | Title × director | `show_id`, director |
| `countries_released` | Title × country | `show_id`, country |
| `netflix_cast` | Title × cast member | `show_id`, cast member |
| `description` | One row per title | `show_id`, description |

### Key design decisions

- **Wide to long in SQL.** Multi-value fields arrive as numbered columns. `UNION` stacks them and removes duplicates; `WHERE ... IS NOT NULL` drops empty slots.
- **Audience = rating group.** The data has no viewer information, so ratings stand in for intended audience (Adult, Teen, Older kids/Family, All kids).

## 4. Project 2: Classic Models Sales Analysis

**Question:** Where do sales and profit come from, and when?

### Data flow

```mermaid
flowchart TD
    A["data/classicmodels_script.sql"] --> B["MySQL database classicmodels<br/>8 tables"]
    B --> C["sql/01<br/>2004 exploration join (sanity check)"]
    C --> D["sql/02<br/>view sales_data_for_power_bi<br/>one row per order line"]
    D --> E["Power BI: Classic_Models_Analysis.pbix<br/>Sales overview + Profit and trends"]
```

### Source schema and the view

The view joins six of the eight tables:

```mermaid
erDiagram
    orders ||--|{ orderdetails : contains
    products ||--o{ orderdetails : "appears in"
    customers ||--o{ orders : places
    employees ||--o{ customers : "is sales rep for"
    offices ||--o{ employees : employs
```

| Calculated field | Formula |
|------------------|---------|
| `sales_value` | `quantityOrdered * priceEach` |
| `cost_of_sales` | `quantityOrdered * buyPrice` |

Pulling the sales rep's office gives two geographic cuts: `customer_country` and `office_country`.

### Integrity check

22 of 122 customers have no sales rep, so the inner join to `employees` could drop rows. None of them placed orders, so the view total ($9,604,190.61) equals the raw order-line sum.

### Power BI layer

- **Page 1, Sales overview:** sales by product line, office and customer country; sales vs. cost per product; date and product slicers; a Sales / Net Profit toggle (bookmarks); KPI cards.
- **Page 2, Profit and trends:** decomposition tree (country → product line → customer); monthly table with month-over-month % and year-to-date.
- **DAX measures:** net profit, MoM %, YTD sales, average order value.

## 5. Conventions shared across projects

- **Folder layout:** `data/`, `sql/`, `outputs/`, plus a case-study `README.md`.
- **SQL scripts** are numbered in run order, with a header comment stating the purpose and, where relevant, the expected row counts.
- **Case-study README structure:** summary, business question, data, tools, method, dashboards, findings, recommendations, limitations, how to reproduce.
- **Figures are verified** against the source data before they go in a README.
- **Licensing:** the author's work is MIT; source datasets keep their own licenses and are linked from each project README.

## 6. Reproducing the environment

| Need | Version / note |
|------|----------------|
| MySQL | Any recent MySQL server (schema names: `netflix_data`, `classicmodels`) |
| Power BI Desktop | Free edition; opens the `.pbix` files |
| Excel | Only needed to redo Project 1 cleaning |

**Project 1:** start from `data/raw/netflix_titles.csv`, apply the cleaning steps, load `data/cleaned/` into `netflix_data`, run `sql/01-04`, then open the `.pbix` and point it at `data/cleaned/` if prompted.

**Project 2:** run `data/classicmodels_script.sql`, run `sql/02_create_sales_view_for_power_bi.sql`, then open the `.pbix` and point it at your MySQL server and the view.

## 7. Known limitations of the system

- **Not fully automated.** The Excel cleaning and Power BI steps are manual; only the SQL layer is scriptable.
- **Netflix wide tables are not in the repo as SQL.** The loading of the cleaned CSVs into MySQL is not scripted, so the `01-04` scripts assume the tables already exist (`listed in`, etc.).
- **`.pbix` files are binary** and do not diff in Git; screenshots in `outputs/` are the reviewable record.
- **Project 2 view includes all order statuses**, including cancelled orders (about 2.5% of sales).
- **Datasets are samples or catalogs**, so results illustrate technique rather than describe real businesses.
