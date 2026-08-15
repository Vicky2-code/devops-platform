const BASE = import.meta.env.VITE_API_URL || 'http://localhost:8000'

export function getToken() {
  return localStorage.getItem('devflow_token')
}

export function setToken(token) {
  localStorage.setItem('devflow_token', token)
}

export function clearToken() {
  localStorage.removeItem('devflow_token')
}

async function request(path, options = {}) {
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) }
  const token = getToken()
  if (token) headers.Authorization = `Bearer ${token}`

  const resp = await fetch(`${BASE}${path}`, { ...options, headers })

  if (resp.status === 401) {
    clearToken()
    window.location.href = '/login'
    throw new Error('Unauthorized')
  }

  if (!resp.ok) {
    let detail = resp.statusText
    try {
      const body = await resp.json()
      if (body.detail) detail = typeof body.detail === 'string' ? body.detail : JSON.stringify(body.detail)
    } catch {
      /* no json body */
    }
    throw new Error(detail)
  }

  if (resp.status === 204) return null
  return resp.json()
}

export const api = {
  register: (body) => request('/api/auth/register', { method: 'POST', body: JSON.stringify(body) }),
  login: async (username, password) => {
    const form = new URLSearchParams()
    form.append('username', username)
    form.append('password', password)
    const resp = await fetch(`${BASE}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: form,
    })
    if (!resp.ok) throw new Error('Invalid credentials')
    const data = await resp.json()
    setToken(data.access_token)
    return data
  },
  me: () => request('/api/users/me'),
  health: () => fetch(`${BASE}/api/health`).then((r) => r.json()),

  projects: {
    list: () => request('/api/projects'),
    create: (body) => request('/api/projects', { method: 'POST', body: JSON.stringify(body) }),
    get: (id) => request(`/api/projects/${id}`),
    remove: (id) => request(`/api/projects/${id}`, { method: 'DELETE' }),
  },
  environments: {
    list: (projectId) => request(`/api/projects/${projectId}/environments`),
    create: (projectId, body) =>
      request(`/api/projects/${projectId}/environments`, { method: 'POST', body: JSON.stringify(body) }),
  },
  deployments: {
    list: (projectId) => request(`/api/projects/${projectId}/deployments`),
    create: (projectId, body) =>
      request(`/api/projects/${projectId}/deployments`, { method: 'POST', body: JSON.stringify(body) }),
    get: (projectId, id) => request(`/api/projects/${projectId}/deployments/${id}`),
  },
  jobs: {
    list: () => request('/api/jobs'),
    create: (body) => request('/api/jobs', { method: 'POST', body: JSON.stringify(body) }),
    get: (id) => request(`/api/jobs/${id}`),
  },
}