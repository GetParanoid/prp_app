import { VehicleState } from '../types/garage';

/**
 * Get progress bar color based on percentage
 */
export const getProgressColor = (percent: number): string => {
  if (percent >= 75) return 'green.5';
  if (percent > 25) return 'yellow.5';
  return 'red.5';
};

/**
 * Round health values to percentage
 */
export const roundHealth = (health: number): number => {
  return Math.round(health / 10);
};

/**
 * Format currency with commas
 */
export const formatCurrency = (amount: number): string => {
  return amount.toLocaleString();
};

/**
 * Get vehicle state display text
 */
export const getVehicleStateText = (state: VehicleState): string => {
  switch (state) {
    case VehicleState.OUT:
      return 'Out';
    case VehicleState.GARAGED:
      return 'Garaged';
    case VehicleState.IMPOUNDED:
      return 'Impounded';
    default:
      return 'Unknown';
  }
};

/**
 * Get vehicle state color
 */
export const getVehicleStateColor = (state: VehicleState): string => {
  switch (state) {
    case VehicleState.OUT:
      return 'yellow';
    case VehicleState.GARAGED:
      return 'green';
    case VehicleState.IMPOUNDED:
      return 'red';
    default:
      return 'gray';
  }
};

/**
 * Check if vehicle can be taken out
 */
export const canTakeOutVehicle = (state: VehicleState): boolean => {
  return state === VehicleState.GARAGED;
};

/**
 * Check if vehicle is in depot and needs payment
 */
export const needsDepotPayment = (state: VehicleState, garageType?: string): boolean => {
  return state === VehicleState.OUT && garageType === 'depot';
};
