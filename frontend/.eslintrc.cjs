module.exports = {
  env: {
    browser: true,
    es2022: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    ecmaFeatures: { jsx: true },
  },
  plugins: ['react', 'react-hooks'],
  extends: [],
  rules: {
    'react/react-in-jsx-scope': 'off',
    'react-hooks/exhaustive-deps': 'warn',
    // ESLint's no-unused-vars doesn't track JSX variable usage; we rely on
    // 'react/jsx-uses-vars' to keep components/vars referenced in JSX "used".
    'react/jsx-uses-vars': 'error',
    'react/jsx-uses-react': 'off',
    'no-unused-vars': ['warn', { argsIgnorePattern: '^_', varsIgnorePattern: '^React$' }],
  },
  settings: {
    react: { version: 'detect' },
  },
}