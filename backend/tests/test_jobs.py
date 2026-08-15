def test_create_scan_job(client, auth_headers):
    resp = client.post(
        "/api/jobs",
        json={"name": "nightly-scan", "kind": "scan", "parameters": {"images": ["demo:1.0"]}},
        headers=auth_headers,
    )
    assert resp.status_code == 201
    body = resp.json()
    assert body["kind"] == "scan"
    assert body["status"] in ("queued", "running", "success")
    assert body["parameters"]["images"] == ["demo:1.0"]


def test_invalid_job_kind(client, auth_headers):
    resp = client.post(
        "/api/jobs", json={"name": "bad", "kind": "explode"}, headers=auth_headers
    )
    assert resp.status_code == 422


def test_job_reaches_success(client, auth_headers):
    import time

    created = client.post(
        "/api/jobs", json={"name": "unit", "kind": "test"}, headers=auth_headers
    ).json()
    for _ in range(20):
        time.sleep(0.5)
        job = client.get(f"/api/jobs/{created['id']}", headers=auth_headers).json()
        if job["status"] in ("success", "failed"):
            break
    assert job["status"] in ("success", "failed")
    assert job["logs"]
