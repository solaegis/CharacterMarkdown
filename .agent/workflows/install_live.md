---
description: Install the addon to the live ESO addon directory
---


To install the current version of the addon to the live ESO environment, run:

```bash
task install:live
```

This command will:
1. Dynamically detect the current version from git (tag or commit).
2. Copy files to the ESO Live AddOns directory.
3. Inject the detected version into the installed manifest and files, replacing `@project-version@`.

It should be run whenever code changes are made to ensure the live addon is up to date and correctly versioned.
