from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def root():
    return jsonify({
        'message': 'Casa da Ana Contracts API - Debug Mode',
        'status': 'running',
        'port': os.getenv('PORT', '5000'),
        'host': '0.0.0.0'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'Casa da Ana Debug',
        'version': '2.0.1-debug'
    })

@app.route('/test')
def test():
    return jsonify({
        'message': 'Test endpoint working!',
        'environment': {
            'PORT': os.getenv('PORT'),
            'EVOLUTION_API_URL': 'configured' if os.getenv('EVOLUTION_API_URL') else 'missing',
            'EVOLUTION_API_KEY': 'configured' if os.getenv('EVOLUTION_API_KEY') else 'missing',
            'PHONE_NUMBER': 'configured' if os.getenv('PHONE_NUMBER') else 'missing'
        }
    })

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    print(f"🚀 Starting debug server on 0.0.0.0:{port}")
    app.run(host='0.0.0.0', port=port, debug=True) 