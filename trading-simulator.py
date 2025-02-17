from flask import Flask, jsonify
import random
import time
import threading
from prometheus_client import start_http_server, Counter, Gauge
import logging
from pythonjsonlogger import jsonlogger

# Initialize Flask app
app = Flask(__name__)

# Configure JSON logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Create a JSON formatter
formatter = jsonlogger.JsonFormatter(
    fmt="%(asctime)s %(levelname)s %(name)s %(message)s"
)

# Create a handler and set the formatter
handler = logging.StreamHandler()
handler.setFormatter(formatter)

# Add the handler to the logger
logger.addHandler(handler)

# Prometheus metrics
TRADES_TOTAL = Counter("trades_total", "Total number of trades")
TRADES_IN_PROGRESS = Gauge("trades_in_progress", "Number of trades in progress")

# In-memory storage for trading activity
trading_activity = []

# Generate random trading activity
def generate_trading_activity():
    while True:
        TRADES_IN_PROGRESS.inc()
        order = {
            "id": len(trading_activity) + 1,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "action": random.choice(["buy", "sell"]),
            "symbol": random.choice(["AAPL", "GOOGL", "AMZN", "MSFT", "TSLA"]),
            "quantity": random.randint(1, 100),
            "price": round(random.uniform(100, 500), 2)
        }
        trading_activity.append(order)
        TRADES_TOTAL.inc()
        TRADES_IN_PROGRESS.dec()

        # Log the trade
        logger.info("Trade executed", extra={"trade": order})

        time.sleep(random.uniform(0.5, 2))

# REST API Endpoints
@app.route("/trades", methods=["GET"])
def get_trades():
    logger.info("Fetching all trades")
    return jsonify(trading_activity)

@app.route("/health", methods=["GET"])
def health_check():
    logger.info("Health check endpoint called")
    return jsonify({"status": "healthy"})

if __name__ == "__main__":
    # Start Prometheus metrics server on port 8000
    start_http_server(8000)

    # Start trading activity generator
    threading.Thread(target=generate_trading_activity, daemon=True).start()

    # Run Flask app
    logger.info("Starting trading application")
    app.run(host="0.0.0.0", port=5000)