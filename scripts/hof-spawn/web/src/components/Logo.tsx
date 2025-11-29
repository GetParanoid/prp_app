import { Box, Image } from '@mantine/core';
import { useResponsiveStyles } from '../utils/responsive';

const Logo: React.FC = () => {
  const responsive = useResponsiveStyles();
  
  return (
    <Box
      style={{
        position: 'absolute',
        bottom: responsive.padding,
        left: responsive.padding,
        zIndex: 25,
        width: `calc(60px * var(--scale-factor, 1))`,
        height: `calc(60px * var(--scale-factor, 1))`,
      }}
    >
      <Image
        src="https://r2.fivemanage.com/aOkIPeZksXD3I7JXuvAsG/LogoLetter.png"
        alt="HOF Logo"
        style={{
          width: '100%',
          height: '100%',
          objectFit: 'contain',
          filter: 'drop-shadow(0 0 8px rgba(0, 0, 0, 0.5))',
        }}
      />
    </Box>
  );
};

export default Logo;
