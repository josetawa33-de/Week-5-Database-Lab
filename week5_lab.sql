CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT,
    amount NUMERIC(10,2),
    status TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO orders (customer_id, amount, status, created_at)
SELECT
    (random() * 50000)::int,
    (random() * 500)::numeric(10,2),
    (ARRAY['pending','shipped','delivered'])[ceil(random()*3)],
    now() - (random()*365)::int * interval '1 day'
FROM generate_series(1, 2000000);

ANALYZE orders;

SELECT COUNT(*) FROM orders;

EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, SUM(amount)
FROM orders
WHERE status = 'pending'
  AND created_at > now() - interval '30 days'
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 10;

CREATE INDEX idx_pending_recent
ON orders (created_at DESC, customer_id)
WHERE status = 'pending';

ANALYZE orders;

EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, SUM(amount)
FROM orders
WHERE status = 'pending'
  AND created_at > now() - interval '30 days'
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 10;

BEGIN;

SELECT amount
FROM orders
WHERE id = 1;

UPDATE orders
SET amount = 9999
WHERE id = 1;

SELECT amount
FROM orders
WHERE id = 1;

COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT amount
FROM orders
WHERE id = 1;

UPDATE orders
SET amount = 8888
WHERE id = 1;

SELECT amount
FROM orders
WHERE id = 1;

COMMIT;

SELECT current_database(), current_user;

SHOW POOLS;