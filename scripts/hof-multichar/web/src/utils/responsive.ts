// Responsive scaling utilities
// Base resolution: 1080p (1920x1080)

const BASE_HEIGHT = 1080;
const BASE_WIDTH = 1920;

interface ResponsiveConfig {
  scaleFactor: number;
  isMobile: boolean;
  isTablet: boolean;
  isDesktop: boolean;
}

class ResponsiveManager {
  private config: ResponsiveConfig;
  private listeners: (() => void)[] = [];

  constructor() {
    this.config = this.calculateConfig();
    this.setupListeners();
    this.updateCSSVariables();
  }

  private calculateConfig(): ResponsiveConfig {
    const height = window.innerHeight;
    const width = window.innerWidth;
    const scaleFactor = height / BASE_HEIGHT;

    return {
      scaleFactor,
      isMobile: width < 768,
      isTablet: width >= 768 && width < 1024,
      isDesktop: width >= 1024,
    };
  }

  private setupListeners() {
    window.addEventListener('resize', this.handleResize.bind(this));
  }

  private handleResize() {
    this.config = this.calculateConfig();
    this.updateCSSVariables();
    this.listeners.forEach(listener => listener());
  }

  private updateCSSVariables() {
    const root = document.documentElement;
    root.style.setProperty('--scale-factor', this.config.scaleFactor.toString());
    root.style.setProperty('--border-radius', `${8 * this.config.scaleFactor}px`);
    root.style.setProperty('--box-shadow-blur', `${10 * this.config.scaleFactor}px`);
    root.style.setProperty('--padding', `${20 * this.config.scaleFactor}px`);
  }

  public getConfig(): ResponsiveConfig {
    return { ...this.config };
  }

  public subscribe(callback: () => void) {
    this.listeners.push(callback);
    return () => {
      this.listeners = this.listeners.filter(listener => listener !== callback);
    };
  }

  public scaleVh(px: number): string {
    return `${(px / BASE_HEIGHT) * 100}vh`;
  }

  public scaleVw(px: number): string {
    return `${(px / BASE_WIDTH) * 100}vw`;
  }

  public scaleRem(px: number): string {
    return `${(px / 16) * this.config.scaleFactor}rem`;
  }

  public createGlow(color: string, blur: number = 10): string {
    const scaledBlur = Math.round(blur * this.config.scaleFactor);
    return `0 0 ${scaledBlur}px ${color}`;
  }
}

// Export singleton instance
export const responsive = new ResponsiveManager();

// React import for the hook
import React from 'react';

// Utility functions
export const scaleVh = (px: number): string => responsive.scaleVh(px);
export const scaleVw = (px: number): string => responsive.scaleVw(px);
export const scaleRem = (px: number): string => responsive.scaleRem(px);
export const createGlow = (color: string, blur?: number): string => responsive.createGlow(color, blur);

// React hook for responsive updates
export const useResponsive = () => {
  const [config, setConfig] = React.useState(responsive.getConfig());

  React.useEffect(() => {
    const unsubscribe = responsive.subscribe(() => {
      setConfig(responsive.getConfig());
    });
    return unsubscribe;
  }, []);

  return config;
};
