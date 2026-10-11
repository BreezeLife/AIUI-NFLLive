import test from 'node:test';
import assert from 'node:assert/strict';
import { normalizeScoreboard, normalizeStandings } from '../lib/nfl.js';
import { normalize } from '../lib/storage.js';

test('normalizes ESPN scoreboard with quarter scores and status', () => {
  const result = normalizeScoreboard({ season: { year: 2026 }, week: { number: 5 }, events: [{ id: '1', shortName: 'A @ H', competitions: [{ status: { type: { state: 'in', shortDetail: '2nd · 4:18' }, period: 2 }, venue: { fullName: 'Field' }, competitors: [{ homeAway: 'home', team: { abbreviation: 'H', displayName: 'Home' }, score: '17', linescores: [{ displayValue: '7' }, { displayValue: '10' }] }, { homeAway: 'away', team: { abbreviation: 'A', displayName: 'Away' }, score: '14', linescores: [{ displayValue: '7' }, { displayValue: '7' }] }] }] }] });
  assert.equal(result.week, 5); assert.equal(result.games[0].live, true); assert.deepEqual(result.games[0].home.linescores, ['7', '10']);
});

test('normalizes standings groups', () => {
  const result = normalizeStandings({ children: [{ abbreviation: 'AFC', standings: { entries: [{ team: { abbreviation: 'KC', displayName: 'Kansas City Chiefs' }, stats: [{ type: 'wins', displayValue: '4' }, { type: 'losses', displayValue: '1' }, { type: 'winpercent', displayValue: '.800' }] }] } }] });
  assert.equal(result[0].entries[0].record, '4-1'); assert.equal(result[0].entries[0].pct, '.800');
});

test('storage normalization closes unsupported preference values', () => {
  assert.deepEqual(normalize({ locale: 'xx', tab: 'bad', source: 'anything' }), { locale: 'en', tab: 'scores', source: 'live' });
});
