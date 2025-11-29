import { Text, useMantineTheme, Stack } from '@mantine/core';
import { useResponsiveStyles } from '../utils/responsive';

interface SpawnInfoProps {
  text: string;
}

const SpawnInfo: React.FC<SpawnInfoProps> = ({ text }) => {
  const theme = useMantineTheme();
  const responsive = useResponsiveStyles();
  
  return (
    <Stack
      gap={responsive.smallMargin}
      style={{
        position: 'absolute',
        top: '8%',
        left: '50%',
        transform: 'translateX(-50%)',
        zIndex: 10,
        textAlign: 'center',
      }}
    >
      <Text
        size={responsive.text.xxl}
        fw={700}
        c="blue.4"
        ta="center"
        style={{
          textShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.blue[4]}`,
          letterSpacing: responsive.scaleFactor * 2,
          fontFamily: theme.fontFamily,
          whiteSpace: 'nowrap',
        }}
      >
        {text}
      </Text>
      <Text
        size={responsive.text.sm}
        fw={400}
        c="gray.4"
        ta="center"
        style={{
          textShadow: `0 0 ${Math.round(responsive.boxShadowBlur / 2)}px ${theme.colors.gray[4]}`,
          letterSpacing: responsive.scaleFactor * 1,
          fontFamily: theme.fontFamily,
          whiteSpace: 'nowrap',
        }}
      >
        Select a spawn location to wake up at...
      </Text>
    </Stack>
  );
};

export default SpawnInfo;
