from app import app, load_sales

def test_sales_has_data():
    rows = load_sales()
    assert len(rows) > 0
    assert all(r["packs"] >= 0 for r in rows)

def test_api_returns_json():
    res = app.test_client().get("/api/sales")
    assert res.status_code == 200
    assert res.get_json()[0]["district"] == "Jaipur"

def test_health():
    assert app.test_client().get("/health").status_code == 200
