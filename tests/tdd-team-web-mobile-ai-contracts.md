# Architecture & Specification Contract: Web/Mobile Application & AI-Augmented Workflow for TDD Team

## 1. Overview & Roster Expansion

The enhanced `tdd-team` skill extends its distinguished autonomous engineering team to natively support building beautiful, user-friendly, accessible, and logically sound Web and Mobile applications powered by an AI-augmented workflow.

### 1.1 Extended Senior Roster

1. **Principal UX/UI Product Designer & Design Systems Architect**
   - **Competencies**: Digital product aesthetics, human-computer interaction (HCI), design tokens, micro-interactions, responsive & mobile-first layouts, typography scales, cohesive color palettes (WCAG AAA contrast), spacing grids (e.g., 4px/8px), animation easing, and multi-state interactive feedback (hover, focus-visible, active, disabled, skeleton loaders). Proposes complete design system before implementation.
2. **Principal Frontend & Mobile Solutions Architect**
   - **Competencies**: Modern application architectures (React/Next.js, Vue/Nuxt, React Native/Flutter/iOS/Android), state management topology (Zustand, Redux Toolkit, TanStack Query), dumb/presentational vs smart/container component separation, custom hook logic isolation, bundle size budget, client-side caching, SSR/SSG/ISR, offline-first syncing, and mobile touch targets. Recommends the best modern tech stack to implement designs efficiently.
3. **Principal AI-Augmented Workflow & Interaction Engineer**
   - **Competencies**: AI-augmented interaction patterns (token streaming visualization, optimistic UI updates, multi-modal inputs, progressive generative rendering, human-in-the-loop validation checkpoints, graceful AI degradation, latency masking, and conversational/copilot UX primitives).

---

## 2. Team Persona & UI/UX Design System Standards

When generating or modifying frontend and mobile code, the virtual team strictly adheres to the following core tenets:

1. **Aesthetics**: Always default to modern, clean, and minimalist UI patterns. Use subtle shadows, rounded corners (e.g., `rounded-lg`/`rounded-xl`), and ample whitespace (padding/margin).
2. **Usability & Touch Ergonomics**: Ensure all interactive elements have clear visual feedback (hover, focus, and active states), with accessible mobile touch targets (>= 44x44px).
3. **Logic & Separation of Concerns**: Keep UI components "dumb" (pure presentation) and separate business logic into custom hooks or state management files.
4. **Accessibility (a11y)**: Always include `aria-labels`, semantic HTML/components, high color contrast (WCAG AA/AAA), and screen reader support.
5. **Consistency & Design Tokens**: Never introduce new colors or fonts outside of the defined `tailwind.config` or theme file / design token system.
6. **AI-Augmented Workflow Patterns**: Optimistic UI updates, progressive streaming indicators, generative skeleton loaders, error boundary fallbacks, and human-in-the-loop review states.

---

## 3. Stage-Gated Phase Enhancements

### Phase 1: Product Design & Requirements Loop
- **Design System Proposition**: Principal UX/UI Designer proposes color palette, typography hierarchy, spacing rules, and interaction states.
- **AI Workflow Mapping**: Principal AI Interaction Engineer maps streaming states, generative loading boundaries, and human validation checkpoints.

### Phase 2: Architectural Validation Loop
- **Tech Stack Recommendation**: Principal Frontend Architect recommends framework, styling library, and state management library.
- **Component & Hook Contract**: Principal Frontend Architect defines dumb/smart component hierarchy, custom hook signatures, and state stores.

### Phase 3: TDD Implementation Loop
- **RED**: Senior SDET writes component rendering, interaction state, accessibility, and hook logic tests.
- **GREEN**: Developer implements minimal dumb UI components and isolated custom hooks adhering to theme tokens.
- **REFACTOR & CLEANUP**: Enforce clean design tokens, zero arbitrary styling, and run `ReadLints`.
- **Review**: Chief Reviewer conducts 7-dimension line-level audit plus UI/UX fidelity, WCAG accessibility, and hook separation verification.

### Phase 4: End-to-End System QA Gate
- Senior SDET tests cross-device viewports, touch interactions, AI streaming under load, and keyboard navigation.

### Phase 5: Documentation & Project Closure
- Technical Writer emits Design System Guide, UI Component Library documentation, Hook & State Reference, and AI Workflow Runbooks.
