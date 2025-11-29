import { useState, useRef, useEffect } from 'react';
import {
  Card,
  Text,
  Group,
  Stack,
  Progress,
  Button,
  Badge,
  Collapse,
  ActionIcon,
} from '@mantine/core';
import {
  IconChevronDown,
  IconChevronUp,
  IconCarGarage,
  IconGasStation,
  IconEngine,
  IconHammer,
  IconCheck,
  IconCurrencyDollar,
  IconPlayerPlay,
} from '@tabler/icons-react';
import { VehicleData, VehicleDatabase, GarageConfig } from '../types/garage';
import {
  getProgressColor,
  roundHealth,
  formatCurrency,
  getVehicleStateText,
  getVehicleStateColor,
  canTakeOutVehicle,
  needsDepotPayment,
} from '../utils/garage';
import { colors, responsive } from '../utils/responsive';

interface VehicleCardProps {
  vehicle: VehicleData;
  vehicleDb: VehicleDatabase;
  garageInfo: GarageConfig;
  garageName: string;
  accessPoint: number;
  onTakeOut: (vehicleId: number, garageName: string, accessPoint: number) => void;
  onPayDepot?: (vehicleId: number) => void;
}

export const VehicleCard = ({ 
  vehicle, 
  vehicleDb, 
  garageInfo, 
  garageName,
  accessPoint,
  onTakeOut, 
  onPayDepot 
}: VehicleCardProps) => {
  const [expanded, setExpanded] = useState(false);
  const cardRef = useRef<HTMLDivElement>(null);

  // Safety check for vehicle data
  if (!vehicle || !vehicle.modelName) {
    console.error('Invalid vehicle data passed to VehicleCard:', vehicle);
    return null;
  }

  // Auto-scroll when expanding
  useEffect(() => {
    if (expanded && cardRef.current) {
      // Small delay to ensure the collapse animation has started
      setTimeout(() => {
        if (cardRef.current) {
          // Find the scroll container (the parent with overflow)
          const scrollContainer = cardRef.current.closest('.hud-scrollbar') || 
                                 cardRef.current.closest('[style*="overflow"]');
          
          if (scrollContainer) {
            const cardRect = cardRef.current.getBoundingClientRect();
            const containerRect = scrollContainer.getBoundingClientRect();
            
            // Check if the bottom of the card is visible
            const isBottomVisible = cardRect.bottom <= containerRect.bottom;
            
            if (!isBottomVisible) {
              // Scroll to show the bottom of the expanded card
              cardRef.current.scrollIntoView({
                behavior: 'smooth',
                block: 'end',
                inline: 'nearest'
              });
            }
          }
        }
      }, 150); // Slightly longer delay for Collapse animation
    }
  }, [expanded]);

  const vehicleInfo = vehicleDb[vehicle.modelName] || { 
    brand: '', 
    name: (vehicle.modelName || 'Unknown Vehicle')
      .replace(/\d+$/, '') // Remove trailing numbers
      .replace(/([a-z])([A-Z])/g, '$1 $2') // Add space before capital letters
      .split(/[\s_-]+/) // Split on spaces, underscores, or hyphens
      .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()) // Capitalize each word
      .join(' ')
  };
  const vehicleLabel = vehicleInfo.brand 
    ? `${vehicleInfo.brand} ${vehicleInfo.name}` 
    : vehicleInfo.name;
  
  // Safety checks for vehicle properties
  const engine = roundHealth(vehicle.props?.engineHealth || 100);
  const body = roundHealth(vehicle.props?.bodyHealth || 100);
  const fuel = vehicle.props?.fuelLevel || 100;

  const engineColor = getProgressColor(engine);
  const bodyColor = getProgressColor(body);
  const fuelColor = getProgressColor(fuel);

  const stateText = getVehicleStateText(vehicle.state);
  const stateColor = getVehicleStateColor(vehicle.state);

  const canTakeOut = canTakeOutVehicle(vehicle.state);
  const needsPayment = needsDepotPayment(vehicle.state, garageInfo.type);

  const handleTakeOut = () => {
    onTakeOut(vehicle.id, garageName, accessPoint);
  };

  const handlePayDepot = () => {
    if (onPayDepot) {
      onPayDepot(vehicle.id);
    }
  };

  return (
    <Card 
      ref={cardRef}
      shadow="xl" 
      padding={0}
      radius="md" 
      withBorder
      className="hud-card vehicle-card"
      style={{
        background: `linear-gradient(135deg, ${colors.surfaceBg} 0%, rgba(255, 255, 255, 0.02) 100%)`,
        border: `1px solid rgba(255, 255, 255, 0.1)`,
        transition: 'all 0.3s ease-out',
        cursor: 'pointer',
        position: 'relative',
        overflow: 'hidden',
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.transform = 'translateY(-2px)';
        e.currentTarget.style.boxShadow = `0 0 ${responsive.scalePx(20)} rgba(34, 139, 230, 0.3), 0 ${responsive.scalePx(8)} ${responsive.scalePx(32)} rgba(0, 0, 0, 0.4)`;
        e.currentTarget.style.borderColor = colors.bluePrimary;
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = 'translateY(0)';
        e.currentTarget.style.boxShadow = `0 0 ${responsive.scalePx(10)} rgba(34, 139, 230, 0.1), 0 ${responsive.scalePx(4)} ${responsive.scalePx(16)} rgba(0, 0, 0, 0.3)`;
        e.currentTarget.style.borderColor = 'rgba(255, 255, 255, 0.1)';
      }}
    >
      {/* HUD Accent Line */}
      <div
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: '2px',
          background: `linear-gradient(90deg, ${colors.bluePrimary} 0%, ${colors.cyanPrimary} 100%)`,
          opacity: 0.7,
        }}
      />
      
      <div style={{ padding: responsive.scalePx(12) }}>
        <Group 
          justify="space-between" 
          gap={responsive.scalePx(8)}
          style={{ cursor: 'pointer' }}
          onClick={() => setExpanded(!expanded)}
        >
          <Group gap={responsive.scalePx(8)} style={{ flex: 1, minWidth: 0 }}>
            {canTakeOut && (
              <Button
                size="xs"
                className="hud-button-success"
                onClick={(e) => {
                  e.stopPropagation();
                  handleTakeOut();
                }}
                style={{
                  padding: responsive.scalePx(4),
                  minWidth: responsive.scalePx(24),
                  height: responsive.scalePx(24),
                  backgroundColor: `rgba(255, 255, 255, 0.1)`,
                  color: '#000000',
                  border: `1px solid rgba(81, 207, 102, 0.6)`,
                  borderRadius: responsive.scalePx(4),
                  transition: 'all 0.3s ease-out',
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.backgroundColor = `rgba(81, 207, 102, 0.3)`;
                  e.currentTarget.style.color = '#ffffff';
                  e.currentTarget.style.transform = 'scale(1.05)';
                  e.currentTarget.style.boxShadow = `0 0 ${responsive.scalePx(6)} rgba(81, 207, 102, 0.4)`;
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.backgroundColor = `rgba(255, 255, 255, 0.1)`;
                  e.currentTarget.style.color = '#000000';
                  e.currentTarget.style.transform = 'scale(1)';
                  e.currentTarget.style.boxShadow = 'none';
                }}
              >
                <IconPlayerPlay size={responsive.scaleFactor * 10} />
              </Button>
            )}
            <div style={{ flex: 1, minWidth: 0 }}>
              <Text 
                fw={600} 
                size="xs" 
                lineClamp={1} 
                style={{
                  color: colors.textPrimary,
                  fontSize: responsive.scalePx(13),
                  textShadow: '0 1px 2px rgba(0, 0, 0, 0.3)',
                }}
              >
                {vehicleLabel}
              </Text>
              <Group gap={responsive.scalePx(8)}>
                <Text 
                  size="xs" 
                  lineClamp={1}
                  style={{
                    color: colors.textDimmed,
                    fontSize: responsive.scalePx(11),
                  }}
                >
                  {vehicle.plate || "NO PLATE"}
                </Text>
                <Text 
                  size="xs" 
                  lineClamp={1}
                  style={{
                    color: colors.textDimmed,
                    fontSize: responsive.scalePx(11),
                  }}
                >
                  VIN: {vehicle.id}
                </Text>
              </Group>
            </div>
          </Group>
          <Group gap={responsive.scalePx(8)}>
            <Badge 
              size="xs" 
              style={{
                fontSize: responsive.scalePx(9),
                padding: `${responsive.scalePx(2)} ${responsive.scalePx(6)}`,
                backgroundColor: stateColor === 'green' 
                  ? 'rgba(81, 207, 102, 0.25)' 
                  : stateColor === 'yellow' 
                    ? 'rgba(255, 212, 59, 0.25)' 
                    : 'rgba(250, 82, 82, 0.25)',
                color: stateColor === 'green' 
                  ? '#ffffff' 
                  : stateColor === 'yellow' 
                    ? '#ffffff' 
                    : '#ffffff',
                border: `1px solid ${stateColor === 'green' 
                  ? 'rgba(81, 207, 102, 0.6)' 
                  : stateColor === 'yellow' 
                    ? 'rgba(255, 212, 59, 0.6)' 
                    : 'rgba(250, 82, 82, 0.6)'}`,
                borderRadius: responsive.scalePx(3),
                fontWeight: 500,
                textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
              }}
            >
              {stateText}
            </Badge>
            <ActionIcon
              variant="subtle"
              onClick={(e) => {
                e.stopPropagation();
                setExpanded(!expanded);
              }}
              size={responsive.scaleFactor * 20}
              style={{
                color: colors.textDimmed,
                transition: 'all 0.3s ease-out',
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.color = colors.bluePrimary;
                e.currentTarget.style.transform = 'scale(1.1)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.color = colors.textDimmed;
                e.currentTarget.style.transform = 'scale(1)';
              }}
            >
              {expanded ? <IconChevronUp size={responsive.scaleFactor * 12} /> : <IconChevronDown size={responsive.scaleFactor * 12} />}
            </ActionIcon>
          </Group>
        </Group>
      </div>

      <Collapse in={expanded}>
        <div style={{ 
          padding: `0 ${responsive.scalePx(12)} ${responsive.scalePx(12)}`,
          borderTop: `1px solid rgba(255, 255, 255, 0.1)`,
          marginTop: responsive.scalePx(8),
          paddingTop: responsive.scalePx(12),
        }}>
          {/* Vehicle Health Information with HUD Styling */}
          <Group gap={responsive.scalePx(8)} grow>
            <Stack gap={responsive.scalePx(4)} style={{ flex: 1 }}>
              <Group gap={responsive.scalePx(4)} justify="space-between">
                <Group gap={responsive.scalePx(4)}>
                  <IconEngine size={responsive.scaleFactor * 12} color={colors.bluePrimary} />
                  <Text 
                    size="xs" 
                    fw={600} 
                    style={{
                      color: colors.textPrimary,
                      fontSize: responsive.scalePx(11),
                    }}
                  >
                    Engine
                  </Text>
                </Group>
                <Text 
                  size="xs" 
                  style={{
                    color: colors.textDimmed,
                    fontSize: responsive.scalePx(10),
                  }}
                >
                  {engine}%
                </Text>
              </Group>
              <Progress
                value={engine}
                color={engineColor}
                size={responsive.scalePx(4)}
                radius={responsive.scalePx(2)}
                style={{
                  backgroundColor: 'rgba(255, 255, 255, 0.1)',
                }}
              />
            </Stack>

            <Stack gap={responsive.scalePx(4)} style={{ flex: 1 }}>
              <Group gap={responsive.scalePx(4)} justify="space-between">
                <Group gap={responsive.scalePx(4)}>
                  <IconHammer size={responsive.scaleFactor * 12} color={colors.cyanPrimary} />
                  <Text 
                    size="xs" 
                    fw={600} 
                    style={{
                      color: colors.textPrimary,
                      fontSize: responsive.scalePx(11),
                    }}
                  >
                    Body
                  </Text>
                </Group>
                <Text 
                  size="xs" 
                  style={{
                    color: colors.textDimmed,
                    fontSize: responsive.scalePx(10),
                  }}
                >
                  {body}%
                </Text>
              </Group>
              <Progress
                value={body}
                color={bodyColor}
                size={responsive.scalePx(4)}
                radius={responsive.scalePx(2)}
                style={{
                  backgroundColor: 'rgba(255, 255, 255, 0.1)',
                }}
              />
            </Stack>

            <Stack gap={responsive.scalePx(4)} style={{ flex: 1 }}>
              <Group gap={responsive.scalePx(4)} justify="space-between">
                <Group gap={responsive.scalePx(4)}>
                  <IconGasStation size={responsive.scaleFactor * 12} color={colors.yellowPrimary} />
                  <Text 
                    size="xs" 
                    fw={600} 
                    style={{
                      color: colors.textPrimary,
                      fontSize: responsive.scalePx(11),
                    }}
                  >
                    Fuel
                  </Text>
                </Group>
                <Text 
                  size="xs" 
                  style={{
                    color: colors.textDimmed,
                    fontSize: responsive.scalePx(10),
                  }}
                >
                  {Math.round(fuel)}%
                </Text>
              </Group>
              <Progress
                value={fuel}
                color={fuelColor}
                size={responsive.scalePx(4)}
                radius={responsive.scalePx(2)}
                style={{
                  backgroundColor: 'rgba(255, 255, 255, 0.1)',
                }}
              />
            </Stack>
          </Group>

          {/* HUD Action Buttons */}
          <Group gap={responsive.scalePx(8)} mt={responsive.scalePx(12)}>
            {canTakeOut && (
              <Button
                leftSection={<IconCarGarage size={responsive.scaleFactor * 12} />}
                onClick={handleTakeOut}
                size="xs"
                className="hud-button-primary"
                style={{ 
                  flex: 1,
                  fontSize: responsive.scalePx(11),
                  padding: responsive.scalePx(8),
                  backgroundColor: `rgba(34, 139, 230, 0.2)`,
                  color: '#ffffff',
                  border: `1px solid rgba(34, 139, 230, 0.6)`,
                  borderRadius: responsive.scalePx(6),
                  transition: 'all 0.3s ease-out',
                  textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
                  fontWeight: 500,
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.backgroundColor = `rgba(34, 139, 230, 0.3)`;
                  e.currentTarget.style.transform = 'translateY(-1px)';
                  e.currentTarget.style.boxShadow = `0 0 ${responsive.scalePx(8)} rgba(34, 139, 230, 0.4)`;
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.backgroundColor = `rgba(34, 139, 230, 0.2)`;
                  e.currentTarget.style.transform = 'translateY(0)';
                  e.currentTarget.style.boxShadow = 'none';
                }}
              >
                Take Out
              </Button>
            )}

            {needsPayment && (
              <Button
                leftSection={<IconCurrencyDollar size={responsive.scaleFactor * 12} />}
                onClick={handlePayDepot}
                size="xs"
                className="hud-button-warning"
                style={{ 
                  flex: 1,
                  fontSize: responsive.scalePx(11),
                  padding: responsive.scalePx(8),
                  backgroundColor: `rgba(255, 212, 59, 0.2)`,
                  color: '#ffffff',
                  border: `1px solid rgba(255, 212, 59, 0.6)`,
                  borderRadius: responsive.scalePx(6),
                  transition: 'all 0.3s ease-out',
                  textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
                  fontWeight: 500,
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.backgroundColor = `rgba(255, 212, 59, 0.3)`;
                  e.currentTarget.style.transform = 'translateY(-1px)';
                  e.currentTarget.style.boxShadow = `0 0 ${responsive.scalePx(8)} rgba(255, 212, 59, 0.4)`;
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.backgroundColor = `rgba(255, 212, 59, 0.2)`;
                  e.currentTarget.style.transform = 'translateY(0)';
                  e.currentTarget.style.boxShadow = 'none';
                }}
              >
                Pay ${formatCurrency(vehicle.depotPrice)}
              </Button>
            )}

            {vehicle.state === 0 && !needsPayment && (
              <Button
                leftSection={<IconCheck size={responsive.scaleFactor * 12} />}
                disabled
                size="xs"
                style={{ 
                  flex: 1,
                  fontSize: responsive.scalePx(11),
                  padding: responsive.scalePx(8),
                  backgroundColor: 'rgba(255, 255, 255, 0.05)',
                  color: colors.textDimmed,
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                  borderRadius: responsive.scalePx(6),
                  opacity: 0.6,
                }}
              >
                Already Out
              </Button>
            )}

            {vehicle.state === 2 && (
              <Button
                disabled
                size="xs"
                style={{ 
                  flex: 1,
                  fontSize: responsive.scalePx(11),
                  padding: responsive.scalePx(8),
                  backgroundColor: `rgba(250, 82, 82, 0.1)`,
                  color: colors.redPrimary,
                  border: `1px solid ${colors.redPrimary}`,
                  borderRadius: responsive.scalePx(6),
                  opacity: 0.7,
                }}
              >
                Impounded
              </Button>
            )}
          </Group>
        </div>
      </Collapse>
    </Card>
  );
};
