import os
import random
import time
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest
import logging

# Initialize Flask app
app = Flask(__name__)

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("backend_service")

# Prometheus metrics
REQUEST_COUNT = Counter(
    'backend_service_requests_total', 
    'Total number of requests', 
    ['method', 'endpoint', 'http_status']
)
REQUEST_LATENCY = Histogram(
    'backend_service_request_latency_seconds', 
    'Latency of requests in seconds', 
    ['method', 'endpoint']
)

# Environment variables
EXTERNAL_INTEGRATION_KEY = os.getenv("EXTERNAL_INTEGRATION_KEY", "default_key")

# Helper function to simulate external API interaction
def call_external_api():
    # Dummy external API URL
    url = "https://dummy-external-api.com/logs"
    headers = {"Authorization": f"Bearer {EXTERNAL_INTEGRATION_KEY}"}
    logger.info("Calling external API")
    try:
        # Simulate a request (this is a dummy and can be left empty)
        response = {"status": "success", "data": "External logs"}
        return response, 200
    except Exception as e:
        logger.error(f"Error calling external API: {e}")
        return {"error": str(e)}, 500

@app.route('/download_external_logs', methods=['GET'])
def download_external_logs():
    start_time = time.time()
    response, status_code = call_external_api()

    # Record metrics
    REQUEST_COUNT.labels('GET', '/download_external_logs', status_code).inc()
    REQUEST_LATENCY.labels('GET', '/download_external_logs').observe(time.time() - start_time)

    return jsonify(response), status_code

@app.route('/metrics', methods=['GET'])
def metrics():
    return generate_latest(), 200

@app.route('/health_check', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
