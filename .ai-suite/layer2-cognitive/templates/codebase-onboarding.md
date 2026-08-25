# Template: Principal-Engineer Codebase Onboarding

**Purpose:** Use when you are a new developer onboarding to an existing project and you need a **single response** that gives you enough architectural literacy to start contributing. No files are produced; the output is a structured chat response.

---

@Codebase

Act as a **Principal Staff Engineer**. I am a new developer onboarding to this project and I need to understand the codebase to start adding new features and enhancements.

Analyze the codebase and provide a comprehensive, well-structured architectural overview. Break down your response into the following sections.

## 1. High-Level Architecture & Tech Stack
- What is the overarching design pattern (MVC, Microkernel, Event-Driven, Monolith, modular monolith, hexagonal, etc.)?
- What are the primary languages, frameworks, and core dependencies?

## 2. Core Modules & Directory Structure
- List the 3-5 most critical directories or modules.
- Explain the single responsibility of each module and how they interact.

## 3. Execution Flow & Entry Points
- Where does the application start? (`main.go`, `index.js`, init scripts, lambda handlers, etc.)
- Trace the primary "happy path" data flow from input / request to output / response.

## 4. Data Management & State
- How is state, caching, and database interaction handled?
- What are the central data models, schemas, or interfaces I should be aware of?

## 5. Extension & Enhancement Guide
- If I wanted to add a new core feature (new API endpoint, new driver, new UI component), which files or directories would I typically modify?
- Are there established coding conventions, design patterns, or testing practices in this codebase that I MUST strictly follow?
