export enum VehicleState {
  OUT = 0,
  GARAGED = 1,
  IMPOUNDED = 2
}

export enum VehicleType {
  CAR = 'car',
  AIR = 'air',
  SEA = 'sea',
  ALL = 'all',
}

export enum GarageType {
  DEPOT = 'depot',
}

export interface VehicleProps {
  engineHealth: number;
  bodyHealth: number;
  fuelLevel: number;
  plate: string;
  // Add other vehicle properties as needed
}

export interface VehicleData {
  id: number;
  citizenid?: string;
  modelName: string;
  plate: string;
  garage: string;
  state: VehicleState;
  depotPrice: number;
  props: VehicleProps;
}

export interface GarageConfig {
  label: string;
  type?: GarageType;
  vehicleType: VehicleType;
  groups?: string[];
}

export interface GarageUIData {
  garageName: string;
  garageInfo: GarageConfig;
  vehicles: VehicleData[];
  accessPoint: number;
}

export interface VehicleInfo {
  brand: string;
  name: string;
}

export type VehicleDatabase = Record<string, VehicleInfo>;
