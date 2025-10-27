CREATE OR REPLACE PROCEDURE log_transaction(
  p_account_id BIGINT,
  p_tx_type    TEXT,
  p_amount     NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO tx_log(account_id, tx_type, amount, tx_timestamp)
  VALUES (p_account_id, p_tx_type, p_amount, NOW());
END;
$$;
