# Workflow CLI Interface Contract

## Commands

### 1. Evolve
`./ai-suite workflow evolve`
- **Action**: Outputs the reflection prompt to the user. Then, analyzes `.ai-suite/layer4-evolutionary/reflection/evolutions/` for new markdown files, and commits them.

### 2. Absorb
`./ai-suite workflow absorb [--host USER@HOST --remote-path PATH | --local | --local-path PATH]`
- **Action**: 
  1. Calls `./absorb_fetch.sh` with the given arguments.
  2. Parses the `[ABSORB_SANDBOX]` output.
  3. Copies new skills from the sandbox into `.ai-suite/layer3-registry/core/` or similar.
  4. Generates an evolution report.

### 3. Integrate
`./ai-suite workflow integrate [--host USER@HOST --remote-path PATH]`
- **Action**:
  1. Creates a local temporary sandbox.
  2. Copies current `.ai-suite` skills into the sandbox in the target agent's structure.
  3. Calls `./integrate_push.sh` with `--push-sandbox <sandbox>`.
