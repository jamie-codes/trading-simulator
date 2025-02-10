from flask import Flask, jsonify
import random
import time
import threading

app = Flask(__name__)

# In-memory storage for trading activity
trading_activity = []

# Generate random trading activity
def generate_trading_activity():
    while True:
        order = {
            "id": len(trading_activity) + 1,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "action": random.choice(["buy", "sell"]),
            "symbol": random.choice(["AAPL", "GOOGL", "AMZN", "MSFT", "TSLA"]),
            "quantity": random.randint(1, 100),
            "price": round(random.uniform(100, 500), 2)
        }
        trading_activity.append(order)
        time.sleep(random.uniform(0.5, 2))  # Simulate random delays between trades

# REST API Endpoints
@app.route("/trades", methods=["GET"])
def get_trades():
    return jsonify(trading_activity)

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "healthy"})

if __name__ == "__main__":
    # Start a background thread to generate trading activity
    threading.Thread(target=generate_trading_activity, daemon=True).start()
    
    # Run the Flask app
    app.run(host="0.0.0.0", port=5000)