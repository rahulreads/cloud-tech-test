import os
import time
import random
from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest
import logging

# Initialize Flask app
app = Flask(__name__)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("data_api")

# Prometheus metrics
REQUEST_COUNT = Counter(
    'data_api_requests_total', 
    'Total number of requests to the data API', 
    ['method', 'endpoint', 'http_status']
)
REQUEST_LATENCY = Histogram(
    'data_api_request_latency_seconds', 
    'Latency of data API requests in seconds', 
    ['method', 'endpoint']
)

# Configurable log directory (defaults to `/tmp/logs`)
LOG_DIRECTORY = os.getenv("LOG_DIRECTORY", "/tmp/logs")

# Helper Functions
def generate_log():
    """Generate a random log message."""
    logs = [
        "Processing request...",
        "Executing task...",
        "Preparing data...",
        "Performing operation..."
    ]
    return random.choice(logs)

def write_to_file(file_path, text):
    """Write a log message to a file."""
    with open(file_path, 'a') as file:
        file.write(text + '\n')

@app.route('/', methods=['GET'])
def process_api():
    """Handle the root API endpoint."""
    start_time = time.time()
    
    # Simulate processing delay
    time.sleep(3)
    
    # Generate a log message
    log_message = generate_log()
    logger.info(f"Generated log message: {log_message}")
    
    # Ensure the log directory exists
    if not os.path.exists(LOG_DIRECTORY):
        os.makedirs(LOG_DIRECTORY)
    
    # Write the log to a file
    file_name = f"log_{int(time.time())}.txt"
    file_path = os.path.join(LOG_DIRECTORY, file_name)

    try:
        write_to_file(file_path, log_message)
        logger.info(f"Log written to file: {file_path}")
    except IOError as e:
        logging.error(f"Failed to write log file: {e}")
    
    # Record Prometheus metrics
    REQUEST_COUNT.labels('GET', '/', 200).inc()
    REQUEST_LATENCY.labels('GET', '/').observe(time.time() - start_time)
    
    return jsonify({"message": "Log processed", "log": log_message}), 200

@app.route('/metrics', methods=['GET'])
def metrics():
    """Expose Prometheus metrics."""
    return generate_latest(), 200

@app.route('/health_check', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    # Run the app securely (disable debug mode in production)
    app.run(host='0.0.0.0', port=5000, debug=False)
