Bump the Visual Minipro version by incrementing the patch number, commit, and tag.

## Step 1: Read the current version

```bash
grep "MARKETING_VERSION" "Visual Minipro.xcodeproj/project.pbxproj" | head -1
```

Extract the current `MARKETING_VERSION` (e.g. `1.5.5`) and `CURRENT_PROJECT_VERSION` from:

```bash
grep "CURRENT_PROJECT_VERSION\|MARKETING_VERSION" "Visual Minipro.xcodeproj/project.pbxproj" | head -4
```

Only look at the first two occurrences of each — they are the Debug and Release configs for the main app target. The other occurrences belong to test targets and should not be changed.

Compute:
- `new_version`: increment the patch component by 1 (e.g. `1.5.5` → `1.5.6`)
- `new_build`: increment `CURRENT_PROJECT_VERSION` by 1 (e.g. `13` → `14`)

## Step 2: Update the project file

In `Visual Minipro.xcodeproj/project.pbxproj`, update the first two occurrences of each:
- `MARKETING_VERSION = <old>;` → `MARKETING_VERSION = <new_version>;`
- `CURRENT_PROJECT_VERSION = <old>;` → `CURRENT_PROJECT_VERSION = <new_build>;`

Verify the changes:

```bash
grep -n "CURRENT_PROJECT_VERSION\|MARKETING_VERSION" "Visual Minipro.xcodeproj/project.pbxproj"
```

Confirm the main target configs (lines ~486 and ~524) are updated and the test target configs are unchanged.

## Step 3: Commit

```bash
git add -A && git commit -m "Bump version to <new_version>"
```

## Step 4: Tag

```bash
git tag -a <new_version> -m "<new_version>"
```
