import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../api.js'

function StatCard({ label, value, tone }) {
  return (
    <div className={`stat ${tone || ''}`}>
      <div className="stat-value">{value}</div>
      <div className="stat-label">{label}</div>
    </div>
  )
}

export default function Dashboard() {
  const [projects, setProjects] = useState([])
  const [jobs, setJobs] = useState([])
  const [health, setHealth] = useState(null)

  useEffect(() => {
    Promise.allSettled([api.projects.list(), api.jobs.list(), api.health()]).then(([p, j, h]) => {
      if (p.status === 'fulfilled') setProjects(p.value)
      if (j.status === 'fulfilled') setJobs(j.value)
      if (h.status === 'fulfilled') setHealth(h.value)
    })
  }, [])

  const running = jobs.filter((j) => j.status === 'running').length
  const succeeded = jobs.filter((j) => j.status === 'success').length

  return (
    <div>
      <h1>Dashboard</h1>
      <p className="muted">Overview of your automation platform.</p>

      <div className="stats">
        <StatCard label="Projects" value={projects.length} tone="blue" />
        <StatCard label="Jobs running" value={running} tone="green" />
        <StatCard label="Jobs succeeded" value={succeeded} tone="teal" />
        <StatCard
          label="Backend"
          value={health?.status === 'ok' ? 'healthy' : 'unreachable'}
          tone={health?.status === 'ok' ? 'green' : 'red'}
        />
      </div>

      <div className="grid2">
        <div className="card">
          <h3>Recent projects</h3>
          {projects.length === 0 && <p className="muted">No projects yet. Create one.</p>}
          <ul>
            {projects.slice(0, 5).map((p) => (
              <li key={p.id}>
                <Link to={`/projects/${p.id}`}>{p.name}</Link>
                <span className={`pill ${p.status}`}>{p.status}</span>
              </li>
            ))}
          </ul>
        </div>

        <div className="card">
          <h3>Recent jobs</h3>
          {jobs.length === 0 && <p className="muted">No automation jobs yet.</p>}
          <ul>
            {jobs.slice(0, 5).map((j) => (
              <li key={j.id}>
                <span className="job-name">{j.name}</span>
                <span className={`pill ${j.status}`}>{j.status}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  )
}