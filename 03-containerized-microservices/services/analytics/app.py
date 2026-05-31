from flask import Flask, request, jsonify

app = Flask(__name__)

# In-memory storage acting as a temporary database mock
processed_records = []

@app.route("/analyze", methods=["POST"])
def analyze_data():
    """
    Processes incoming telemetry data, applies computational modifiers,
    and stores the structured result.
    """
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data payload provided"}), 400
    
    metric_value = data.get("value", 0)
    # Simple mathematical threshold classification
    alert_status = "high" if metric_value > 100 else "normal"
    
    analysis_result = {
        "payload": data,
        "insights": {
            "classification": alert_status,
            "calibrated_value": metric_value * 1.05 # Simulating a data calibration formula
        }
    }
    processed_records.append(analysis_result)
    print(f"[Analytics] Data processed successfully. Status: {alert_status}")
    
    return jsonify({
        "status": "processed",
        "results": analysis_result["insights"]
    }), 200

@app.route("/metrics", methods=["GET"])
def get_metrics():
    """
    Returns global aggregated analytical state.
    """
    return jsonify({
        "total_processed_items": len(processed_records),
        "historical_records": processed_records
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
