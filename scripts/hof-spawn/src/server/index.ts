export {};

declare global {
  function onNet(eventName: string, callback: (...args: any[]) => void): void;
  function emitNet(eventName: string, target: number | string, ...args: any[]): void;
}
