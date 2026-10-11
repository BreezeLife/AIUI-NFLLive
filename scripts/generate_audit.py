import hashlib, importlib.util, json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKILL = Path(sys.argv[1] if len(sys.argv) > 1 else '/Users/weiqi/.codex/skills/rokid-aiui-agent')
out = ROOT / '.aiui-evidence'; out.mkdir(exist_ok=True)
spec = importlib.util.spec_from_file_location('audit_contracts', SKILL / 'scripts/validate_aiui_audit.py')
contracts = importlib.util.module_from_spec(spec); sys.modules[spec.name] = contracts; spec.loader.exec_module(contracts)
report = json.loads((out / 'inventory.json').read_text())
layers_order = ('SOURCE', 'STATIC', 'LOGIC', 'AIX', 'STUDIO', 'DEVICE')
def ordered(layers): return tuple(layer for layer in layers_order if layer in layers)
def blocked(layers):
    reasons = {'SOURCE':'selected-version official support inspection not captured for this row','STATIC':'local structural checks lack external RUNNER attestation','LOGIC':'trusted current-revision LOGIC capture unavailable','AIX':'trusted current-revision AIX capture unavailable','STUDIO':'authenticated selected-runtime Studio capture unavailable','DEVICE':'physical Rokid device and authenticated capture unavailable'}
    return '; '.join(f'{layer}=blocked:{reasons[layer]}' for layer in layers)
def table(header, rows):
    esc = lambda v: str(v).replace('\\','\\\\').replace('|','\\|')
    return '\n'.join('| ' + ' | '.join(esc(c) for c in row) + ' |' for row in [header, tuple('---' for _ in header), *rows])

ux_rows, cap_rows, required, blocked_ids = [], [], [], []
default_gates = {'UX-TARGET':'all-targets','UX-STATE':'all-states','UX-TEXT':'boundary-text','UX-FOCUS':'focus-model','UX-RECOVERY':'failure-recovery','UX-LIFECYCLE':'page-lifecycle','UX-VISUAL':'visual-system','UX-ENVIRONMENT':'optical-scenes','UX-MOTION':'motion-performance'}
for family, required_layers in contracts.UX_REQUIRED_LAYERS.items():
    ls = ordered(required_layers)
    gates = [x['gate'] for x in report['inputGates']] if family == 'UX-INPUT' else [default_gates[family]]
    surface, risk, criterion = contracts.UX_CONTRACTS[family]
    for index, gate in enumerate(gates, 1):
        ident = f'{family}-GATE{index}' if len(gates) > 1 else family
        ux_rows.append([f'[{ident}] {{gate={gate}}}', surface, risk, f'{{contract={contracts.UX_CONTRACT_TOKENS[family]}}} {criterion}', ', '.join(ls), 'BLOCKED', blocked(ls)])
        blocked_ids.append(ident); required.extend(f'{ident}@{layer}' for layer in ls)

for claim in report['claimedCapabilities']:
    item = next(x for x in report['items'] if f"{x['family']}@{x['gate']}" == claim)
    family, gate = item['family'], item['gate']; policy = contracts.CAPABILITY_POLICIES[family]
    if family == 'project.unregistered': ident = 'CAP-UNREGISTERED-' + gate.removeprefix('unregistered-').upper(); label = 'Unregistered project capability'
    else: ident = f"{policy.base_id}-{hashlib.sha256(gate.encode()).hexdigest()[:12].upper()}"; label = family.replace('.', ' ').replace('-', ' ').capitalize()
    ls = ordered(policy.layers)
    sources = '; '.join(f'{role}=[{role.lower()}]({url})' for role, url in sorted(contracts.CAPABILITY_SOURCE_POLICIES[family]))
    behavior = [contracts.capability_contract_cell(family, path, desc) for path, desc in zip(('positive','negative-fallback','lifecycle-cleanup'), contracts.CAPABILITY_BEHAVIOR_CONTRACTS[family])]
    mechanism = item.get('mechanism', '')
    if mechanism.startswith('CLAIM:') and '@' in mechanism:
        surface = mechanism.split('@', 1)[1].split(':', 1)[0]
    elif mechanism.startswith('target:'):
        surface = mechanism.split(':', 1)[1]
    else:
        surface = ','.join(report['supportedSurfaces']) or 'UNAVAILABLE'
    cap_rows.append([f'[{ident}] {{family={family}}} {{gate={gate}}} {label}', f"AIUI 0.17.0; device=UNAVAILABLE; surface={surface}", item['apiBinding'], item['declarationBinding'], sources, *behavior, ', '.join(ls), 'BLOCKED', blocked(ls)])
    blocked_ids.append(ident); required.extend(f'{ident}@{layer}' for layer in ls)

metadata = [f"Project revision: {report['projectRevision']}", 'Canonical version: AIUI 0.17.0', 'Import root: .', 'Device/host: UNAVAILABLE', 'Supported surfaces: ' + ','.join(report['supportedSurfaces']), 'Inputs: ' + ','.join(sorted(f"{x['kind']}@{x['gate']}" for x in report['inputGates'])), 'Claimed capabilities: ' + ','.join(report['claimedCapabilities'])]
audit = '\n'.join(metadata) + '\n\n## Project UX evidence matrix\n\n' + table(contracts.UX_HEADERS, ux_rows) + '\n\n## Per-capability matrix\n\n' + table(contracts.CAPABILITY_HEADERS, cap_rows) + '\n\n## Final release decision\n\nFinal status: BLOCKED\nRelease-ready: NO\nReason: FAIL=[none]; BLOCKED=[' + ','.join(sorted(blocked_ids)) + ']\nRequired gates: ' + ','.join(sorted(required)) + '\n'
(out / 'AIUI-AUDIT.md').write_text(audit)
print(f'Generated {len(ux_rows)} UX rows and {len(cap_rows)} capability rows.')
