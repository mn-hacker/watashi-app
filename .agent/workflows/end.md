---
description: Save daily work summary to session log
---

# /end - End Session Workflow

When user sends `/end`, create a session log that summarizes all work done.

## Steps:

1. Create/update `session_log.md` in the brain/artifacts folder with:
   - Date and time
   - Summary of all completed tasks
   - Files created/modified
   - Any remaining TODOs

2. Use this format:

```markdown
# Session Log: [DATE]

## Summary
[Brief overview of what was accomplished]

## Tasks Completed
- [x] Task 1
- [x] Task 2
...

## Files Modified
- `path/to/file1.dart` - description
- `path/to/file2.dart` - description

## New Files Created
- `path/to/new/file.dart` - purpose

## TODOs for Next Session
- [ ] Item 1
- [ ] Item 2
```

3. Confirm to user that session has been logged.
