import React, { useEffect, useState } from 'react'
import { api } from '../api.js'

export default function Jobs() {
  const [jobs, setJobs] = useState([])
  const [name, setName] = useState('')
  const [kind, setKind] = useState('deploy')

  const load = () => api.jobs.list().then(setJobs)

  useEffect(() => {
    load()
    const t = setInterval(load, 4000)
    return () => clearInterval(t)
  }, [])

  const create = async (e) => {
    e.preventDefault()
    await api.jobs.create({ name, kind, parameters: {} })
    setName('')
    load()
  }

  return (
    <div>
      <h1>Automation Jobs</h1>
      <p className="muted">Run deploy, test and security-scan jobs.</p>

      <form className="card row-form" onSubmit={create}>
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="job name" required />
        <select value={kind} onChange={(e) => setKind(e.target.value)}>
          <option value="deploy">deploy</option>
          <option value="test">test</option>
          <option value="scan">scan</option>
        </select>
        <button className="btn-primary" type="submit">
          Trigger job
        </button>
      </form>

      <div className="card">
        {jobs.length === 0 && <p className="muted">No jobs yet.</p>}
        {jobs.slice(0, 20).map((j) => (
          <div className="job-row" key={j.id}>
            <div>
              <strong>{j.name}</strong>
              <span className="muted"> · {j.kind}</span>
            </div>
            <span className={`pill ${j.status}`}>{j.status}</span>
          </div>
        ))}
      </div>

      <div className="card">
        <h3>Job logs (latest)</h3>
        <pre className="logs">{jobs[0]?.logs || 'No logs yet'}</pre>
      </div>
    </div>
  )
}