import React from 'react'
import { Navigate, Route, Routes, Link, useNavigate } from 'react-router-dom'
import { api, getToken, clearToken } from './api.js'
import Login from './pages/Login.jsx'
import Dashboard from './pages/Dashboard.jsx'
import Projects from './pages/Projects.jsx'
import ProjectDetail from './pages/ProjectDetail.jsx'
import Jobs from './pages/Jobs.jsx'
import Health from './pages/Health.jsx'

function PrivateRoute({ children }) {
  return getToken() ? children : <Navigate to="/login" replace />
}

function Layout() {
  const navigate = useNavigate()
  const logout = () => {
    clearToken()
    navigate('/login')
  }
  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="brand">devflow</div>
        <nav>
          <Link to="/">Dashboard</Link>
          <Link to="/projects">Projects</Link>
          <Link to="/jobs">Automation Jobs</Link>
          <Link to="/health">Health</Link>
        </nav>
        <button className="btn-outline logout" onClick={logout}>
          Logout
        </button>
      </aside>
      <main className="content">{children}</main>
    </div>
  )
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        path="/"
        element={
          <PrivateRoute>
            <Layout>
              <Dashboard />
            </Layout>
          </PrivateRoute>
        }
      />
      <Route
        path="/projects"
        element={
          <PrivateRoute>
            <Layout>
              <Projects />
            </Layout>
          </PrivateRoute>
        }
      />
      <Route
        path="/projects/:id"
        element={
          <PrivateRoute>
            <Layout>
              <ProjectDetail />
            </Layout>
          </PrivateRoute>
        }
      />
      <Route
        path="/jobs"
        element={
          <PrivateRoute>
            <Layout>
              <Jobs />
            </Layout>
          </PrivateRoute>
        }
      />
      <Route
        path="/health"
        element={
          <PrivateRoute>
            <Layout>
              <Health />
            </Layout>
          </PrivateRoute>
        }
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}