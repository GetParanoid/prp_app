import { Modal, Text, Button, Group, Stack, useMantineTheme } from '@mantine/core';
import { fetchNui } from '../utils/fetchNui';
import { isEnvBrowser } from '../utils/misc';
import { useResponsiveStyles } from '../utils/responsive';
import { IconCheck, IconX } from '@tabler/icons-react';

interface SpawnDecisionProps {
  visible: boolean;
  chosenData: { label: string; x: number; y: number; z: number };
  setVisible: (visible: boolean) => void;
  setChosenData: (data: { label: string; x: number; y: number; z: number }) => void;
}

const SpawnDecision: React.FC<SpawnDecisionProps> = ({ visible, chosenData, setVisible, setChosenData }) => {
  const theme = useMantineTheme();
  const responsive = useResponsiveStyles();
  
  const handleSpawn = () => {
    setVisible(false);
    if (isEnvBrowser()) {
      console.log('Browser mode: Spawning at', chosenData);
      alert(`Browser Debug: Spawned at ${chosenData.label} (${chosenData.x}, ${chosenData.y}, ${chosenData.z})`);
    } else {
      void fetchNui('spawnCharacter', chosenData);
      void fetchNui('hideFrame');
    }
  };

  const handleCancel = () => {
    setVisible(false);
    setChosenData({ label: '', x: 0, y: 0, z: 0 });
  };

  return (
    <Modal
      opened={visible}
      onClose={handleCancel}
      title={null}
      centered
      withCloseButton={false}
      size="md"
      styles={{
        content: {
          background: `${theme.colors.dark[8]}f8`,
          border: `1px solid ${theme.colors.dark[4]}`,
          borderRadius: responsive.borderRadius,
          boxShadow: `0 20px 40px ${theme.colors.dark[9]}80`,
          backdropFilter: 'blur(20px)',
        },
        body: {
          padding: responsive.padding,
        },
      }}
    >
      <Stack gap={responsive.margin} align="center">
        <Text
          size={responsive.text.lg}
          fw={600}
          c="white"
          ta="center"
        >
          Spawn at {chosenData.label}?
        </Text>

        <Group gap={responsive.margin}>
          <Button
            variant="light"
            color="green"
            size="md"
            leftSection={<IconCheck size={Math.round(responsive.iconSize * 0.8)} />}
            onClick={handleSpawn}
            style={{
              borderRadius: responsive.borderRadius,
              fontWeight: 500,
            }}
          >
            Confirm
          </Button>

          <Button
            variant="light"
            color="gray"
            size="md"
            leftSection={<IconX size={Math.round(responsive.iconSize * 0.8)} />}
            onClick={handleCancel}
            style={{
              borderRadius: responsive.borderRadius,
              fontWeight: 500,
            }}
          >
            Cancel
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
};

export default SpawnDecision;
