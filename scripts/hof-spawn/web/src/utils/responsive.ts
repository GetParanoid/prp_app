/**
 * Responsive scaling utility
 * Scales values based on screen resolution relative to a base resolution (1080p)
 */

const BASE_HEIGHT = 1080;

/**
 * Get the current screen height scale factor relative to 1080p
 */
export const getScaleFactor = (): number => {
  return window.innerHeight / BASE_HEIGHT;
};

/**
 * Scale a pixel value based on current screen resolution
 * @param baseValue - The base value designed for 1080p
 * @returns Scaled value for current resolution
 */
export const scaleValue = (baseValue: number): number => {
  return baseValue * getScaleFactor();
};

/**
 * Scale a rem value based on current screen resolution
 * @param remValue - The base rem value designed for 1080p
 * @returns Scaled rem value as string
 */
export const scaleRem = (remValue: number): string => {
  return `${remValue * getScaleFactor()}rem`;
};

/**
 * Scale pixel values and return as px string
 * @param baseValue - The base pixel value designed for 1080p
 * @returns Scaled pixel value as string
 */
export const scalePx = (baseValue: number): string => {
  return `${scaleValue(baseValue)}px`;
};

/**
 * Create responsive styles object with commonly used scaled values
 */
export const useResponsiveStyles = () => {
  const scaleFactor = getScaleFactor();
  
  return {
    scaleFactor,
    iconSize: Math.round(24 * scaleFactor), // Base icon size 24px
    avatarSize: scaleRem(2.5), // Base avatar size 2.5rem
    padding: scaleRem(0.46), // Base padding 0.46rem
    margin: scalePx(8), // Base margin 8px
    smallMargin: scalePx(4), // Base small margin 4px
    borderRadius: Math.max(4, Math.round(4 * scaleFactor)), // Minimum 4px radius
    boxShadowBlur: Math.round(10 * scaleFactor),
    // Text sizes scaled for responsiveness
    text: {
      xs: scaleRem(0.75),    // 12px base
      sm: scaleRem(0.875),   // 14px base  
      md: scaleRem(1),       // 16px base
      lg: scaleRem(1.125),   // 18px base
      xl: scaleRem(1.25),    // 20px base
      xxl: scaleRem(1.5),    // 24px base
    }
  };
};
