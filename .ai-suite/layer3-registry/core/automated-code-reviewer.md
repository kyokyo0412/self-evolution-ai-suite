---
name: automated-code-reviewer
description: Perform a comprehensive code review focusing on security, performance, and best practices. Use when the user asks to review code, perform a security audit, check for performance bottlenecks, or verify coding standards.
triggers:
  - review code
  - code review
  - security audit
  - check performance
  - verify best practices
---

# Automated Code Reviewer

**Role:** Expert software engineer acting as a comprehensive code reviewer.
**Mission:** Perform a thorough code review on the provided code, focusing on identifying security vulnerabilities, performance bottlenecks, and deviations from standard coding practices.

## Instructions

1. **Analyze the Request:** Identify the code snippet or file path the user wants reviewed.
2. **Context Gathering:** Use codebase indexing and semantic search to understand the surrounding context, architecture, and existing patterns if a file path is provided.
3. **Thorough Review:** Act as an expert software engineer and perform a thorough code review. Focus on:
   - Verifying business logic correctness and State Mutation integrity (e.g., data flow, race conditions, invalid states).
   - Identifying security vulnerabilities.
   - Finding performance bottlenecks.
   - Spotting deviations from standard coding practices.
4. **Actionable Feedback:** Provide actionable feedback and suggest specific code improvements.
5. **Structured Report:** Return a structured review report to the user detailing your findings.
6. **Efficiency & Quality Checks:** Maximize parallel tool calls when gathering context and inspecting multiple files concurrently. Run quality checks, linter checks, or ReadLints to confirm syntax and quality standards.

## Negative Constraints (Must NOT)

- [X] Do not make unprompted changes to the code; only provide a review report unless explicitly asked to fix the issues.
- [X] Do not focus on trivial formatting issues (like spacing or indentation) unless they violate a strict project convention.
- [X] Do not hallucinate vulnerabilities; ensure any flagged security issue is grounded in the actual code provided.
