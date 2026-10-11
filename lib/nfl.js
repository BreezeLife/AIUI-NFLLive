export const SCOREBOARD = 'https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard';
export const STANDINGS = 'https://site.api.espn.com/apis/v2/sports/football/nfl/standings';
const clean = value => String(value || '').replace(/[\x00-\x1f\x7f]/g, ' ').replace(/\s+/g, ' ').trim();

function team(competitor) {
  const info = competitor.team || {};
  return { id: info.id || competitor.id, abbr: info.abbreviation || info.shortDisplayName || 'TBD', name: info.displayName || info.name || 'TBD', score: Number(competitor.score || 0), linescores: (competitor.linescores || []).map(line => line.displayValue ?? String(line.value ?? 0)), record: (competitor.records || []).find(r => r.type === 'total')?.summary || '' };
}
export function normalizeScoreboard(payload) {
  const events = Array.isArray(payload?.events) ? payload.events : [];
  return { season: payload?.season?.year || new Date().getFullYear(), week: payload?.week?.number || '', games: events.map(event => {
    const competition = event.competitions?.[0] || {}; const teams = (competition.competitors || []).map(team); const home = teams.find((_, i) => competition.competitors[i]?.homeAway === 'home') || teams[0] || team({}); const away = teams.find((_, i) => competition.competitors[i]?.homeAway === 'away') || teams[1] || team({});
    const status = competition.status || event.status || {}; const state = status.type?.state || 'pre';
    return { id: event.id || competition.id, date: event.date || competition.date, shortName: event.shortName || '', home, away, venue: competition.venue?.fullName || '', city: competition.venue?.address?.city || '', state, status: status.type?.shortDetail || status.type?.detail || '', clock: status.displayClock || '', period: status.period || 0, live: state === 'in', final: state === 'post', recent: Boolean(competition.recent), broadcast: competition.broadcasts?.[0]?.names?.[0] || '' };
  }) };
}
export function normalizeStandings(payload) {
  const groups = [];
  for (const child of payload?.children || []) {
    const entries = (child.standings?.entries || []).map((entry, index) => { const stats = Object.fromEntries((entry.stats || []).map(stat => [stat.type, stat.displayValue])); return { rank: stats.playoffseed || String(index + 1), name: entry.team?.displayName || entry.team?.name || 'Team', abbr: entry.team?.abbreviation || '', record: stats.wins !== undefined ? `${stats.wins}-${stats.losses || 0}${stats.ties && stats.ties !== '0' ? `-${stats.ties}` : ''}` : entry.stats?.find(s => s.type === 'total')?.displayValue || '', pct: stats.winpercent || stats.winPct || '' }; });
    groups.push({ name: child.abbreviation || child.name || '', entries });
  }
  return groups;
}
export function demoData() { return { season: 2026, week: 5, games: [{ id: 'demo-1', shortName: 'BUF @ KC', date: new Date().toISOString(), venue: 'Arrowhead Stadium', city: 'Kansas City', state: 'in', status: '2nd · 04:18', clock: '4:18', period: 2, live: true, final: false, home: { abbr: 'KC', name: 'Kansas City Chiefs', score: 17, linescores: ['7', '10'], record: '4-1' }, away: { abbr: 'BUF', name: 'Buffalo Bills', score: 14, linescores: ['7', '7'], record: '3-2' } }] }; }
export function request(wx, url) { return new Promise((resolve, reject) => { if (!wx?.request) return reject(new Error('request unavailable')); let settled = false; const finish = (fn, value) => { if (settled) return; settled = true; fn(value); }; try { wx.request({ url, method: 'GET', timeout: 12000, success: res => res?.data ? finish(resolve, res.data) : finish(reject, new Error('empty response')), fail: err => finish(reject, err || new Error('network failure')) }); } catch (error) { finish(reject, error); } }); }
