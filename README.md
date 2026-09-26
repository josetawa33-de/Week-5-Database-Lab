The `orders` table was created and populated with 2,000,000 records. After loading the data, `ANALYZE orders;` was used to update PostgreSQL statistics, and the row count was verified as 2,000,000.

Before creating an index, the query was analyzed using `EXPLAIN (ANALYZE, BUFFERS)`. PostgreSQL used a `Parallel Seq Scan on orders`, with two workers planned and launched. The query returned 53,581 matching rows and removed 648,806 rows during filtering. The execution time was 503.992 ms. The plan recorded 14,338 shared buffer hits and 2,329 shared buffer reads. The aggregation used five batches and 696 kB of temporary disk space.

A partial composite index named `idx_pending_recent` was then created on `created_at DESC, customer_id` for rows where `status = 'pending'`. After running `ANALYZE orders;`, the same query was executed again.

The second execution used a `Bitmap Index Scan` on `idx_pending_recent`, followed by a `Bitmap Heap Scan`. The query again returned 53,581 rows, but execution time decreased to 234.152 ms. This represents a reduction of 269.840 ms, or approximately 53.5%.

The execution-plan transition was:

Before the index:

`Parallel Seq Scan → HashAggregate → Sort → Limit`

After the index:

`Bitmap Index Scan → Bitmap Heap Scan → HashAggregate → Sort → Limit`

The raw buffer information also showed 12,841 shared buffer hits and 3,354 shared buffer reads after indexing. Although the buffer-read counts varied between the two runs, the important evidence was the change in scan strategy and the reduction in total execution time.

For transaction isolation, two PostgreSQL sessions were used. Under `READ COMMITTED`, a second transaction updated the amount for `id = 1` to 9999. The first transaction's subsequent `SELECT` saw the new committed value. This demonstrated statement-level snapshot behavior.

A second test used `REPEATABLE READ`. The first transaction initially saw 9999. After another session changed the value to 8888, the first transaction continued to see 9999 until its transaction ended. This demonstrated that `REPEATABLE READ` maintains a consistent transaction snapshot.

PgBouncer was configured to listen on `127.0.0.1:6432` and connect to PostgreSQL on port 5432. The pooling mode was configured as `transaction`. A connection through PgBouncer successfully reached the `week4_database` database, and `SELECT current_database(), current_user;` confirmed the connection.

Finally, `SHOW POOLS;` was used to verify the PgBouncer configuration. The `week4_database` pool showed `transaction` as its pool mode, confirming that transaction pooling was successfully configured and working.
