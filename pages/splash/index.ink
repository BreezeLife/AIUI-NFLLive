<script def>
{ "navigationBarTitleText": "NFL Live", "description": "NFL Live cover. Tap to start or enter after five seconds. English first, with Japanese, Korean and Simplified Chinese. Prefer _blank; _current supported." }
</script>
<script setup>
import wx from 'wx';
import { strings } from '../../lib/i18n.js';
import { readSettings } from '../../lib/storage.js';
export default {
  data: { copy: strings('en'), remaining: 5 },
  onLoad() { this._dead = false; this._visible = false; this._focused = true; this._started = false; this._timer = null; this._remaining = 5000; const value = readSettings(wx).value; this.setData({ copy: strings(value.locale) }); },
  onShow() { this._visible = true; this.arm(); },
  onHide() { this.suspend(); this._visible = false; },
  onUnload() { this.suspend(); this._dead = true; },
  onHostFocus() { this._focused = true; this.arm(); }, onHostBlur() { this.suspend(); this._focused = false; },
  suspend() { if (this._timer !== null) clearTimeout(this._timer); this._timer = null; if (this._since) this._remaining = Math.max(0, this._remaining - (Date.now() - this._since)); this._since = null; },
  arm() { if (this._dead || !this._visible || !this._focused || this._started || this._timer !== null) return; this._since = Date.now(); this._timer = setTimeout(() => { this.suspend(); this.setData({ remaining: Math.ceil(this._remaining / 1000) }); if (this._remaining <= 0) this.start(); else this.arm(); }, Math.min(1000, this._remaining)); },
  start() { if (this._dead || !this._visible || !this._focused || this._started) return; this._started = true; this.suspend(); const fail = () => { this._started = false; this._remaining = 5000; this.setData({ remaining: 5 }); }; try { wx.redirectTo({ url: '/pages/home/index', fail }); } catch (_) { fail(); } },
  onKeyUp(event) { if (event.code === 'Enter') { event.preventDefault(); this.start(); } }
};
</script>
<page>
  <view class="splash" bindtap="start">
    <view class="top"><text>FIELD EDITION / 01</text><text>ROKID AIUI</text></view>
    <view class="center">
      <view class="logo"><view class="bars"><view class="bar one"></view><view class="bar two"></view><view class="bar three"></view></view><view class="word"><text class="nfl">NFL</text><text class="live">LIVE.</text></view></view>
      <text class="tagline">{{copy.tagline}}</text>
    </view>
    <view class="start"><text class="prompt">{{copy.start}}</text><text class="count">{{copy.auto}} {{remaining}}{{copy.sec}}</text></view>
    <text class="foot">SCORES · SCHEDULE · STANDINGS · DRIVE DETAIL</text>
  </view>
</page>
<style>
.splash { width:100%; height:100%; box-sizing:border-box; padding:16px 24px 12px; display:flex; flex-direction:column; background-color:#000; color:#00ff66; }
.top { display:flex; flex-direction:row; justify-content:space-between; font-family:monospace; font-size:10px; color:#00bc4b; }.center { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center; }.logo { display:flex; flex-direction:row; align-items:center; }.bars { height:102px; display:flex; flex-direction:row; align-items:flex-end; margin-right:18px; }.bar { width:11px; margin-right:5px; background-color:#00ff66; }.one { height:40px; background-color:#008f38; }.two { height:70px; background-color:#00c64f; }.three { height:102px; }.word { display:flex; flex-direction:column; }.nfl { font-size:47px; line-height:46px; font-weight:700; letter-spacing:4px; }.live { font-size:57px; line-height:56px; font-weight:700; }.tagline { font-size:16px; line-height:22px; margin-top:18px; color:#00d856; }.start { display:flex; flex-direction:column; align-items:center; }.prompt { font-family:monospace; font-size:22px; line-height:29px; }.count { font-size:12px; line-height:18px; margin-top:3px; color:#00bc4b; }.foot { text-align:center; font-family:monospace; font-size:10px; line-height:15px; margin-top:14px; color:#00bc4b; }
@media (target:_current) { .splash { padding:12px 16px; }.top { display:none; }.bars { height:68px; }.one { height:27px; }.two { height:46px; }.three { height:68px; }.bar { width:8px; margin-right:4px; }.nfl { font-size:32px; line-height:33px; }.live { font-size:40px; line-height:40px; }.tagline { font-size:14px; margin-top:10px; }.prompt { font-size:19px; }.foot { display:none; } }
</style>
