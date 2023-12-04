import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.example.timemanager',
  appName: 'timemanager',
  webDir: 'dist',
  server: {
    androidScheme: 'http'
  }
};

export default config;
