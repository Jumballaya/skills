#!/usr/bin/env bash
# PreToolUse hook for Write/Edit: injects A Philosophy of Software Design principles
# as additionalContext so they stay in view while writing code. See ./SKILL.md.
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Writing/editing code — apply the coding-style skill (A Philosophy of Software Design). Minimize complexity (dependencies + obscurity). Prefer DEEP modules: simple interface over a powerful implementation. Hide design decisions; no information leakage. Pull complexity downward. Define errors out of existence. Make code obvious; comments say what code cannot. Red flags to fix NOW: shallow module, information leakage, pass-through method/variable, temporal decomposition, conjoined methods, repetition, special-general mixture, vague name, comment restating code."}}
JSON
