def test_register_success(client):
    resp = client.post(
        "/api/auth/register",
        json={"username": "alice", "email": "alice@example.com", "password": "longenoughpw"},
    )
    assert resp.status_code == 201
    assert "access_token" in resp.json()


def test_register_duplicate_email(client, auth_headers):
    # 'tester' already exists from fixture
    resp = client.post(
        "/api/auth/register",
        json={"username": "tester2", "email": "tester@example.com", "password": "longenoughpw"},
    )
    assert resp.status_code == 409


def test_register_short_password(client):
    resp = client.post(
        "/api/auth/register",
        json={"username": "bob", "email": "bob@example.com", "password": "short"},
    )
    assert resp.status_code == 422


def test_login_wrong_password(client):
    resp = client.post("/api/auth/login", data={"username": "tester", "password": "wrong"})
    assert resp.status_code == 401


def test_login_ok(client, auth_headers):
    # auth_headers fixture itself performed a successful login
    assert auth_headers["Authorization"].startswith("Bearer ")


def test_me_requires_token(client):
    assert client.get("/api/users/me").status_code == 401


def test_me_returns_user(client, auth_headers):
    resp = client.get("/api/users/me", headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["username"] == "tester"
