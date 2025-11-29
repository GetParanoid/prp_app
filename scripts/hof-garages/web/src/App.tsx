import { useState, useEffect } from 'react';
import { isEnvBrowser } from './utils/misc';
import { useNuiEvent } from './hooks/useNuiEvent';
import { fetchNui } from './utils/fetchNui';
import { GaragePanel } from './components/GaragePanel';
import { GarageUIData } from './types/garage';
import { mockGarageData, mockVehicleDatabase, mockDepotGarageData } from './utils/mockData';
import { responsive } from './utils/responsive';

function App() {
  const [visible, setVisible] = useState(false); // Always start hidden
  const [garageData, setGarageData] = useState<GarageUIData | null>(null); // No initial data

  useEffect(() => {
    console.log('HUD initialized with scale factor:', responsive.scaleFactor);
  }, []);

  useNuiEvent('setVisible', (data: { visible?: boolean }) => {
    setVisible(data.visible || false);
  });

  useNuiEvent('setGarageData', (data: GarageUIData) => {
    setGarageData(data);
    setVisible(true);
  });

  useNuiEvent('hideGarageUI', () => {
    setVisible(false);
    setGarageData(null);
  });

  function handleClose() {
    setVisible(false);
    setGarageData(null);
    void fetchNui('hideGarageUI');
  }

  function handleTakeOut(vehicleId: number, garageName: string, accessPoint: number) {
    console.log('Taking out vehicle:', vehicleId, 'from garage:', garageName, 'at access point:', accessPoint);
    void fetchNui('takeOutVehicle', { vehicleId, garageName, accessPoint });
  }

  function handlePayDepot(vehicleId: number) {
    console.log('Paying depot for vehicle:', vehicleId);
    void fetchNui('payDepotFee', { vehicleId });
  }

  // Web-Dev: Switch between garage types for browser testing
  const handleDemoSwitch = () => {
    if (!isEnvBrowser()) return;
    
    setGarageData(current => 
      current?.garageName === 'legion_square' ? mockDepotGarageData : mockGarageData
    );
  };

  // Web-Dev: Show UI in browser mode
  const handleDemoShow = () => {
    if (!isEnvBrowser()) return;
    setVisible(true);
    setGarageData(mockGarageData);
  };

  return (
    <>
      {visible && garageData && (
        <GaragePanel
          data={garageData}
          vehicleDb={mockVehicleDatabase}
          onClose={handleClose}
          onTakeOut={handleTakeOut}
          onPayDepot={handlePayDepot}
        />
      )}
      
      {/* Web-Dev buttons for browser testing */}
      {isEnvBrowser() && (
        <div style={{ position: 'fixed', top: '10px', left: '10px', zIndex: 1001 }}>
          <button
            onClick={handleDemoShow}
            className="hud-button"
            style={{ marginRight: '10px' }}
          >
            Show Garage UI
          </button>
          {visible && (
            <button
              onClick={handleDemoSwitch}
              className="hud-button hud-button-success"
            >
              Switch Garage Type
            </button>
          )}
        </div>
      )}
    </>
  );
}

export default App;
