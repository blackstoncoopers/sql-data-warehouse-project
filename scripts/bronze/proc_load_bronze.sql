/*
===============================================================================
Config-driven Bronze Loader (PostgreSQL)
===============================================================================
What this does:
- Stores a single base path in bronze.etl_config (safe placeholder for Git)
- Procedure reads base path, truncates tables, and COPY loads CSVs using that path

How to run locally:
1) Set your local base path ONCE:
   INSERT INTO bronze.etl_config (config_key, config_value)
   VALUES ('data_base_path', '/your/folder/path/for/datasets')
   ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;

2) CALL bronze.load_bronze();

Git-friendly approach:
- Commit only a placeholder value (e.g. '/path/to/datasets') in any seed script,
  and keep your real path in a local-only script that is .gitignore’d.
===============================================================================
*/

-- 1) Config table (run once)
CREATE TABLE IF NOT EXISTS bronze.etl_config (
    config_key   text PRIMARY KEY,
    config_value text NOT NULL
);

-- Optional: seed with a safe placeholder (OK to commit)
INSERT INTO bronze.etl_config (config_key, config_value)
VALUES ('data_base_path', '/path/to/datasets')
ON CONFLICT (config_key) DO NOTHING;


CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $proc$
DECLARE
    base_path        text;
    batch_start_time timestamp;
    batch_end_time   timestamp;
    start_time       timestamp;
    end_time         timestamp;
    file_path        text;
    sql_cmd          text;
BEGIN
    SELECT config_value
      INTO base_path
      FROM bronze.etl_config
     WHERE config_key = 'data_base_path';

    IF base_path IS NULL OR length(trim(base_path)) = 0 THEN
        RAISE EXCEPTION
            'Missing ETL config: bronze.etl_config(config_key=''data_base_path''). Set it to your datasets folder.';
    END IF;

    base_path := regexp_replace(base_path, '/+$', '');
    batch_start_time := clock_timestamp();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE 'Base path: %', base_path;
    RAISE NOTICE '================================================';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    -- crm_cust_info
    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.crm_cust_info;

    file_path := base_path || '/source_crm/cust_info.csv';
    sql_cmd := format(
        'COPY bronze.crm_cust_info FROM %L WITH (FORMAT csv, HEADER true, DELIMITER '','')',
        file_path
    );
    RAISE NOTICE '>> %', sql_cmd;
    EXECUTE sql_cmd;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time))::int;

    -- crm_prd_info
    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.crm_prd_info;

    file_path := base_path || '/source_crm/prd_info.csv';
    sql_cmd := format(
        'COPY bronze.crm_prd_info FROM %L WITH (FORMAT csv, HEADER true, DELIMITER '','')',
        file_path
    );
    RAISE NOTICE '>> %', sql_cmd;
    EXECUTE sql_cmd;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time))::int;

    -- crm_sales_details
    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.crm_sales_details;

    file_path := base_path || '/source_crm/sales_details.csv';
    sql_cmd := format(
        'COPY bronze.crm_sales_details FROM %L WITH (FORMAT csv, HEADER true, DELIMITER '','')',
        file_path
    );
    RAISE NOTICE '>> %', sql_cmd;
    EXECUTE sql_cmd;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time))::int;

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    -- erp_loc_a101
    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.erp_loc_a101;

    file_path := base_path || '/source_erp/LOC_A101.csv';
    sql_cmd := format(
        'COPY bronze.erp_loc_a101 FROM %L WITH (FORMAT csv, HEADER true, DELIMITER '','')',
        file_path
    );
    RAISE NOTICE '>> %', sql_cmd;
    EXECUTE sql_cmd;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time))::int;

    -- erp_cust_az12
    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.erp_cust_az12;

    file_path := base_path || '/source_erp/CUST_AZ12.csv';
    sql_cmd := format(
        'COPY bronze.erp_cust_az12 FROM %L WITH (FORMAT csv, HEADER true, DELIMITER '','')',
        file_path
    );
    RAISE NOTICE '>> %', sql_cmd;
    EXECUTE sql_cmd;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time))::int;

    -- erp_px_cat_g1v2
    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    file_path := base_path || '/source_erp/PX_CAT_G1V2.csv';
    sql_cmd := format(
        'COPY bronze.erp_px_cat_g1v2 FROM %L WITH (FORMAT csv, HEADER true, DELIMITER '','')',
        file_path
    );
    RAISE NOTICE '>> %', sql_cmd;
    EXECUTE sql_cmd;

    end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time))::int;

    batch_end_time := clock_timestamp();
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE '   - Total Load Duration: % seconds', EXTRACT(EPOCH FROM (batch_end_time - batch_start_time))::int;
    RAISE NOTICE '==========================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '==========================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
        RAISE NOTICE '==========================================';
        RAISE;
END;
$proc$;
