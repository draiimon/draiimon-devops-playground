---
name: Local PC versus Replit files
description: Boundary between files edited in the Replit workspace and commands or screenshots performed on the user's local WSL machine.
---

The user's DevOps exam work is performed on their local WSL/Ubuntu machine, while the assistant can only edit the copy in the Replit workspace. Uploaded terminal screenshots are the source of truth for commands actually run locally; Replit documentation edits must not be described as changes already made on the user's PC.

**Why:** Confusing the two environments caused avoidable rework when repository cloning and documentation were verified in different places.

**How to apply:** For local-machine steps, give one command block at a time, wait for the user's screenshot, then document that exact result in the Replit copy. Clearly distinguish “documented here” from “executed on your PC.”