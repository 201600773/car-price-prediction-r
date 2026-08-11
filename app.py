# =============================================================
# app.py - Flask API for Car Price Prediction
# =============================================================

from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import subprocess
import json
import os

app = Flask(__name__)
CORS(app)  # Allow cross-origin requests from your website

# =============================================================
# HOME ROUTE
# =============================================================

@app.route('/')
def home():
    return jsonify({
        'message': '🚗 Car Price Prediction API',
        'status': 'running',
        'endpoints': {
            '/predict': 'POST - Predict car price',
            '/health': 'GET - Check API health'
        }
    })

# =============================================================
# HEALTH CHECK
# =============================================================

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'model_exists': os.path.exists('outputs/models/random_forest_model.rds')
    })

# =============================================================
# PREDICTION ENDPOINT
# =============================================================

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # 1. Get data from request
        data = request.json
        
        # Validate required fields
        required_fields = ['present_price', 'year', 'kms_driven', 'owner', 
                          'fuel_type', 'seller_type', 'transmission']
        
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'success': False,
                    'error': f'Missing field: {field}'
                }), 400
        
        # 2. Prepare command for R script
        cmd = [
            'Rscript',
            'predict_price.R',
            str(data['present_price']),
            str(data['year']),
            str(data['kms_driven']),
            str(data['owner']),
            data['fuel_type'],
            data['seller_type'],
            data['transmission']
        ]
        
        # 3. Run R script
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30  # 30 second timeout
        )
        
        # 4. Check if R script ran successfully
        if result.returncode != 0:
            return jsonify({
                'success': False,
                'error': 'R script failed',
                'details': result.stderr
            }), 500
        
        # 5. Parse output - get the JSON line at the end
        output_lines = result.stdout.strip().split('\n')
        json_output = output_lines[-1]  # Last line is JSON
        
        try:
            prediction_data = json.loads(json_output)
        except json.JSONDecodeError:
            # If JSON parsing fails, try to extract the price
            import re
            price_match = re.search(r'₹([\d.]+)', result.stdout)
            if price_match:
                price = float(price_match.group(1))
                prediction_data = {'success': True, 'price': price}
            else:
                return jsonify({
                    'success': False,
                    'error': 'Could not parse prediction'
                }), 500
        
        # 6. Return prediction
        return jsonify({
            'success': True,
            'price': prediction_data['price'],
            'message': f'Predicted price: ₹{prediction_data["price"]} Lakhs'
        })
        
    except subprocess.TimeoutExpired:
        return jsonify({
            'success': False,
            'error': 'Prediction timed out'
        }), 504
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

# =============================================================
# RUN THE APP
# =============================================================

if __name__ == '__main__':
    # Get port from environment variable (for Render deployment)
    port = int(os.environ.get('PORT', 5000))
    
    app.run(
        debug=False,  # Set to True for local development
        host='0.0.0.0',
        port=port
    )
