import React, { useEffect, useState } from 'react'
import { api } from '../api.js'

export default function Health() {
  const [health, setHealth] = useState(null)
  const [user, setUser] = useState(null)
  const [error, setError] = useState('')

  useEffect(() => {
    let alive = true
    const tick = () => {
      api
        .health()
        .then((h) => alive && setHealth(h))
        .catch(() => alive && setHealth({ status: 'down' }))
      api
        .me()
        .then((u) => alive && setUser(u))
        .catch(() => alive && setUser(null))
    }
    tick()
    const t = setInterval(tick, 5000)
    return () => {
      alive = false
      clearInterval(t)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div>
      <h1>Health</h1>
      <p className="muted">Backend, database and auth status.</p>
      {error && <div className="error">{error}</div>}

      <div className="stats">
        <div className={`stat ${health?.status === 'ok' ? 'green' : 'red'}`}>
          <div className="stat-value">{health?.status ?? '…'}</div>
          <div className="stat-label">Backend</div>
        </div>
        <div className={`stat ${health?.database === 'connected' ? 'green' : 'red'}`}>
          <div className="stat-value">{health?.database ?? '…'}</div>
          <div className="stat-label">Database</div>
        </div>
      </div>

      {health && (
        <div className="card">
          <h3>Details</h3>
          <table>
            <tbody>
              <tr>
                <td>App</td>
                <td className="mono">{health.app}</td>
              </tr>
              <tr>
                <td>Version</td>
                <td className="mono">{health.version}</td>
              </tr>
              <tr>
                <td>Environment</td>
                <td className="mono">{health.environment}</td>
              </tr>
              <tr>
                <td>Signed in as</td>
                <td className="mono">{user ? `${user.username} <${user.email}>` : '—'}</td>
              </tr>
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}