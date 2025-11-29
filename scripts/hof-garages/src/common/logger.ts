import Config from '@common/config';

export function debugLog(...payload: unknown[]): void {
  if (!Config.EnableDebugLogging) return;
  console.log(...payload);
}
