const KEY = 'nfl-live.preferences.v1';
let memory = { locale: 'en', tab: 'scores', source: 'live' };
let sessionOnly = false;

export function normalize(value = {}) {
  return {
    locale: ['en', 'ja', 'ko', 'zh'].includes(value.locale) ? value.locale : 'en',
    tab: ['scores', 'schedule', 'standings', 'detail'].includes(value.tab) ? value.tab : 'scores',
    source: value.source === 'demo' ? 'demo' : 'live'
  };
}

export function readSettings(wx) {
  if (sessionOnly || !wx || typeof wx.getStorageSync !== 'function') return { value: { ...memory }, warning: sessionOnly };
  try {
    const raw = wx.getStorageSync(KEY);
    if (raw) memory = normalize(typeof raw === 'string' ? JSON.parse(raw) : raw);
    return { value: { ...memory }, warning: false };
  } catch (_) { return { value: { ...memory }, warning: true }; }
}

export function saveSettings(wx, value) {
  memory = normalize(value);
  if (!wx || typeof wx.setStorageSync !== 'function') return true;
  try { wx.setStorageSync(KEY, JSON.stringify(memory)); sessionOnly = false; return true; }
  catch (_) { sessionOnly = true; return false; }
}
