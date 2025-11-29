import { Box, useMantineTheme } from '@mantine/core';
import { useResponsiveStyles } from '../utils/responsive';

const MapComponent: React.FC = () => {
  const theme = useMantineTheme();
  const responsive = useResponsiveStyles();
  
  return (
    <Box
      style={{
        position: 'absolute',
        height: '75vh',
        width: '70vw',
        background: 'url(./map.webp) no-repeat center center',
        backgroundSize: 'cover',
        borderRadius: responsive.borderRadius * 2,
        border: `2px solid ${theme.colors.dark[6]}`,
        boxShadow: `0 0 ${responsive.boxShadowBlur * 2}px ${theme.colors.dark[8]}, inset 0 0 ${responsive.boxShadowBlur}px rgba(0,0,0,0.5)`,
        filter: 'brightness(0.8) contrast(1.1)',
      }}
    />
  );
};

export default MapComponent;
