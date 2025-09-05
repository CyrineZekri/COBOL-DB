CREATE OR REPLACE PROCEDURE LOG_TRANSACTION(
    p_account_id INT,
    p_amount DECIMAL(10, 2),
    p_tx_type VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tx_log (account_id, amount, tx_type)
    VALUES (p_account_id, p_amount, p_tx_type);
END;
$$;
GRANT EXECUTE ON PROCEDURE LOG_TRANSACTION(INT, DECIMAL, VARCHAR) TO postgres;
