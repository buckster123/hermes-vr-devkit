# Contributing

Thanks for helping improve Hermes VR DevKit.

This repo is most useful when contributions are small, reproducible, and easy to
verify. A good PR usually does one of the following:

- Improves a Hermes skill with a concrete workflow, command, pitfall, or test.
- Adds a reference note for Godot, Blender, Quest, OpenXR, Android, or MCP.
- Adds or improves a starter template without requiring private assets.
- Makes installer behavior safer, clearer, or more portable.
- Adds verification steps that another contributor can run.

## Preferred PR Shape

1. Create a focused branch, for example `docs/quest-export-notes` or
   `fix/godot-mcp-protocol-patch`.
2. Keep installer changes separate from documentation changes when possible.
3. Include a short test plan in the PR body.
4. If the change affects a command, include the exact command tested.
5. If hardware is required, state the device tested, such as Quest 3, Quest 3S,
   or Quest 2.

## Skill Contribution Guidelines

Hermes skills should be practical operating playbooks, not generic tutorials.

A strong `SKILL.md` includes:

- Clear trigger conditions: when the agent should load the skill.
- Exact commands and file paths.
- Known pitfalls and symptom-to-fix notes.
- Verification steps or smoke tests.
- Links to reference docs inside the skill folder.

Avoid adding unverified claims. If a workflow is promising but not fully tested,
mark it as an assumption or TODO.

## Safety Expectations

Do not commit:

- Personal access tokens.
- Keystore passwords.
- Private signing keys.
- Local machine secrets.
- Large generated build artifacts.
- Vendor archives that can be downloaded from stable upstream URLs.
