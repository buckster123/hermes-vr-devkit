# Security Policy

Hermes VR DevKit is a development-tooling repository. It includes shell scripts,
MCP configuration, Android tooling setup, Godot project templates, and build
scripts that may affect a developer workstation or connected Quest device.

## Trust Model

Treat this repository as source code to inspect, not as a magic installer to run
blindly. In particular:

- Do not pipe remote install scripts into `bash` until you have reviewed the
  script and pinned the repository/commit you intend to use.
- Do not paste personal access tokens, signing keys, keystore passwords, or API
  credentials into issues, PRs, logs, screenshots, or MCP prompts.
- Prefer local clones, feature branches, and reviewed PRs for changes to
  installer scripts or MCP configuration.
- Keep Android signing keys and release keystores outside the repository.
- Use generated debug keystores only for local testing.

## Reporting Issues

If you find a vulnerability or risky installation behavior, please open a GitHub
issue with:

1. The affected file and line numbers.
2. The command or workflow that triggers the risk.
3. Whether the issue is confirmed, suspected, or a hardening suggestion.
4. A proposed safer default, if known.

Avoid including secrets or private machine details in public issues.

## Maintainer Checklist for Sensitive Changes

Before merging changes to installer scripts, build scripts, or MCP server setup:

- Review every command that uses `sudo`, downloads binaries, changes shell
  startup files, modifies system groups, or deletes directories.
- Prefer version-pinned downloads with checksums where practical.
- Keep destructive commands scoped to known temporary directories.
- Ensure scripts print what they will do before making major changes.
- Confirm generated files do not contain tokens, absolute private paths, or
  keystore passwords.
