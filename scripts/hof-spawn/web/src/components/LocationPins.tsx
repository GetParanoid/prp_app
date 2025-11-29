import { Box, Text, Button, useMantineTheme, Tooltip, Avatar } from '@mantine/core';
import { fetchNui } from '../utils/fetchNui';
import { LocationInterface } from '../types/index';
import { isEnvBrowser } from '../utils/misc';
import { useResponsiveStyles } from '../utils/responsive';
import { 
  IconMapPin, 
  IconHome, 
  IconShield, 
  IconBuilding, 
  IconBuildingBank,
  IconUsers,
  IconCar,
  IconMedicalCross
} from '@tabler/icons-react';

interface LocationPinsProps {
  locations: LocationInterface[];
  setVisible: (visible: boolean) => void;
  setChosenData: (data: { label: string; x: number; y: number; z: number }) => void;
}

const LocationPins: React.FC<LocationPinsProps> = ({ locations, setVisible, setChosenData }) => {
  const theme = useMantineTheme();
  const responsive = useResponsiveStyles();

  const getSpawnTypeConfig = (type: string | undefined) => {
    const safeType = type || 'general';
    
    switch (safeType) {
      case 'police':
        return {
          icon: IconShield,
          color: theme.colors.blue[4],
          colorName: 'blue'
        };
      case 'housing':
      case 'residential':
        return {
          icon: IconHome,
          color: theme.colors.green[4],
          colorName: 'green'
        };
      case 'hotel':
        return {
          icon: IconBuilding,
          color: theme.colors.violet[4],
          colorName: 'violet'
        };
      case 'hospital':
        return {
          icon: IconMedicalCross,
          color: theme.colors.pink[4],
          colorName: 'pink'
        };
      case 'prison':
        return {
          icon: IconBuildingBank,
          color: theme.colors.red[4],
          colorName: 'red'
        };
      case 'garage':
        return {
          icon: IconCar,
          color: theme.colors.yellow[4],
          colorName: 'yellow'
        };
      case 'general':
      default:
        return {
          icon: IconMapPin,
          color: theme.colors.cyan[4],
          colorName: 'cyan'
        };
    }
  };

  if (isEnvBrowser()) {
    console.log('LocationPins: Rendered with', locations?.length, 'locations');
  }

  const spawnCharacter = (data: LocationInterface) => {
    if (isEnvBrowser()) {
      console.log('Browser mode: Would spawn at', data.label);
      alert(`Browser Debug: Would spawn at ${data.label}`);
    }
    setChosenData(data);
    setVisible(true);
  };

  return (
    <Box
      style={{
        position: 'absolute',
        height: '75vh',
        width: '70vw',
        pointerEvents: 'none',
        zIndex: 20,
      }}
    >
      {!locations || locations.length === 0 ? (
        isEnvBrowser() ? (
          <Box style={{ 
            color: 'white', 
            position: 'absolute', 
            top: '10px', 
            left: '10px', 
            background: theme.colors.red[6], 
            padding: responsive.padding, 
            borderRadius: responsive.borderRadius,
            boxShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.red[4]}`,
          }}>
            <Text size={responsive.text.sm} c="white">No locations found (Browser Debug Mode)</Text>
          </Box>
        ) : null
      ) : (
        locations.map((data, key) => {
          const typeConfig = getSpawnTypeConfig(data.type);
          const IconComponent = typeConfig.icon;
          
          return (
          <Tooltip
            key={key}
            label={data.label}
            position="top"
            withArrow
            styles={{
              tooltip: {
                background: `${theme.colors.dark[8]}f0`,
                border: `1px solid ${typeConfig.color}`,
                borderRadius: responsive.borderRadius,
                boxShadow: `0 0 ${responsive.boxShadowBlur}px ${typeConfig.color}40`,
                color: '#ffffff',
                fontSize: responsive.text.sm,
                fontWeight: 500,
                backdropFilter: 'blur(8px)',
              },
              arrow: {
                borderColor: typeConfig.color,
              }
            }}
          >
            {/* Stat Indicator Pattern */}
            <Box
              style={{
                position: 'absolute',
                top: `${data.top}%`,
                left: `${data.left}%`,
                transform: 'translate(-50%, -50%)',
                pointerEvents: 'all',
                zIndex: 25,
              }}
            >
              {/* Background Glow Effect */}
              <Box
                style={{
                  position: 'absolute',
                  width: `calc(${responsive.avatarSize} * 0.8)`,
                  height: `calc(${responsive.avatarSize} * 0.8)`,
                  borderRadius: responsive.borderRadius,
                  background: `radial-gradient(circle, ${typeConfig.color}25 0%, transparent 70%)`,
                  animation: 'pulse 3s ease-in-out infinite',
                  zIndex: 0,
                }}
              />
              
              {/* Main Pin Icon Container */}
              <Avatar
                size={`calc(${responsive.avatarSize} * 0.7)`}
                radius="xs"
                variant="light"
                color={typeConfig.colorName}
                style={{
                  borderRadius: responsive.borderRadius,
                  background: theme.colors.dark[8],
                  border: `2px solid ${typeConfig.color}`,
                  boxShadow: `0 0 ${responsive.boxShadowBlur * 0.5}px ${typeConfig.color}`,
                  position: 'relative',
                  zIndex: 1,
                  cursor: 'pointer',
                  transition: 'all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)',
                  transformOrigin: 'center',
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.boxShadow = `0 0 ${responsive.boxShadowBlur * 1.5}px ${typeConfig.color}80`;
                  e.currentTarget.style.background = theme.colors.dark[6];
                  e.currentTarget.style.transform = 'scale(1.25) translateY(-2px)';
                  e.currentTarget.style.borderWidth = '3px';
                  e.currentTarget.style.borderColor = typeConfig.color;
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.boxShadow = `0 0 ${responsive.boxShadowBlur * 0.5}px ${typeConfig.color}`;
                  e.currentTarget.style.background = theme.colors.dark[8];
                  e.currentTarget.style.transform = 'scale(1) translateY(0px)';
                  e.currentTarget.style.borderWidth = '2px';
                  e.currentTarget.style.borderColor = typeConfig.color;
                }}
                onClick={() => spawnCharacter(data)}
              >
                <IconComponent size={Math.round(responsive.iconSize * 0.7)} color={typeConfig.color} />
              </Avatar>
            </Box>
          </Tooltip>
          );
        }))}
      
      {/* CSS animation for pulse effect */}
      <style>
        {`
          @keyframes pulse {
            0% { opacity: 0.3; transform: scale(1); }
            50% { opacity: 0.6; transform: scale(1.02); }
            100% { opacity: 0.3; transform: scale(1); }
          }
        `}
      </style>
    </Box>
  );
};

export default LocationPins;
