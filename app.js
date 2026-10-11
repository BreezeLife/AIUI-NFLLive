import { readSettings } from './lib/storage.js';

export default {
  globalData: {
    name: 'NFL Live',
    version: '1.0.0',
    api: 'ESPN public NFL JSON feeds'
  },
  onLaunch() {
    // Reading once validates that the storage adapter is available on this host.
    this.globalData.preferences = readSettings().value;
  }
};
