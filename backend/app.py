from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/')
def home():
    return jsonify({"message": "Welcome to Flask API"})

@app.route('/api/data')
def get_data():
    return jsonify({
        "status": "success",
        "data": [
            {"id": 1, "name": "Item 1", "description": "First item"},
            {"id": 2, "name": "Item 2", "description": "Second item"},
            {"id": 3, "name": "Item 3", "description": "Third item"}
        ]
    })

@app.route('/api/message/<name>')
def get_message(name):
    return jsonify({
        "status": "success",
        "message": f"Hello, {name}!"
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
