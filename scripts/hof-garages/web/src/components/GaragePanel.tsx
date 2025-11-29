import { useState, useMemo, useEffect } from 'react';
import {
  Paper,
  Stack,
  Text,
  Group,
  TextInput,
  Select,
  ActionIcon,
  Title,
  Badge,
} from '@mantine/core';
import {
  IconSearch,
  IconX,
  IconFilter,
  IconCarGarage,
} from '@tabler/icons-react';
import { VehicleCard } from './VehicleCard';
import { GarageUIData, VehicleState, VehicleDatabase } from '../types/garage';
import { responsive, scaleVh, scaleVw, colors } from '../utils/responsive';

interface GaragePanelProps {
  data: GarageUIData | null;
  vehicleDb: VehicleDatabase;
  onClose: () => void;
  onTakeOut: (vehicleId: number, garageName: string, accessPoint: number) => void;
  onPayDepot?: (vehicleId: number) => void;
}

export const GaragePanel = ({ 
  data, 
  vehicleDb, 
  onClose, 
  onTakeOut, 
  onPayDepot 
}: GaragePanelProps) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [stateFilter, setStateFilter] = useState<string | null>(null);

  // Add null check
  if (!data) {
    return null;
  }

  if (!data || !data.garageName || !data.garageInfo) {
    return null;
  }

  // Debug: Log the actual data structure from game
  console.log('GaragePanel received data:', data);
  console.log('Vehicles array:', data.vehicles);

  // ESC key listener to close garage UI
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        event.preventDefault();
        onClose();
      }
    };

    // Add event listener
    document.addEventListener('keydown', handleKeyDown);

    // Cleanup function to remove event listener
    return () => {
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [onClose]);

  // Ensure vehicles array exists
  const vehicles = data.vehicles || [];

  const filteredVehicles = useMemo(() => {
    if (!vehicles?.length) return [];

    return vehicles.filter((vehicle) => {
      // Safety check for vehicle properties
      if (!vehicle || !vehicle.modelName || !vehicle.plate) {
        console.warn('Invalid vehicle data:', vehicle);
        return false;
      }

      // Search filter
      const vehicleInfo = vehicleDb[vehicle.modelName] || { 
        brand: '', 
        name: vehicle.modelName
          .replace(/\d+$/, '') // Remove trailing numbers
          .replace(/([a-z])([A-Z])/g, '$1 $2') // Add space before capital letters
          .split(/[\s_-]+/) // Split on spaces, underscores, or hyphens
          .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()) // Capitalize each word
          .join(' ')
      };
      const vehicleLabel = (vehicleInfo.brand 
        ? `${vehicleInfo.brand} ${vehicleInfo.name}` 
        : vehicleInfo.name).toLowerCase();
      const plate = vehicle.plate.toLowerCase();
      const searchLower = searchTerm.toLowerCase();
      
      const matchesSearch = vehicleLabel.includes(searchLower) || 
                           plate.includes(searchLower) ||
                           vehicle.id.toString().includes(searchLower);

      // State filter
      const matchesState = !stateFilter || stateFilter === '' || 
                          vehicle.state.toString() === stateFilter;

      return matchesSearch && matchesState;
    }).sort((a, b) => {
      // Sort by state (garaged first), then by model name
      if (a.state !== b.state) {
        if (a.state === VehicleState.GARAGED) return -1;
        if (b.state === VehicleState.GARAGED) return 1;
        return a.state - b.state;
      }
      
      const aInfo = vehicleDb[a.modelName] || { 
        brand: '', 
        name: (a.modelName || 'Unknown')
          .replace(/\d+$/, '')
          .replace(/([a-z])([A-Z])/g, '$1 $2')
          .split(/[\s_-]+/)
          .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
          .join(' ')
      };
      const bInfo = vehicleDb[b.modelName] || { 
        brand: '', 
        name: (b.modelName || 'Unknown')
          .replace(/\d+$/, '')
          .replace(/([a-z])([A-Z])/g, '$1 $2')
          .split(/[\s_-]+/)
          .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
          .join(' ')
      };
      const aLabel = aInfo.brand ? `${aInfo.brand} ${aInfo.name}` : aInfo.name;
      const bLabel = bInfo.brand ? `${bInfo.brand} ${bInfo.name}` : bInfo.name;
      
      return aLabel.localeCompare(bLabel);
    });
  }, [vehicles, vehicleDb, searchTerm, stateFilter]);

  const vehicleCountsByState = useMemo(() => {
    if (!vehicles?.length) return { garaged: 0, out: 0, impounded: 0 };
    
    return vehicles.reduce((acc, vehicle) => {
      if (!vehicle || typeof vehicle.state === 'undefined') {
        console.warn('Vehicle missing state:', vehicle);
        return acc;
      }
      
      switch (vehicle.state) {
        case VehicleState.GARAGED:
          acc.garaged++;
          break;
        case VehicleState.OUT:
          acc.out++;
          break;
        case VehicleState.IMPOUNDED:
          acc.impounded++;
          break;
      }
      return acc;
    }, { garaged: 0, out: 0, impounded: 0 });
  }, [vehicles]);

  const stateOptions = [
    { 
      value: '', 
      label: 'All Vehicles',
    },
    { 
      value: VehicleState.GARAGED.toString(), 
      label: `Garaged (${vehicleCountsByState.garaged})`,
    },
    { 
      value: VehicleState.OUT.toString(), 
      label: `Out (${vehicleCountsByState.out})`,
    },
    { 
      value: VehicleState.IMPOUNDED.toString(), 
      label: `Impounded (${vehicleCountsByState.impounded})`,
    },
  ];

  return (
    <Paper
      shadow="xl"
      p={0}
      radius="md"
      className="hud-card scale-in"
      style={{
        position: 'fixed',
        top: scaleVh(50),
        right: scaleVw(32),
        width: scaleVw(400),
        minWidth: `${320 * responsive.scaleFactor}px`,
        maxWidth: `${500 * responsive.scaleFactor}px`,
        height: 'auto',
        minHeight: scaleVh(300),
        maxHeight: scaleVh(680),
        overflow: 'hidden',
        zIndex: 1000,
        display: 'flex',
        flexDirection: 'column',
        background: `linear-gradient(135deg, ${colors.secondaryBg} 0%, ${colors.surfaceBg} 100%)`,
        border: `1px solid rgba(34, 139, 230, 0.3)`,
        boxShadow: `0 0 ${scaleVh(20)} rgba(34, 139, 230, 0.2), 0 ${scaleVh(8)} ${scaleVh(32)} rgba(0, 0, 0, 0.4)`,
      }}
    >
      {/* Header with Glow Effect */}
      <div
        style={{
          background: `linear-gradient(90deg, ${colors.bluePrimary} 0%, ${colors.cyanPrimary} 100%)`,
          padding: responsive.scalePx(16),
          borderBottom: `1px solid rgba(255, 255, 255, 0.1)`,
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        {/* Header glow effect */}
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            height: '1px',
            background: 'linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.8), transparent)',
          }}
        />
        
        <Group justify="space-between" align="center">
          <Group gap={responsive.scalePx(12)} align="center">
            {/* Logo */}
            <div
              style={{
                width: responsive.scalePx(40),
                height: responsive.scalePx(40),
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                borderRadius: '50%',
                background: 'rgba(255, 255, 255, 0.1)',
                backdropFilter: 'blur(10px)',
                border: '1px solid rgba(255, 255, 255, 0.2)',
                boxShadow: '0 4px 12px rgba(0, 0, 0, 0.3)',
              }}
            >
              <img
                src="https://r2.fivemanage.com/aOkIPeZksXD3I7JXuvAsG/LogoLetter.png"
                alt="HOF Logo"
                style={{
                  width: responsive.scalePx(26),
                  height: responsive.scalePx(26),
                  filter: 'drop-shadow(0 2px 4px rgba(0, 0, 0, 0.4))',
                }}
                onError={(e) => {
                  // Fallback to garage icon if logo fails to load
                  const target = e.target as HTMLImageElement;
                  target.style.display = 'none';
                  const fallbackIcon = target.parentElement?.querySelector('.fallback-icon');
                  if (fallbackIcon) {
                    (fallbackIcon as HTMLElement).style.display = 'block';
                  }
                }}
              />
              <IconCarGarage 
                className="fallback-icon"
                size={responsive.scaleFactor * 20} 
                style={{ 
                  display: 'none',
                  color: 'rgba(255, 255, 255, 0.8)',
                }} 
              />
            </div>
            
            <div>
              <Title 
                order={4} 
                c="white" 
                style={{ 
                  lineHeight: 1.2,
                  textShadow: '0 2px 4px rgba(0, 0, 0, 0.3)',
                  fontSize: responsive.scalePx(16),
                  fontWeight: 600,
                }}
              >
                {data.garageInfo.label}
              </Title>
              <Text 
                size="xs" 
                style={{
                  fontSize: responsive.scalePx(11),
                  color: '#ffffff',
                  opacity: 0.9,
                  textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
                  fontWeight: 500,
                }}
              >
                {vehicles.length} vehicle{vehicles.length !== 1 ? 's' : ''} available
              </Text>
            </div>
          </Group>
          <ActionIcon
            variant="subtle"
            color="white"
            onClick={onClose}
            size={responsive.scaleFactor * 28}
            style={{
              borderRadius: '50%',
              transition: 'all 0.3s ease-out',
              backgroundColor: 'rgba(255, 255, 255, 0.1)',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = 'rgba(255, 255, 255, 0.2)';
              e.currentTarget.style.transform = 'scale(1.1)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = 'rgba(255, 255, 255, 0.1)';
              e.currentTarget.style.transform = 'scale(1)';
            }}
          >
            <IconX size={responsive.scaleFactor * 16} />
          </ActionIcon>
        </Group>
      </div>

      {/* Filters Section */}
      <div style={{ 
        padding: responsive.scalePx(12),
        position: 'relative',
        zIndex: 1100,
      }}>
        <Stack gap={responsive.scalePx(8)}>
          <TextInput
            placeholder="Search VIN, Plate, Make, Model..."
            leftSection={<IconSearch size={responsive.scaleFactor * 14} />}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.currentTarget.value)}
            size="xs"
            className="hud-input"
            styles={{
              input: {
                fontSize: responsive.scalePx(12),
                padding: responsive.scalePx(8),
                paddingLeft: responsive.scalePx(32),
                backgroundColor: colors.surfaceBg,
                borderColor: 'rgba(255, 255, 255, 0.1)',
                color: colors.textPrimary,
                transition: 'all 0.3s ease-out',
                '&:focus': {
                  borderColor: colors.bluePrimary,
                  boxShadow: `0 0 ${responsive.scalePx(10)} rgba(34, 139, 230, 0.3)`,
                },
                '&::placeholder': {
                  color: colors.textDimmed,
                },
              },
              section: {
                color: colors.textDimmed,
                width: responsive.scalePx(28),
                minWidth: responsive.scalePx(28),
              }
            }}
          />
          
          <Select
            placeholder="Filter by state..."
            leftSection={<IconFilter size={responsive.scaleFactor * 14} />}
            data={stateOptions}
            value={stateFilter}
            onChange={(value) => {
              console.log('Filter changed to:', value);
              setStateFilter(value);
            }}
            clearable
            size="xs"
            className="hud-input"
            comboboxProps={{
              shadow: 'xl',
              withinPortal: true,
              zIndex: 2000,
              position: 'bottom-start',
            }}
            onDropdownOpen={() => console.log('Dropdown opened')}
            onDropdownClose={() => console.log('Dropdown closed')}
            renderOption={({ option }) => {
              const getStateStyle = (value: string) => {
                if (value === VehicleState.GARAGED.toString()) {
                  return {
                    backgroundColor: 'rgba(81, 207, 102, 0.25)',
                    borderColor: 'rgba(81, 207, 102, 0.6)',
                  };
                } else if (value === VehicleState.OUT.toString()) {
                  return {
                    backgroundColor: 'rgba(255, 212, 59, 0.25)',
                    borderColor: 'rgba(255, 212, 59, 0.6)',
                  };
                } else if (value === VehicleState.IMPOUNDED.toString()) {
                  return {
                    backgroundColor: 'rgba(250, 82, 82, 0.25)',
                    borderColor: 'rgba(250, 82, 82, 0.6)',
                  };
                }
                return null;
              };

              const stateStyle = getStateStyle(option.value);

              return (
                <Group gap={responsive.scalePx(8)} wrap="nowrap">
                  {stateStyle && (
                    <Badge
                      size="xs"
                      style={{
                        backgroundColor: stateStyle.backgroundColor,
                        color: '#ffffff',
                        border: `1px solid ${stateStyle.borderColor}`,
                        borderRadius: responsive.scalePx(3),
                        fontWeight: 500,
                        textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
                        minWidth: responsive.scalePx(8),
                        height: responsive.scalePx(8),
                        padding: 0,
                      }}
                    />
                  )}
                  <Text 
                    size="xs" 
                    style={{ 
                      fontSize: responsive.scalePx(12),
                      color: '#ffffff',
                      fontWeight: 500,
                    }}
                  >
                    {option.label}
                  </Text>
                </Group>
              );
            }}
            styles={{
              input: {
                fontSize: responsive.scalePx(12),
                padding: responsive.scalePx(8),
                paddingLeft: responsive.scalePx(32),
                backgroundColor: colors.surfaceBg,
                borderColor: 'rgba(255, 255, 255, 0.1)',
                color: colors.textPrimary,
                transition: 'all 0.3s ease-out',
                '&:focus': {
                  borderColor: colors.bluePrimary,
                  boxShadow: `0 0 ${responsive.scalePx(10)} rgba(34, 139, 230, 0.3)`,
                },
                '&::placeholder': {
                  color: colors.textDimmed,
                },
              },
              section: {
                color: colors.textDimmed,
                width: responsive.scalePx(28),
                minWidth: responsive.scalePx(28),
              },
              dropdown: {
                backgroundColor: colors.surfaceBg,
                borderColor: colors.bluePrimary,
                border: `1px solid ${colors.bluePrimary}`,
                boxShadow: `0 0 ${responsive.scalePx(20)} rgba(34, 139, 230, 0.3), 0 ${responsive.scalePx(8)} ${responsive.scalePx(32)} rgba(0, 0, 0, 0.4)`,
                borderRadius: responsive.scalePx(8),
                padding: responsive.scalePx(4),
                zIndex: 2000,
              },
              option: {
                color: colors.textPrimary,
                fontSize: responsive.scalePx(12),
                padding: responsive.scalePx(8),
                borderRadius: responsive.scalePx(4),
                margin: responsive.scalePx(2),
                fontWeight: 500,
                '&[data-selected]': {
                  backgroundColor: `rgba(34, 139, 230, 0.3)`,
                  color: '#ffffff',
                },
                '&[data-hovered]': {
                  backgroundColor: 'rgba(34, 139, 230, 0.15)',
                  color: '#ffffff',
                  transform: 'translateX(2px)',
                  transition: 'all 0.2s ease-out',
                  borderLeft: `2px solid ${colors.bluePrimary}`,
                },
              },
            }}
          />
        </Stack>
      </div>

      {/* Divider */}
      <div
        style={{
          height: '1px',
          background: `linear-gradient(90deg, transparent, ${colors.bluePrimary}, transparent)`,
          opacity: 0.3,
        }}
      />

      {/* Vehicle List */}
      <div 
        style={{ 
          flex: 1,
          overflowY: 'auto',
          overflowX: 'hidden',
          minHeight: 0,
          paddingRight: responsive.scalePx(4),
        }}
        className="hud-scrollbar"
      >
        <div style={{ padding: responsive.scalePx(8) }}>
          {filteredVehicles.length === 0 ? (
            <div
              style={{
                textAlign: 'center',
                padding: responsive.scalePx(32),
                color: colors.textDimmed,
                background: `linear-gradient(135deg, ${colors.surfaceBg} 0%, rgba(255, 255, 255, 0.02) 100%)`,
                borderRadius: responsive.scalePx(8),
                border: '1px solid rgba(255, 255, 255, 0.05)',
              }}
            >
              <IconCarGarage 
                size={responsive.scaleFactor * 48} 
                style={{ 
                  marginBottom: responsive.scalePx(16),
                  opacity: 0.3,
                  color: colors.bluePrimary,
                }} 
              />
              <Text 
                size="sm" 
                style={{ 
                  fontSize: responsive.scalePx(14),
                  marginBottom: responsive.scalePx(8),
                  color: colors.textPrimary,
                }}
              >
                {searchTerm || stateFilter ? 'No vehicles match your filters' : 'No vehicles in this garage'}
              </Text>
              <Text 
                size="xs" 
                style={{ 
                  fontSize: responsive.scalePx(12),
                  opacity: 0.7,
                  color: colors.textDimmed,
                }}
              >
                Try adjusting your search or filter criteria
              </Text>
            </div>
          ) : (
            <Stack gap={responsive.scalePx(8)}>
              {filteredVehicles.map((vehicle) => (
                <VehicleCard
                  key={vehicle.id}
                  vehicle={vehicle}
                  vehicleDb={vehicleDb}
                  garageInfo={data.garageInfo}
                  garageName={data.garageName}
                  accessPoint={data.accessPoint}
                  onTakeOut={onTakeOut}
                  onPayDepot={onPayDepot}
                />
              ))}
            </Stack>
          )}
        </div>
      </div>

      {/* Footer Stats with Glow */}
      <div
        style={{
          padding: responsive.scalePx(12),
          borderTop: `1px solid rgba(255, 255, 255, 0.1)`,
          background: `linear-gradient(180deg, transparent 0%, rgba(0, 0, 0, 0.2) 100%)`,
        }}
      >
        <Group justify="space-between">
          <Badge 
            size="xs" 
            className="hud-badge-success"
            style={{
              fontSize: responsive.scalePx(10),
              padding: `${responsive.scalePx(4)} ${responsive.scalePx(8)}`,
              backgroundColor: `rgba(81, 207, 102, 0.25)`,
              color: '#ffffff',
              border: `1px solid rgba(81, 207, 102, 0.6)`,
              borderRadius: responsive.scalePx(3),
              fontWeight: 500,
              textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
            }}
          >
            {vehicleCountsByState.garaged} Available
          </Badge>
          <Badge 
            size="xs" 
            className="hud-badge-warning"
            style={{
              fontSize: responsive.scalePx(10),
              padding: `${responsive.scalePx(4)} ${responsive.scalePx(8)}`,
              backgroundColor: `rgba(255, 212, 59, 0.25)`,
              color: '#ffffff',
              border: `1px solid rgba(255, 212, 59, 0.6)`,
              borderRadius: responsive.scalePx(3),
              fontWeight: 500,
              textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
            }}
          >
            {vehicleCountsByState.out} Out
          </Badge>
          <Badge 
            size="xs" 
            className="hud-badge-danger"
            style={{
              fontSize: responsive.scalePx(10),
              padding: `${responsive.scalePx(4)} ${responsive.scalePx(8)}`,
              backgroundColor: `rgba(250, 82, 82, 0.25)`,
              color: '#ffffff',
              border: `1px solid rgba(250, 82, 82, 0.6)`,
              borderRadius: responsive.scalePx(3),
              fontWeight: 500,
              textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
            }}
          >
            {vehicleCountsByState.impounded} Impounded
          </Badge>
        </Group>
      </div>
    </Paper>
  );
};
