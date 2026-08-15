def test_create_environment(client, auth_headers, project):
    resp = client.post(
        f"/api/projects/{project['id']}/environments",
        json={"name": "production", "region": "us-east-1"},
        headers=auth_headers,
    )
    assert resp.status_code == 201
    assert resp.json()["name"] == "production"
    assert resp.json()["status"] == "provisioned"


def test_list_environments(client, auth_headers, project):
    for name in ("dev", "staging"):
        client.post(
            f"/api/projects/{project['id']}/environments", json={"name": name}, headers=auth_headers
        )
    resp = client.get(f"/api/projects/{project['id']}/environments", headers=auth_headers)
    assert resp.status_code == 200
    assert {e["name"] for e in resp.json()} == {"dev", "staging"}
