import React, { useEffect, useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { api } from '../api.js'

export default function ProjectDetail() {
  const { id } = useParams()
  const [project, setProject] = useState(null)
  const [envs, setEnvs] = useState([])
  const [deploys, setDeploys] = useState([])
  const [envName, setEnvName] = useState('dev')
  const [commit, setCommit] = useState('HEAD')
  const [error, setError] = useState('')

  const load = () => {
    api.projects.get(id).then(setProject)
    api.environments.list(id).then(setEnvs)
    api.deployments.list(id).then(setDeploys)
  }

  useEffect(() => {
    load()
    const t = setInterval(load, 4000)
    return () => clearInterval(t)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id])

  const addEnv = async (e) => {
    e.preventDefault()
    await api.environments.create(id, { name: envName })
    setEnvName('dev')
    load()
  }

  const deploy = async (e) => {
    e.preventDefault()
    setError('')
    try {
      await api.deployments.create(id, { commit_sha: commit, triggered_by: 'dashboard' })
      setCommit('HEAD')
      load()
    } catch (err) {
      setError(err.message)
    }
  }

  if (!project) return <p>Loading…</p>

  return (
    <div>
      <Link to="/projects" className="link">
        ← Projects
      </Link>
      <h1>{project.name}</h1>
      <p className="muted">{project.description || 'No description'}</p>

      <div className="grid2">
        <div className="card">
          <h3>Environments</h3>
          <form className="row-form" onSubmit={addEnv}>
            <input value={envName} onChange={(e) => setEnvName(e.target.value)} placeholder="dev" />
            <button className="btn-primary" type="submit">
              Add
            </button>
          </form>
          <ul>
            {envs.map((e) => (
              <li key={e.id}>
                <strong>{e.name}</strong> <span className="muted">({e.region})</span>
                <span className={`pill ${e.status}`}>{e.status}</span>
              </li>
            ))}
            {envs.length === 0 && <p className="muted">No environments.</p>}
          </ul>
        </div>

        <div className="card">
          <h3>New deployment</h3>
          <form className="row-form" onSubmit={deploy}>
            <input value={commit} onChange={(e) => setCommit(e.target.value)} placeholder="commit sha" />
            <button className="btn-primary" type="submit">
              Deploy
            </button>
          </form>
          {error && <div className="error">{error}</div>}
        </div>
      </div>

      <div className="card">
        <h3>Deployments</h3>
        {deploys.length === 0 && <p className="muted">No deployments yet.</p>}
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Commit</th>
              <th>Image</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {deploys.map((d) => (
              <tr key={d.id}>
                <td>{d.id}</td>
                <td className="mono">{d.commit_sha}</td>
                <td className="mono">{d.image || '—'}</td>
                <td>
                  <span className={`pill ${d.status}`}>{d.status}</span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="card">
        <h3>Logs (latest deployment)</h3>
        <pre className="logs">{deploys[0]?.logs || 'No logs yet'}</pre>
      </div>
    </div>
  )
}