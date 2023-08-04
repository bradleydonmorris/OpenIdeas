SELECT
	pg_namespace.nspname AS "Schema",
	pg_class.relname AS "Table",
	pg_attribute.attname AS "Column"
	FROM pg_namespace
		INNER JOIN pg_class
			ON pg_namespace.oid = pg_class.relnamespace
		INNER JOIN pg_attribute
			ON pg_class.oid = pg_attribute.attrelid
	WHERE
		pg_namespace.nspname = @Schema
		AND pg_class.relname = @Table
		AND pg_attribute.attname = @Column
