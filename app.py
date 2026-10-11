import csv
from flask import Flask, jsonify, send_from_directory

app = Flask(__name__, static_folder="static")

def load_sales(path="data/sales.csv"):
    with open(path) as f:
        return [{"district": r["district"], "packs": int(r["packs_thousand"])}
                for r in csv.DictReader(f)]

@app.route("/")
def home():
    return send_from_directory("static", "index.html")

@app.route("/api/sales")
def sales():
    return jsonify(load_sales())

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
