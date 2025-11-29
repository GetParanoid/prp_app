import { useState, useEffect } from 'react';
import { Box, Text, Stack, useMantineTheme, ScrollArea, Group } from '@mantine/core';
import { fetchNui } from '../utils/fetchNui';
import { isEnvBrowser } from '../utils/misc';
import { useResponsiveStyles } from '../utils/responsive';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { IconHome, IconMapPin } from '@tabler/icons-react';

interface PlayerProperty {
  label: string;
  keyHolders: string[];
  id: number;
  type: string;
}

interface SpawnProps {
  visible: boolean;
}

const Spawn: React.FC<SpawnProps> = ({ visible }) => {
  const theme = useMantineTheme();
  const responsive = useResponsiveStyles();
  const [properties, setProperties] = useState<PlayerProperty[]>(
    isEnvBrowser() ? [
      {
        label: "Free Apartment",
        keyHolders: [],
        id: 1,
        type: "shell",
      },
      {
        label: "Luxury Apartment",
        keyHolders: ["player1", "player2"],
        id: 2,
        type: "apartment",
      },
      {
        label: "Mirror Park 1 ",
        keyHolders: [],
        id: 3,
        type: "house",
      },
      {
        label: "Mirror Park 2 ",
        keyHolders: [],
        id: 3,
        type: "house",
      },
      {
        label: "Mirror Park 3 ",
        keyHolders: [],
        id: 3,
        type: "house",
      },
      {
        label: "Mirror Park 4",
        keyHolders: [],
        id: 3,
        type: "house",
      },
      {
        label: "Mirror Park 5",
        keyHolders: [],
        id: 3,
        type: "house",
      },
      {
        label: "Mirror Park 6",
        keyHolders: [],
        id: 3,
        type: "house",
      },
    ] : []
  );
  const [loading, setLoading] = useState<boolean>(false);
  const [retryCount, setRetryCount] = useState<number>(0);
  const [error, setError] = useState<string | null>(null);

  //? Listen for property data from NUI
  useNuiEvent('setPlayerProperties', (data: PlayerProperty[]) => {
    console.log('[Spawn] Raw received data:', data, 'Type:', typeof data, 'IsArray:', Array.isArray(data));
    
    setLoading(false);
    setError(null);
    
    //? Ensure data is an array
    if (Array.isArray(data)) {
      setProperties(data);
    } else if (data && typeof data === 'object') {
      // Try to extract array from object
      const extractedArray = (data as any).properties || (data as any).data || Object.values(data) || [];
      console.log('[Spawn] Extracted array:', extractedArray);
      if (Array.isArray(extractedArray)) {
        setProperties(extractedArray);
      } else {
        console.warn('[Spawn] Could not extract array from object, using empty array');
        setProperties([]);
      }
    } else {
      console.warn('[Spawn] Received non-array data for properties:', data);
      setProperties([]);
    }
  });

  //? Listen for property loading errors from NUI
  useNuiEvent('propertyLoadError', (errorMessage: string) => {
    console.log('[Spawn] Property load error:', errorMessage);
    setLoading(false);
    setError(errorMessage);
    
    //? Retry up to 3 times with exponential backoff
    if (retryCount < 3) {
      const delay = Math.pow(2, retryCount) * 1000; // 1s, 2s, 4s
      setTimeout(() => {
        console.log(`[Spawn] Retrying property load (attempt ${retryCount + 1})`);
        setRetryCount(prev => prev + 1);
        setLoading(true);
        void fetchNui('getPlayerProperties');
      }, delay);
    }
  });

  //? Request properties when component is set visible
  useEffect(() => {
    if (visible && !isEnvBrowser()) {
      setLoading(true);
      setError(null);
      setRetryCount(0);
      void fetchNui('getPlayerProperties');
    }
  }, [visible]);

  const handleSpawnAtProperty = (property: PlayerProperty) => {
    if (isEnvBrowser()) {
      console.log('Browser mode: Spawning at property', property);
      alert(`Browser Debug: Spawned at ${property.label} (ID: ${property.id})`);
    } else {
      void fetchNui('spawnAtProperty', { id: property.id });
      //? Hide the main frame, player is spawned.
      void fetchNui('hideFrame');
    }
  };

  if (!visible) {
    return null;
  }

  //? Show loading icon
  if (loading) {
    return (
      <Box
        style={{
          position: 'absolute',
          left: `calc(50% + 35vw + ${parseFloat(responsive.margin)}px)`,
          top: '50%',
          transform: 'translateY(-50%)',
          width: Math.round(200 * responsive.scaleFactor),
          background: theme.colors.dark[8],
          border: `1px solid ${theme.colors.dark[5]}`,
          borderRadius: responsive.borderRadius,
          boxShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.dark[8]}`,
          backdropFilter: 'blur(20px)',
          padding: parseFloat(responsive.padding) * 0.75 + 'rem',
        }}
      >
        <Text 
          size={responsive.text.xs} 
          color={theme.colors.gray[3]} 
          ta="center"
          style={{ 
            fontWeight: 500,
            marginBottom: parseFloat(responsive.margin) 
          }}
        >
          Loading Properties...
        </Text>
      </Box>
    );
  }

  //? Show error
  if (error && !loading) {
    return (
      <Box
        style={{
          position: 'absolute',
          left: `calc(50% + 35vw + ${parseFloat(responsive.margin)}px)`,
          top: '50%',
          transform: 'translateY(-50%)',
          width: Math.round(200 * responsive.scaleFactor),
          background: theme.colors.dark[8],
          border: `1px solid ${theme.colors.red[6]}`,
          borderRadius: responsive.borderRadius,
          boxShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.red[9]}`,
          backdropFilter: 'blur(20px)',
          padding: parseFloat(responsive.padding) * 0.75 + 'rem',
        }}
      >
        <Text 
          size={responsive.text.xs} 
          color={theme.colors.red[4]} 
          ta="center"
          style={{ 
            fontWeight: 500,
            marginBottom: parseFloat(responsive.margin) 
          }}
        >
          {error}
        </Text>
        {retryCount < 3 && (
          <Text 
            size={responsive.text.xs} 
            color={theme.colors.gray[5]} 
            ta="center"
          >
            Retrying... ({retryCount + 1}/3)
          </Text>
        )}
      </Box>
    );
  }

  //? Show no properties
  if (!Array.isArray(properties) || properties.length === 0) {
    return (
      <Box
        style={{
          position: 'absolute',
          left: `calc(50% + 35vw + ${parseFloat(responsive.margin)}px)`,
          top: '50%',
          transform: 'translateY(-50%)',
          width: Math.round(200 * responsive.scaleFactor),
          background: theme.colors.dark[8],
          border: `1px solid ${theme.colors.dark[5]}`,
          borderRadius: responsive.borderRadius,
          boxShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.dark[8]}`,
          backdropFilter: 'blur(20px)',
          padding: parseFloat(responsive.padding) * 0.75 + 'rem',
        }}
      >
        <Text 
          size={responsive.text.xs} 
          color={theme.colors.gray[5]} 
          ta="center"
          style={{ 
            fontWeight: 500 
          }}
        >
          No Properties Owned
        </Text>
      </Box>
    );
  }

  return (
    <Box
      style={{
        position: 'absolute',
        left: `calc(50% + 35vw + ${parseFloat(responsive.margin)}px)`,
        top: '50%',
        transform: 'translateY(-50%)',
        width: Math.round(200 * responsive.scaleFactor),
        maxHeight: '50vh',
        background: theme.colors.dark[8],
        border: `1px solid ${theme.colors.dark[5]}`,
        borderRadius: responsive.borderRadius,
        boxShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.dark[8]}`,
        backdropFilter: 'blur(20px)',
        padding: parseFloat(responsive.padding) * 0.75 + 'rem',
        zIndex: 100,
      }}
    >
      <Group mb={parseFloat(responsive.smallMargin) * 0.5} gap={parseFloat(responsive.smallMargin) * 0.7}> {/* Reduced margins and gap */}
        <Box
          style={{
            background: theme.colors.blue[4],
            borderRadius: responsive.borderRadius,
            padding: parseFloat(responsive.smallMargin) * 0.6,
            boxShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.blue[4]}40`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <IconHome 
            size={Math.round(responsive.iconSize * 0.8)}
            color="white"
            style={{
              filter: `drop-shadow(0 0 ${responsive.boxShadowBlur / 2}px white)`,
            }}
          />
        </Box>
        <Text
          size={responsive.text.xs}
          fw={600}
          c={theme.colors.dark[0]}
          style={{
            fontFamily: theme.fontFamily,
            letterSpacing: '0.3px',
            textTransform: 'uppercase',
            textShadow: `0 0 ${responsive.boxShadowBlur / 2}px ${theme.colors.blue[4]}40`,
          }}
        >
          My Properties
        </Text>
      </Group>

      <ScrollArea 
        h={`${Math.min(properties.length * Math.round(40 * responsive.scaleFactor) + 15, Math.round(280 * responsive.scaleFactor))}px`}
        scrollbarSize={Math.round(4 * responsive.scaleFactor)}
        styles={{
          scrollbar: {
            '&[data-orientation="vertical"]': {
              backgroundColor: theme.colors.dark[7],
              borderRadius: responsive.borderRadius,
              border: `1px solid ${theme.colors.dark[5]}`,
            },
            '&[data-orientation="vertical"] .mantine-ScrollArea-thumb': {
              backgroundColor: theme.colors.blue[4],
              borderRadius: responsive.borderRadius,
              border: 'none',
              boxShadow: `0 0 ${responsive.boxShadowBlur / 2}px ${theme.colors.blue[4]}80`,
              transition: 'all 0.3s ease-out',
              '&:hover': {
                backgroundColor: theme.colors.blue[3],
                boxShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.blue[4]}`,
              },
            },
          },
        }}
      >
        <Stack gap={parseFloat(responsive.smallMargin) * 0.5}>
          {(properties || []).map((property) => (
            <Box
              key={property.id}
              style={{
                background: theme.colors.dark[6],
                border: `1px solid ${theme.colors.dark[5]}`,
                borderRadius: responsive.borderRadius,
                padding: `${parseFloat(responsive.padding) * 0.5}rem`,
                transition: 'all 0.3s ease-out',
                cursor: 'pointer',
                position: 'relative',
                overflow: 'visible',
                marginRight: Math.round(responsive.iconSize * 0.15),
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.background = theme.colors.dark[5];
                e.currentTarget.style.borderColor = theme.colors.blue[4];
                e.currentTarget.style.boxShadow = `0 0 ${responsive.boxShadowBlur}px ${theme.colors.blue[4]}40`;
                e.currentTarget.style.transform = 'translateX(4px)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = theme.colors.dark[6];
                e.currentTarget.style.borderColor = theme.colors.dark[5];
                e.currentTarget.style.boxShadow = 'none';
                e.currentTarget.style.transform = 'translateX(0px)';
              }}
            >
              <Box
                style={{
                  position: 'absolute',
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: '2px',
                  background: `linear-gradient(180deg, ${theme.colors.blue[4]}00, ${theme.colors.blue[4]}, ${theme.colors.blue[4]}00)`,
                  boxShadow: `0 0 ${responsive.boxShadowBlur / 2}px ${theme.colors.blue[4]}`,
                }}
              />
              
              <Group justify="space-between" align="center" wrap="nowrap">
                <Text
                  size={responsive.text.xs}
                  fw={500}
                  c={theme.colors.dark[0]}
                  style={{
                    fontFamily: theme.fontFamily,
                    flex: 1,
                    paddingLeft: parseFloat(responsive.smallMargin) * 0.5,
                    minWidth: 0,
                  }}
                  lineClamp={1}
                >
                  {property.label}
                </Text>
                
                <Box
                  style={{
                    position: 'relative',
                    width: Math.round(responsive.iconSize * 1.2),
                    height: Math.round(responsive.iconSize * 1.2),
                    borderRadius: responsive.borderRadius,
                    background: theme.colors.blue[4],
                    boxShadow: `0 0 ${responsive.boxShadowBlur}px ${theme.colors.blue[4]}40`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                    transition: 'all 0.3s ease-out',
                    marginLeft: parseFloat(responsive.smallMargin),
                    flexShrink: 0,
                    zIndex: 2,
                  }}
                  onClick={(e) => {
                    e.stopPropagation();
                    handleSpawnAtProperty(property);
                  }}
                  onMouseEnter={(e) => {
                    e.stopPropagation();
                    e.currentTarget.style.transform = 'scale(1.08)';
                    e.currentTarget.style.boxShadow = `0 0 ${responsive.boxShadowBlur * 1.3}px ${theme.colors.blue[4]}80`;
                    e.currentTarget.style.background = theme.colors.blue[3];
                  }}
                  onMouseLeave={(e) => {
                    e.stopPropagation();
                    e.currentTarget.style.transform = 'scale(1)';
                    e.currentTarget.style.boxShadow = `0 0 ${responsive.boxShadowBlur}px ${theme.colors.blue[4]}40`;
                    e.currentTarget.style.background = theme.colors.blue[4];
                  }}
                >
                  <IconMapPin 
                    size={Math.round(responsive.iconSize * 0.5)}
                    color="white"
                    style={{
                      filter: `drop-shadow(0 0 ${responsive.boxShadowBlur / 4}px white)`,
                      pointerEvents: 'none',
                    }}
                  />
                </Box>
              </Group>
            </Box>
          ))}
        </Stack>
      </ScrollArea>
    </Box>
  );
};

export default Spawn;
