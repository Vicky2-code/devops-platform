import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../api.js'

export default function Projects() {
  const [projects, setProjects] = useState([])
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [error, setError] = useState('')

  const load = () => api.projects.list().then(setProjects).catch((e) => setError(e.message))

  useEffect(() => {
    load()
  }, [])

  const create = async (e) => {
    e.preventDefault()
    setError('')
    try {
      await api.projects.create({ name, description })
      setName('')
      setDescription('')
      load()
    } catch (err) {
      setError(err.message)
    }
  }

  const remove = async (id) => {
    if (!confirm('Delete this project?')) return
    await api.projects.remove(id)
    load()
  }

  return (
    <div>
      <h1>Projects</h1>
      <p className="muted">Create and manage your projects.</p>

      <form className="card row-form" onSubmit={create}>
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Project name" required />
        <input value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Description" />
        <button className="btn-primary" type="submit">
          Create
        </button>
      </form>
      {error && <div className="error">{error}</div>}

      <div className="card">
        {projects.length === 0 && <p className="muted">No projects yet.</p>}
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Description</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {projects.map((p) => (
              <tr key={p.id}>
                <td>
                  <Link to={`/projects/${p.id}`}>{p.name}</Link>
                </td>
                <td>{p.description}</td>
                <td>
                  <span className={`pill ${p.status}`}>{p.status}</span>
                </td>
                <td>
                  <button className="btn-danger" onClick={() => remove(p.id)} type="button">
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}