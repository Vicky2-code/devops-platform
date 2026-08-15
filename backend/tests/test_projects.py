def test_list_projects_empty(client, auth_headers):
    resp = client.get("/api/projects", headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json() == []


def test_create_project(client, auth_headers):
    resp = client.post(
        "/api/projects", json={"name": "web-app", "description": "main app"}, headers=auth_headers
    )
    assert resp.status_code == 201
    body = resp.json()
    assert body["name"] == "web-app"
    assert body["status"] == "active"


def test_create_project_requires_auth(client):
    resp = client.post("/api/projects", json={"name": "x"})
    assert resp.status_code == 401


def test_update_project(client, auth_headers, project):
    resp = client.patch(
        f"/api/projects/{project['id']}", json={"description": "updated"}, headers=auth_headers
    )
    assert resp.status_code == 200
    assert resp.json()["description"] == "updated"


def test_delete_project(client, auth_headers, project):
    resp = client.delete(f"/api/projects/{project['id']}", headers=auth_headers)
    assert resp.status_code == 204
    assert client.get(f"/api/projects/{project['id']}", headers=auth_headers).status_code == 404


def test_cannot_see_other_users_projects(client, auth_headers, project):
    # second user cannot read the first user's project
    client.post(
        "/api/auth/register",
        json={"username": "eve", "email": "eve@example.com", "password": "longenoughpw"},
    )
    login = client.post("/api/auth/login", data={"username": "eve", "password": "longenoughpw"})
    other_headers = {"Authorization": f"Bearer {login.json()['access_token']}"}
    resp = client.get(f"/api/projects/{project['id']}", headers=other_headers)
    assert resp.status_code == 404
