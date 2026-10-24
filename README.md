# SQL Learning Journey

Documenting my SQL learning as I build toward using it for data analysis, both in PostgreSQL and onchain data work on Dune Analytics.

Each week has its own folder with the dataset used, the queries I wrote, screenshots of results, and notes on what I learned and what tripped me up. The goal is to show the reasoning behind the SQL, not just collect working queries.

## Tools

- PostgreSQL for the traditional SQL side
- DBeaver for writing and running queries locally
- Dune Analytics for the onchain side, using public blockchain data and DuneSQL

## Progress

| Week | Topics | Status |
|---|---|---|
| 1 | Fundamentals: SELECT, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT, DDL/DML basics | ✅ Done |
| 2 | Filtering Data, SQL Joins (Basics and Advanced), Set Operators, String Functions, Numeric Functions, Date and Time Functions, NULL Functions, CASE, Aggregate Functions | ✅ [Done](./week-2-intermediate-sql) |
| 3 | Window Functions, Window Aggregates, Ranking and Value Functions, Subqueries, CTEs (standalone, multiple, nested and recursive) | ✅ [Done](./week-3) |
| 4 | Views, CTAS and Temp Tables, Advanced Technique Comparisons, Stored Procedures and Functions, Triggers | ✅ [Done](./week-4) |

## Why onchain too?

Onchain data is public, free to query on Dune, and a good way to apply the same SQL fundamentals to a different kind of dataset. It has its own quirks, such as raw token values, hex addresses, and very large tables that need date filtering.

## Structure

```text
sql-learning-journey/
├── .gitignore
│
├── week-1-fundamentals/
│   ├── README.md
│   ├── dataset/
│   │   └── init-mydatabase.sql
│   ├── queries.sql
│   ├── onchain-queries.sql
│   ├── ddl-dml-basics.sql
│   ├── notes.md
│   └── screenshots/
│       ├── postgres/
│       └── dune/
│
├── week-2-intermediate-sql/
│   ├── README.md
│   └── dataset/
│
├── week-3/
│   ├── README.md
│   └── dataset/
│
└── week-4/
    ├── README.md
    └── dataset/
```

## How to reproduce a week's dataset

Each week's dataset folder has a single SQL setup script that creates the database, tables, and sample data together. To run one:

1. Open the script in DBeaver against your PostgreSQL connection.
2. Run the CREATE DATABASE statements first.
3. Reconnect to the new database.
4. Run the rest of the script to create the tables and load the data.
