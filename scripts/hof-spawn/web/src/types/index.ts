export interface LocationInterface {
  top: number;
  left: number;
  label: string;
  type?: string;
  x: number;
  y: number;
  z: number;
}

export interface InfoData {
  time: string;
  date: string;
  weather: string;
  wind?: number;
}

export interface SpawnData {
  label: string;
  x: number;
  y: number;
  z: number;
}

export interface PlayerProperty {
  label: string;
  keyHolders: string[];
  id: number;
  type: string;
  doorLocked: boolean;
  price: number;
}
