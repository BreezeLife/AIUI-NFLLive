<script def>
{ "navigationBarTitleText": "NFL Live Settings", "description": "Choose English, Japanese, Korean or Simplified Chinese, and switch between ESPN live data and a local demo snapshot. Prefer _blank; _current supported." }
</script>
<script setup>
import wx from 'wx';
import { strings, languages } from '../../lib/i18n.js';
import { readSettings, saveSettings } from '../../lib/storage.js';
export default {
  data: { copy: strings('en'), locale: 'en', source: 'live', note: '', languages },
  onLoad() { this._dead = false; this._visible = false; this._focused = true; const stored = readSettings(wx); this._config = stored.value; this.setData({ ...stored.value, copy: strings(stored.value.locale), note: stored.warning ? strings(stored.value.locale).storage : '' }); },
  onShow() { this._visible = true; }, onHide() { this._visible = false; }, onUnload() { this._dead = true; this._visible = false; },
  onHostFocus() { this._focused = true; }, onHostBlur() { this._focused = false; },
  active() { return this._visible && this._focused && !this._dead; },
  changeLanguage(event) { const locale = event?.currentTarget?.dataset?.locale; if (!['en', 'ja', 'ko', 'zh'].includes(locale) || !this.active()) return; this._config = { ...this._config, locale }; const ok = saveSettings(wx, this._config); this.setData({ locale, copy: strings(locale), note: ok ? '' : strings(locale).storage }); },
  live() { this.changeSource('live'); }, demo() { this.changeSource('demo'); },
  changeSource(source) { if (!this.active()) return; this._config = { ...this._config, source }; const ok = saveSettings(wx, this._config); this.setData({ source, note: ok ? '' : this.data.copy.storage }); },
  back() { if (!this.active()) return; try { wx.navigateBack({ delta: 1 }); } catch (_) { try { wx.redirectTo({ url: '/pages/home/index' }); } catch (__) {} } }
};
</script>
<page>
  <view class="settings"><view class="heading"><text class="title">{{copy.settings}}</text><button bindtap="back">{{copy.back}}</button></view><text class="label">{{copy.language}}</text><view class="languages" role="navigation"><button ink:for="{{languages}}" ink:key="code" class="language {{locale === item.code ? 'selected' : ''}}" data-locale="{{item.code}}" bindtap="changeLanguage">{{item.label}}</button></view><text class="label source-label">{{copy.source}}</text><view class="sources"><button class="source {{source === 'live' ? 'selected' : ''}}" bindtap="live">{{copy.liveFeed}}</button><button class="source {{source === 'demo' ? 'selected' : ''}}" bindtap="demo">{{copy.demoFeed}}</button></view><text class="help">{{copy.note}}</text><text class="note">{{note}}</text><text class="foot">NFL LIVE · ESPN PUBLIC JSON · READ ONLY</text></view>
</page>
<style>
.settings { width:100%; height:100%; box-sizing:border-box; padding:12px 16px; display:flex; flex-direction:column; background-color:#000; color:#00ff66; }.heading { display:flex; flex-direction:row; align-items:center; justify-content:space-between; }.title { font-size:22px; line-height:28px; font-weight:700; }.heading button { font-size:13px; min-height:29px; }.label { display:block; margin-top:22px; margin-bottom:8px; font-size:12px; color:#00d856; }.languages { display:flex; flex-direction:row; flex-wrap:wrap; }.language { width:48%; margin:0 2% 9px 0; padding:10px 7px; font-size:18px; line-height:23px; }.language:nth-child(2n) { margin-right:0; }.selected { border-color:#00ff66; background-color:#001f0d; font-weight:700; }.source-label { margin-top:18px; }.sources { display:flex; flex-direction:row; }.source { flex:1; margin-right:7px; padding:8px 5px; font-size:13px; line-height:20px; }.source:last-child { margin-right:0; }.help { margin-top:18px; font-size:12px; line-height:18px; color:#00bc4b; }.note { margin-top:8px; font-size:11px; color:#00ff66; }.foot { margin-top:auto; font-family:monospace; font-size:10px; line-height:15px; color:#00bc4b; }
@media (target:_current) { .settings { padding:10px 16px; }.title { font-size:18px; }.label { margin-top:12px; }.language { padding:7px; font-size:16px; }.help { margin-top:10px; font-size:11px; }.foot { display:none; } }
</style>
