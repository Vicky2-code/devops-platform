import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { api } from '../api.js'

export default function Login() {
  const [mode, setMode] = useState('login')
  const [username, setUsername] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const navigate = useNavigate()

  useEffect(() => {
    if (localStorage.getItem('devflow_token')) navigate('/')
  }, [navigate])

  const submit = async (e) => {
    e.preventDefault()
    setError('')
    try {
      if (mode === 'login') {
        await api.login(username, password)
      } else {
        await api.register({ username, email, password })
        await api.login(username, password)
      }
      navigate('/')
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div className="login-wrap">
      <form className="card login-card" onSubmit={submit}>
        <h1>devflow</h1>
        <p className="muted">DevOps Automation Platform</p>

        {mode === 'register' && (
          <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Email" type="email" required />
        )}
        <input value={username} onChange={(e) => setUsername(e.target.value)} placeholder="Username" autoComplete="username" required />
        <input
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password (min 8 chars)"
          type="password"
          autoComplete="current-password"
          required
        />

        {error && <div className="error">{error}</div>}

        <button className="btn-primary" type="submit">
          {mode === 'login' ? 'Sign in' : 'Create account'}
        </button>

        <button
          type="button"
          className="link"
          onClick={() => setMode(mode === 'login' ? 'register' : 'login')}
        >
          {mode === 'login' ? 'Need an account? Register' : 'Have an account? Sign in'}
        </button>
      </form>
    </div>
  )
}