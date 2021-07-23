import { NativeModules, Platform } from 'react-native';

const { DigitalWatermark } = NativeModules;

async function buildWatermark(iUri, text) {
  const res = await DigitalWatermark.buildWatermark(iUri, text);
  return res;
}

async function detectWatermark(iUri) {
  const res = await DigitalWatermark.detectWatermark(iUri);
  return res;
}

async function saveFile(iUri) {
  if (Platform.OS === 'android') {
    const res = await DigitalWatermark.saveFile(iUri);
    return res;
  } else {
    return Promise.reject('saveFile Android only');
  }
}

export default {
  buildWatermark,
  detectWatermark,
  saveFile,
};
