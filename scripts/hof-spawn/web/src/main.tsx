import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';
import '@mantine/core/styles.css';
import './index.css';
import { isEnvBrowser } from './utils/misc.ts';

const root = ReactDOM.createRoot(document.getElementById('root')!);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

if (isEnvBrowser()) {
  const rootEl = document.getElementById('root');

  // https://i.imgur.com/iPTAdYV.png - Night time img
  // https://i.imgur.com/3pzRj9n.png - Day time img
  rootEl!.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")';
  rootEl!.style.backgroundSize = 'cover';
  rootEl!.style.backgroundRepeat = 'no-repeat';
  rootEl!.style.backgroundPosition = 'center';
}
