-- =========================================================
-- Week 1: SQL Fundamentals — onchain SQL (Dune, DuneSQL)
-- Same fundamentals, applied to Ethereum data.
-- Note: Dune is query-only — no DDL/DML here, since these are
-- shared public tables, not a database I own.
-- =========================================================

-- 1. See what a raw transaction row looks like.
SELECT *
FROM ethereum.transactions
LIMIT 3;

-- 2. Only the columns that matter, converting wei to ETH.
SELECT block_time, "from", "to", value / 1e18 AS eth_amount
FROM ethereum.transactions
LIMIT 5;

-- 3. Large transfers in the last 24 hours only.
SELECT block_time, "from", "to", value / 1e18 AS eth_amount
FROM ethereum.transactions
WHERE block_date >= CURRENT_DATE - INTERVAL '1' DAY
  AND value / 1e18 > 100
ORDER BY eth_amount DESC
LIMIT 20;

-- 4. How many unique wallets sent a transaction in the last 7 days?
SELECT COUNT(DISTINCT "from") AS unique_senders
FROM ethereum.transactions
WHERE block_date >= CURRENT_DATE - INTERVAL '7' DAY;

-- 5. How has daily transaction volume trended over the last 30 days?
SELECT block_date, COUNT(*) AS tx_count
FROM ethereum.transactions
WHERE block_date >= CURRENT_DATE - INTERVAL '30' DAY
GROUP BY block_date
ORDER BY block_date;

-- 6. Which wallets are unusually active — more than 100 transactions
-- in the last week? The most complex query this week.
SELECT "from", COUNT(*) AS tx_count
FROM ethereum.transactions
WHERE block_date >= CURRENT_DATE - INTERVAL '7' DAY
GROUP BY "from"
HAVING COUNT(*) > 100
ORDER BY tx_count DESC
LIMIT 10;
