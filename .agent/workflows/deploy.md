---
description: Deploy changes to GitHub and build APK
---

# Deploy Workflow

## Important Notes
- User does NOT test locally with `flutter run`
- User pushes to GitHub, APK is built by GitHub Actions, then downloaded and tested on phone

## Commands

// turbo-all

1. Check for errors first:
```bash
flutter analyze 2>&1 | Select-String -Pattern "error"
```

2. Add all changes:
```bash
git add -A
```

3. Commit with descriptive message:
```bash
git commit -m "[type]: [description]"
```

4. Get current version:
```bash
git tag --sort=-v:refname | Select-Object -First 1
```

5. Create new tag (increment version):
```bash
git tag v1.0.X
```

6. Push to GitHub with tags:
```bash
git push origin main --tags
```

## Version Format
- Current: v1.0.X (increment X for each release)
- Example: v1.0.14 → v1.0.15
