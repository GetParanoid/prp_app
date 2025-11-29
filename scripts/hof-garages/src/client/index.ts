import Config from '@common/config';
import { Greetings } from '@common/index';
import { debugLog } from '@common/logger';
import { cache } from '@communityox/ox_lib/client';
import { triggerServerCallback } from '@communityox/ox_lib/client';

Greetings();

interface GarageUIData {
  garageName: string;
  garageInfo: {
    label: string;
    type?: string;
    vehicleType: string;
    groups?: string[];
  };
  vehicles: any[];
  accessPoint: number;
}

onNet('hof-garages:client:openGarageUI', (garageData: GarageUIData) => {
  debugLog('Received garage data:', garageData);

  if (!garageData || !garageData.garageName || !garageData.vehicles) {
    console.error('Invalid garage data received');
    return;
  }

  debugLog('Setting NUI focus and sending garage data to UI');
  SetNuiFocus(true, true);
  SendNUIMessage({
    action: 'setGarageData',
    data: garageData,
  });
});

RegisterNuiCallback('hideGarageUI', (data: null, cb: (data: unknown) => void) => {
  SetNuiFocus(false, false);
  cb({});
});

RegisterNuiCallback('takeOutVehicle', async (data: { vehicleId: number; garageName: string; accessPoint: number }, cb: (data: unknown) => void) => {
  try {
    debugLog('Client callback received data:', JSON.stringify(data));
    debugLog('Extracting vehicleId:', data.vehicleId, 'accessPoint:', data.accessPoint);
    debugLog('Sending native event with vehicleId:', data.vehicleId);

    const response = await new Promise<{ success: boolean; message: string }>((resolve, reject) => {
      const eventName = `hof-garages:takeOutVehicleResponse:${GetPlayerServerId(PlayerId())}`;

      const timeout = setTimeout(() => {
        removeEventListener(eventName, handler);
        reject(new Error('Server response timeout'));
      }, 10000);

      const handler = (result: { success: boolean; message: string }) => {
        clearTimeout(timeout);
        removeEventListener(eventName, handler);
        resolve(result);
      };

      onNet(eventName, handler);
      emitNet('hof-garages:takeOutVehicleRequest', data.vehicleId);
    });

    if (response && response.success) {
      SendNUIMessage({
        action: 'hideGarageUI'
      });
      SetNuiFocus(false, false);
      exports['hof-base'].notify({
        title: 'Success',
        description: response.message || 'Vehicle spawned successfully',
        type: 'success',
        duration: 5000
      });
    } else {
      exports['hof-base'].notify({
        title: 'Error',
        description: (response && response.message) || 'Failed to spawn vehicle',
        type: 'error',
        duration: 5000
      });
    }
  } catch (error) {
    console.error('Vehicle spawn error:', error);
    const errorMessage = error instanceof Error ? error.message : 'An error occurred';
    exports['hof-base'].notify({
      title: 'Error',
      description: errorMessage,
      type: 'error',
      duration: 5000
    });
  }

  cb({});
});

RegisterNuiCallback('payDepotFee', async (data: { vehicleId: number }, cb: (data: unknown) => void) => {
  try {
    const response = await triggerServerCallback<{ success: boolean; message: string }>('hof-garages:payDepotFee', data.vehicleId);

    if (response && response.success) {
      exports['hof-base'].notify({
        title: 'Success',
        description: response.message || 'Payment successful',
        type: 'success',
        duration: 5000
      });
    } else {
      exports['hof-base'].notify({
        title: 'Error',
        description: (response && response.message) || 'Payment failed',
        type: 'error',
        duration: 5000
      });
    }
  } catch (error) {
    exports['hof-base'].notify({
      title: 'Error',
      description: 'Payment processing error',
      type: 'error',
      duration: 5000
    });
  }

  cb({});
});

if (Config.EnableNuiCommand) {
  onNet(`${cache.resource}:openNui`, () => {
    SetNuiFocus(true, true);

    SendNUIMessage({
      action: 'setVisible',
      data: {
        visible: true,
      },
    });
  });

  RegisterNuiCallback('exit', (data: null, cb: (data: unknown) => void) => {
    SetNuiFocus(false, false);
    cb({});
  });
}
