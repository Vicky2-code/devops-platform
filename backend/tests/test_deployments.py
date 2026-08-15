def test_create_deployment(client, auth_headers, project):
    resp = client.post(
        f"/api/projects/{project['id']}/deployments",
        json={"commit_sha": "abc123", "image": "demo:1.0"},
        headers=auth_headers,
    )
    assert resp.status_code == 201
    assert resp.json()["status"] in ("queued", "running")


def test_deployment_pipeline_completes(client, auth_headers, project):
    created = client.post(
        f"/api/projects/{project['id']}/deployments",
        json={"commit_sha": "deadbeef"},
        headers=auth_headers,
    ).json()

    # wait for the background pipeline thread (7 stages ≈ 7s)
    import time

    for _ in range(21):
        time.sleep(0.5)
        resp = client.get(
            f"/api/projects/{project['id']}/deployments/{created['id']}", headers=auth_headers
        )
        if resp.json()["status"] in ("success", "failed"):
            break

    body = resp.json()
    assert body["status"] in ("success", "failed")
    assert "healthcheck" in body["logs"] or "security scan" in body["logs"]


def test_deployment_rejects_foreign_environment(client, auth_headers, project):
    client.post(
        "/api/auth/register",
        json={"username": "mallory", "email": "mallory@example.com", "password": "longenoughpw"},
    )
    other_login = client.post("/api/auth/login", data={"username": "mallory", "password": "longenoughpw"})
    other_headers = {"Authorization": f"Bearer {other_login.json()['access_token']}"}
    other_project = client.post(
        "/api/projects", json={"name": "other"}, headers=other_headers
    ).json()
    foreign_env = client.post(
        f"/api/projects/{other_project['id']}/environments", json={"name": "prod"}, headers=other_headers
    ).json()

    resp = client.post(
        f"/api/projects/{project['id']}/deployments",
        json={"environment_id": foreign_env["id"]},
        headers=auth_headers,
    )
    assert resp.status_code == 422
