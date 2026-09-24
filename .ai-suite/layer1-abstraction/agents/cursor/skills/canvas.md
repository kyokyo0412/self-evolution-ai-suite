---
name: canvas
description: Live interactive React app canvas beside the chat. Use when generating standalone analytical artifacts, dashboards, architecture reviews, visual data, tables, charts, or editing .canvas.tsx files.
metadata:
  surfaces:
    - ide
triggers:
  - canvas
---
# Cursor Canvas

Guides authoring live, interactive React apps rendered beside chat as standalone artifacts (`.canvas.tsx`).

## When to Use Canvas
- **Use:** Standalone analytical artifacts, quantitative breakdowns, cross-system audits, interactive tables, charts, and metrics summaries.
- **Do NOT Use:** Targeted code edits, brief answers, single-command outputs, or plain markdown deliverables.

## File Specifications
- **Target Path:** `/Users/<user>/.cursor/projects/<workspace>/canvases/<name>.canvas.tsx`.
- **Imports:** Import exclusively from `cursor/canvas`. No relative imports or external npm modules.
- **Structure:** Exactly one self-contained file with a default-exported React component.
- **Data:** Embed all data inline. Zero `fetch()` or network calls.
- **Styling:** Use tokens from `useHostTheme()`. Zero hardcoded hex colors or noisy gradients.

## Instructions & Canvas Workflow

1. **Verification of Need:** Confirm deliverable represents a standalone analytical or visual artifact.
2. **Path Resolution:** Locate project canvases directory and format kebab-case filename ending in `.canvas.tsx`.
3. **Component Implementation:** Author React component using `cursor/canvas` primitives with inline data.
4. **Validation:** Ensure every chart has clear titles, axis units, and legends. Omit empty states completely.

## Negative Constraints (Must NOT)
- [X] **Do not make network calls**: Never invoke `fetch()` or external APIs within a canvas.
- [X] **Do not render empty state placeholders**: If data is missing, prompt user instead of rendering placeholders.
- [X] **Do not import external npm packages**: Use only built-in primitives from `cursor/canvas`.
- [X] **Do not hardcode styling colors**: Consume tokens via `useHostTheme()`.
