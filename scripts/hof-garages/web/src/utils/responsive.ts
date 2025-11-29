// Responsive scaling utilities for HUD Design System
export const BASE_WIDTH = 1920;
export const BASE_HEIGHT = 1080;

interface ResponsiveConfig {
  scaleFactor: number;
  screenWidth: number;
  screenHeight: number;
}

class ResponsiveSystem {
  private config: ResponsiveConfig;

  constructor() {
    this.config = this.calculateScaling();
    this.updateCSSProperties();
    
    // Update on window resize
    window.addEventListener('resize', () => {
      this.config = this.calculateScaling();
      this.updateCSSProperties();
    });
  }

  private calculateScaling(): ResponsiveConfig {
    const screenWidth = window.innerWidth;
    const screenHeight = window.innerHeight;
    
    // Calculate scale factor based on height (primary) with width constraints
    const heightScale = screenHeight / BASE_HEIGHT;
    const widthScale = screenWidth / BASE_WIDTH;
    
    // Use the smaller scale to ensure everything fits
    const scaleFactor = Math.min(heightScale, widthScale);
    
    return {
      scaleFactor: Math.max(0.5, Math.min(2.0, scaleFactor)), // Clamp between 0.5x and 2.0x
      screenWidth,
      screenHeight
    };
  }

  private updateCSSProperties(): void {
    const root = document.documentElement;
    root.style.setProperty('--scale-factor', this.config.scaleFactor.toString());
    root.style.setProperty('--border-radius', `${4 * this.config.scaleFactor}px`);
    root.style.setProperty('--box-shadow-blur', `${10 * this.config.scaleFactor}px`);
    root.style.setProperty('--padding', `${8 * this.config.scaleFactor}px`);
    root.style.setProperty('--margin', `${8 * this.config.scaleFactor}px`);
  }

  get scaleFactor(): number {
    return this.config.scaleFactor;
  }

  scaleVh(px: number): string {
    return `${(px / BASE_HEIGHT) * 100}vh`;
  }

  scaleVw(px: number): string {
    return `${(px / BASE_WIDTH) * 100}vw`;
  }

  scaleRem(px: number): string {
    return `${(px * this.config.scaleFactor) / 16}rem`;
  }

  scalePx(px: number): string {
    return `${px * this.config.scaleFactor}px`;
  }
}

// Export singleton instance
export const responsive = new ResponsiveSystem();

// Utility functions
export const scaleVh = (px: number): string => responsive.scaleVh(px);
export const scaleVw = (px: number): string => responsive.scaleVw(px);
export const scaleRem = (px: number): string => responsive.scaleRem(px);
export const scalePx = (px: number): string => responsive.scalePx(px);

// Glow effect utility
export const createGlow = (color: string, blur: number = 10): string => {
  const scaledBlur = Math.round(blur * responsive.scaleFactor);
  return `0 0 ${scaledBlur}px ${color}`;
};

// Color palette from HUD Design System
export const colors = {
  // Primary Colors
  primaryBg: '#1a1b1e',
  secondaryBg: '#25262b',
  surfaceBg: '#2c2e33',
  
  // Accent Colors
  bluePrimary: '#228be6',
  greenPrimary: '#51cf66',
  redPrimary: '#fa5252',
  yellowPrimary: '#ffd43b',
  cyanPrimary: '#22d3ee',
  
  // Text Colors
  textPrimary: '#ffffff',
  textDimmed: '#9ca3af',
  
  // Mantine Dark Theme Colors
  dark: {
    0: '#C1C2C5',
    1: '#A6A7AB',
    2: '#909296',
    3: '#5c5f66',
    4: '#373A40',
    5: '#2C2E33',
    6: '#25262b',
    7: '#1A1B1E',
    8: '#141517',
    9: '#101113'
  }
};
