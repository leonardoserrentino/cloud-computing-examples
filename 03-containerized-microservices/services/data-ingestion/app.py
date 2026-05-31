import os
import requests
from flask import Flask, request, jsonify

app = Flask(__name__)

# Fetch the downstream service URL from environment variables (Service Discovery)
ANALYTICS_SERVICE_URL = os.getenv("ANALYTICS_SERVICE_URL", "http://analytics:5001/analyze")

@app.route("/ingest", methods=["POST"])
def ingest_data():
    """
    Accepts incoming JSON payloads from clients and forwards them 
    to the downstream Analytics microservice.
    """
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid payload, JSON required"}), 400
    
    print(f"[Ingestion] Received data stream: {data}")
    
    # Forward the payload to the Analytics service via REST API
    try:
        response = requests.post(ANALYTICS_SERVICE_URL, json=data, timeout=5)
        response.raise_for_status()
        return jsonify({
            "status": "success",
            "message": "Data ingested and successfully forwarded downstream",
            "analytics_response": response.json()
        }), 200
    except requests.exceptions.RequestException as e:
        print(f"[Ingestion] Error communicating with analytics service: {str(e)}")
        return jsonify({
            "status": "partial_success",
            "message": "Data received but downstream analytics service is unreachable",
            "error": str(e)
        }), 502

if __name__ == "__main__":
    # Ensure the app binds to all interfaces inside the container
    app.run(host="0.0.0.0", port=5000)
