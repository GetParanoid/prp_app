import React from 'react';
import { Text, Box } from '@mantine/core';
import { IconBriefcase, IconBuildingBank, IconCalendarEvent, IconCashBanknote, IconFlag, IconGenderBigender } from '@tabler/icons-react';
import { responsive } from '../utils/responsive';

interface Props {
  icon: string;
  label: string;
}

const iconMap: { [key: string]: JSX.Element } = {
  gender: <IconGenderBigender size={responsive.scaleVh(12)} />,
  birthdate: <IconCalendarEvent size={responsive.scaleVh(12)} />,
  nationality: <IconFlag size={responsive.scaleVh(12)} />,
  bank: <IconBuildingBank size={responsive.scaleVh(12)} />,
  cash: <IconCashBanknote size={responsive.scaleVh(12)} />,
  job: <IconBriefcase size={responsive.scaleVh(12)} />
};

const getIconColor = (iconType: string): string => {
  const colorMap: { [key: string]: string } = {
    gender: 'var(--cyan-primary)',
    birthdate: 'var(--yellow-primary)', 
    nationality: 'var(--blue-primary)',
    bank: 'var(--green-primary)',
    cash: 'var(--green-primary)',
    job: 'var(--blue-primary)'
  };
  return colorMap[iconType] || 'var(--text-dimmed)';
};

const InfoCard: React.FC<Props> = (props) => {
  const icon = iconMap[props.icon];
  const iconColor = getIconColor(props.icon);

  return (
    <Box 
      className='character-card-charinfo'
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: `calc(6px * var(--scale-factor))`,
        padding: `calc(4px * var(--scale-factor)) calc(8px * var(--scale-factor))`,
        background: 'rgba(255, 255, 255, 0.05)',
        border: '1px solid rgba(255, 255, 255, 0.1)',
        borderRadius: 'calc(4px * var(--scale-factor))',
        transition: 'all 0.2s ease-out',
        backdropFilter: 'blur(5px)',
        '&:hover': {
          background: 'rgba(255, 255, 255, 0.08)',
          borderColor: iconColor,
          boxShadow: `0 0 calc(6px * var(--scale-factor)) ${iconColor}40`
        }
      }}
    >
      <Box style={{ 
        color: iconColor, 
        display: 'flex',
        filter: `drop-shadow(0 0 calc(5px * var(--scale-factor)) ${iconColor})`
      }}>
        {icon}
      </Box>
      <Text 
        size={responsive.scaleVh(11)} 
        c="var(--text-primary)"
        fw={500}
        style={{
          textShadow: '0 0 calc(2px * var(--scale-factor)) rgba(0, 0, 0, 0.5)'
        }}
      >
        {props.label}
      </Text>
    </Box>
  );
};

export default InfoCard;