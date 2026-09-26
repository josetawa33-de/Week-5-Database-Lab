# Week 5 Database Systems Lab

## Step 1

Created the `orders` table and populated it with 2,000,000 rows.

The table was analyzed using `ANALYZE orders`.

## Step 2

Used `EXPLAIN (ANALYZE, BUFFERS)` to analyze the query performance.

The initial execution time was 402.155 ms.

## Step 3

Created the partial index `idx_pending_recent` to improve query performance.

After creating the index, the execution time was 172.353 ms.

The query performance improved by approximately 57.1%.

## Step 4

Tested PostgreSQL transaction isolation levels.

### READ COMMITTED

The first session initially read 29.28.

After another session updated the value to 9999.00 and committed, the first session saw 9999.00 in the next statement.

### REPEATABLE READ

The first session initially read 9999.00.

Another session updated the value to 8888.00.

The first session continued to see 9999.00 because it was using the same transaction snapshot.

## Step 5

Installed and configured PgBouncer 1.26.0.

PgBouncer was configured to listen on port 6432.

The connection was successfully tested through:

`127.0.0.1:6432`

The database connection to `week4_database` was successful.

`SHOW POOLS;` confirmed that `week4_database` was using:

`transaction`

pooling mode.

## Results

- 2,000,000 rows created
- Initial query time: 402.155 ms
- Optimized query time: 172.353 ms
- Performance improvement: approximately 57.1%
- Partial index: `idx_pending_recent`
- READ COMMITTED tested
- REPEATABLE READ tested
- PgBouncer 1.26.0 configured
- PgBouncer transaction pooling verified