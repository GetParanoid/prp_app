import { Box, Text, Group, Stack, useMantineTheme } from '@mantine/core';
import { InfoData } from '../types/index';
import { useResponsiveStyles } from '../utils/responsive';

const InformationPanel: React.FC<InfoData> = ({ time, date, weather, wind }) => {
  const theme = useMantineTheme();
  const responsive = useResponsiveStyles();
  
  return (
    <Box
      style={{
        position: 'absolute',
        top: 'calc(12.5vh + 20px)',
        left: 'calc(15vw + 30px)',
        zIndex: 15,
        background: `${theme.colors.dark[8]}f0`,
        padding: `${responsive.padding} ${responsive.margin}`,
        borderRadius: responsive.borderRadius,
        border: `1px solid ${theme.colors.dark[5]}`,
        boxShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.dark[8]}`,
        backdropFilter: 'blur(12px)',
        minWidth: '200px',
        margin: responsive.smallMargin,
      }}
    >
      <Stack gap={responsive.smallMargin}>
        <Text 
          c="blue.4" 
          size={responsive.text.md} 
          fw={600}
          style={{
            textShadow: `0 0 ${Math.round(responsive.boxShadowBlur / 2)}px ${theme.colors.blue[4]}`,
          }}
        >
          {date}
        </Text>
        <Group gap={responsive.margin}>
          <Text c="white" size={responsive.text.sm} fw={400}>
            Time: <Text component="span" c="cyan.4" fw={500}>{time}</Text>
          </Text>
          <Text c="white" size={responsive.text.sm} fw={400}>
            Weather: <Text component="span" c="yellow.4" fw={500}>{weather}</Text>
          </Text>
          {wind !== undefined && (
            <Text c="white" size={responsive.text.sm} fw={400}>
              Wind: <Text component="span" c="gray.4" fw={500}>{wind} mph</Text>
            </Text>
          )}
        </Group>
      </Stack>
    </Box>
  );
};

export default InformationPanel;
