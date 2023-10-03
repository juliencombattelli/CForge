# CForge contributing guide

## Commit rules

- Each commit should impact only one CForge module/feature
- The modified module/feature should be appended to the commit title in square brackets
  - Commit title example: `[CForgeJSON] Use JSON pointers instead of JSONPath`
  - Module/feature name examples:
    - All module names in cmake/Modules/ (eg. CForgeAssert, FindGDB)
    - CI: topic related to Continuous Integration/Testing
    - Doc: topic related to CForge documentation (mainly changes in *.md and doc/)
    - Package: topic related to CForge packaging
- The commit title should be imperative, present tense
- Commit message titles length must not be too long but must be descriptive enough
  - In other words, long descriptive titles are preferable over short and vague ones
  - 80 characters is the recommended title length limit
