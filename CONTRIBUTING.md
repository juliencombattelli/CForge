# CForge contributing guide

## Commit rules

- Each commit should impact only one CForge module/feature/topic
- The modified module/feature/topic should be appended to the commit title in square brackets
  - Commit title example: `[CForgeJSON] Use JSON pointers instead of JSONPath`
  - Module/feature/topic name examples:
    - All module names in cmake/Modules/ (eg. `CForgeAssert`, `FindGDB`)
    - `CI`: topic related to Continuous Integration/Testing
    - `Doc`: topic related to CForge documentation (mainly changes in *.md and doc/)
    - `Config`: topic related to CForge configuration and build
    - `Installation`: topic related to CForge installation
    - `Package`: topic related to CForge packaging
    - `Test`: topic related to CForge test infrastructure (for module-level testing use the module name)
- The commit title should be imperative, present tense
- Commit message titles length must not be too long but must be descriptive enough
  - In other words, long descriptive titles are preferable over short and vague ones
  - 80 characters is the recommended title length limit

## Module rules

Please follow the instructions in the [CForge module writing guide](./doc/manual/cforge-modules.7.rst).
