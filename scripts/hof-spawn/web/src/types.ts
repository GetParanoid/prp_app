export interface LocationInterface {
  label: string;
  x: number;
  y: number;
  z: number;
  type: 'police' | 'housing' | 'hotel' | 'hospital' | 'prison' | 'garage' | 'general';
}

export interface InfoData {
  header: string;
  text: string;
}

export interface ChosenData {
  label: string;
  x: number;
  y: number;
  z: number;
}
