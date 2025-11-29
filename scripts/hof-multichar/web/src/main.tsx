import React from 'react'
import ReactDOM from 'react-dom/client'
import './index.css'
import '@mantine/core/styles.css';
import '@mantine/dates/styles.css';
import App from './App'
import { MantineProvider, createTheme } from '@mantine/core';
import { ModalsProvider } from '@mantine/modals';

const theme = createTheme({
  colors: {
    dark: [
      '#9ca3af', // text-dimmed
      '#ffffff', // text-primary
      '#2c2e33', // surface-bg
      '#25262b', // secondary-bg
      '#1a1b1e', // primary-bg
      '#1a1b1e',
      '#1a1b1e',
      '#1a1b1e',
      '#1a1b1e',
      '#1a1b1e',
    ],
    blue: [
      '#e3f2fd',
      '#bbdefb',
      '#90caf9',
      '#64b5f6',
      '#42a5f5',
      '#228be6', // blue-primary
      '#1e88e5',
      '#1976d2',
      '#1565c0',
      '#0d47a1',
    ],
  },
  primaryColor: 'blue',
  fontFamily: 'Inter, system-ui, -apple-system, sans-serif',
  headings: {
    fontFamily: 'Inter, system-ui, -apple-system, sans-serif',
  },
  defaultRadius: 'md',
  shadows: {
    sm: '0 0 10px rgba(0, 0, 0, 0.1)',
    md: '0 0 15px rgba(0, 0, 0, 0.2)',
    lg: '0 0 20px rgba(0, 0, 0, 0.3)',
  },
});

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <MantineProvider theme={theme}>
      <ModalsProvider>
        <App />
      </ModalsProvider>
    </MantineProvider>
  </React.StrictMode>,
)
