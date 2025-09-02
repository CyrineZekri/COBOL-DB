-- This is a "bulletproof" bootstrap script.
-- It forcefully drops existing tables to ensure a clean slate.
DROP TABLE IF EXISTS tx_log;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers CASCADE; -- CASCADE ensures all dependent objects are removed

-- Create the tables with the correct schema
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    balance DECIMAL(10, 2) NOT NULL CHECK (balance >= 0)
);

CREATE TABLE tx_log (
    log_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL REFERENCES accounts(account_id),
    tx_type VARCHAR(10) NOT NULL, -- 'DEPOSIT' or 'WITHDRAW'
    amount DECIMAL(10, 2) NOT NULL,
    tx_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert the initial sample data
INSERT INTO customers (customer_id, name) VALUES
(101, 'John Doe'),
(102, 'Jane Smith');

INSERT INTO accounts (account_id, customer_id, balance) VALUES
(9001, 101, 1500.75),
(9002, 102, 3250.00);

-- Grant all necessary permissions to the student user
GRANT ALL ON customers, accounts, tx_log TO postgres;
GRANT USAGE, SELECT ON SEQUENCE tx_log_log_id_seq TO postgres;