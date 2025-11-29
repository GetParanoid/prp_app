import Locale from 'locale';
import { ResourceContext } from './resource';
import { debugLog } from './logger';

export function Greetings() {
  const greetings = Locale('hello');

  debugLog(`started dist/${ResourceContext}.js`);
  debugLog(greetings);
}
