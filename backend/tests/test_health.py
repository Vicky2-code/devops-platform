def test_health(client):
    resp = client.get("/api/health")
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "ok"
    assert body["database"] == "connected"


def test_root(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.json()["docs"] == "/docs"


def test_metrics_exposed(client):
    resp = client.get("/api/metrics")
    assert resp.status_code == 200
    assert b"http_requests_total" in resp.content
