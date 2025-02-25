CREATE TABLE trades (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    action TEXT NOT NULL,
    symbol TEXT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL NOT NULL
);