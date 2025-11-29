import { Box, Text, useMantineTheme, Flex, Avatar } from '@mantine/core';
import { useResponsiveStyles } from '../utils/responsive';
import { IconHome2 } from '@tabler/icons-react';

interface LastLocationButtonProps {
  onClick: () => void;
}

const LastLocationButton: React.FC<LastLocationButtonProps> = ({ onClick }) => {
  const theme = useMantineTheme();
  const responsive = useResponsiveStyles();
  
  return (
    <Box
      onClick={onClick}
      style={{
        position: 'absolute',
        bottom: 'calc(12.5vh + 15px)',
        left: '50%',
        transform: 'translateX(-50%)',
        zIndex: 15,
        background: `${theme.colors.dark[8]}f0`,
        borderRadius: responsive.borderRadius,
        border: `1px solid ${theme.colors.cyan[4]}`,
        boxShadow: `0 0 ${responsive.boxShadowBlur * 0.8}px ${theme.colors.cyan[4]}60`,
        backdropFilter: 'blur(10px)',
        cursor: 'pointer',
        transition: 'all 0.3s ease-out',
        padding: `${responsive.smallMargin} ${responsive.padding}`,
        minWidth: '160px',
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.boxShadow = `0 0 ${responsive.boxShadowBlur * 1.2}px ${theme.colors.cyan[4]}80`;
        e.currentTarget.style.background = `${theme.colors.dark[6]}f0`;
        e.currentTarget.style.transform = 'translateX(-50%) scale(1.05) translateY(-2px)';
        e.currentTarget.style.borderColor = theme.colors.cyan[3];
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.boxShadow = `0 0 ${responsive.boxShadowBlur * 0.8}px ${theme.colors.cyan[4]}60`;
        e.currentTarget.style.background = `${theme.colors.dark[8]}f0`;
        e.currentTarget.style.transform = 'translateX(-50%) scale(1) translateY(0px)';
        e.currentTarget.style.borderColor = theme.colors.cyan[4];
      }}
    >
      <Flex align="center" justify="center" gap={responsive.smallMargin}>
        <Avatar
          size={`calc(${responsive.avatarSize} * 0.6)`}
          radius="sm"
          variant="light"
          color="cyan"
          style={{
            background: theme.colors.dark[7],
            border: `1px solid ${theme.colors.cyan[4]}`,
            boxShadow: `0 0 ${responsive.boxShadowBlur * 0.3}px ${theme.colors.cyan[4]}`,
          }}
        >
          <IconHome2 size={Math.round(responsive.iconSize * 0.55)} color={theme.colors.cyan[4]} />
        </Avatar>

        <Text
          size={responsive.text.sm}
          fw={600}
          c="cyan.4"
          style={{ 
            lineHeight: 1,
            textAlign: 'center',
          }}
        >
          Last Location
        </Text>
      </Flex>
    </Box>
  );
};

export default LastLocationButton;
