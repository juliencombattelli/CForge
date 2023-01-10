# CForge

CForge is a collection of CMake scripts and modules to forge robust and toolable build systems.

## Features

### Utility modules

- [Work in progress] **CForgeAssert** — Provide a flexible assertion mechanism
- [Not yet implemented] **CForgeConan** — Integrate the Conan package manager into a CMake project
- **CForgeDoc** — Generate rst-formatted documentation using Sphinx
- [Not yet implemented] **CForgeFetchFmt** — Fetch the Fmt library using FetchContent
- [Not yet implemented] **CForgeFetchGoogleTest** — Fetch the GoogleTest framework using FetchContent
- [Not yet implemented] **CForgeFetchSpdlog** — Fetch the Spdlog library using FetchContent
- [Work in progress] **CForgeJSON** — Provide helper functions to parse JSON content
- [Not yet implemented] **CForgeOption** — Provide a flexible way to declare project-wide options
- [Not yet implemented] **CForgeTargetAddPrecompiledHeaders** — Add precompiled headers to a target
- **CForgeTargetAddWarnings** — Add warnings to a target from a JSON file
- [Not yet implemented] **CForgeTargetEnableCoverage** — Enable test coverage analysis for a target
- [Not yet implemented] **CForgeTargetEnableInterproceduralOptimization** — Enable Link-Time Optimizations for a target
- [Not yet implemented] **CForgeTargetEnableSanitizers** — Enable sanitizers for a target
- [Not yet implemented] **CForgeTargetEnableStaticAnalyzers** — Enable static analysis for a target
- **CForgeUnit** — Provide a unit-test framework for CMake code

### Find modules

- [Not yet implemented] **FindGDB** — Find the GDB executable for the current toolchain
- [Not yet implemented] **FindLCOV** — Find the LCOV code coverage report generation tool
- [Not yet implemented] **FindOpenOCD** — Find the OpenOCD executable
- **FindSphinx** — Find the Sphinx documentation generator

### Toolchains

- [Not yet implemented] **Stm32Gcc** — A GCC-based toolchain for STM32 targets (using [ObKo/stm32-cmake](https://github.com/ObKo/stm32-cmake))

## Usage

### Requirements

CForge requires CMake 3.20+. Some dependencies might be needed depending on the modules used.
Check the modules documentation for further information.

### Integration

There are multiple ways to integrate CForge into a CMake project:

- **CForgeConfig.cmake** — Install CForge into your system and use *find_package()* to locate it
- **FetchContent** — Use CMake's *FetchContent* module to download CForge and include it to your project
- **Manual add_subdirectory** (not recommended) — Manually add CForge to your project (eg. by copying the sources or as a git-submodules) and use *add_subdirectory()* to include it

### Options

- **CFORGE_ENABLE_TESTING** — Build the unit tests (default: ON)
- [Not yet implemented] **CFORGE_ENABLE_FUZZING** — Build the fuzzy tests (default: OFF, needs CFORGE_ENABLE_TESTING=ON)
- **CFORGE_UNIT_RUN_TESTS_AT_CONFIGURATION** — Run CForge test suite at configuration instead of during CTest phase (default: OFF, needs CFORGE_ENABLE_TESTING=ON)
- **CFORGE_ENABLE_COVERAGE** — Build with test coverage analysis (default: OFF, needs CFORGE_UNIT_RUN_TESTS_AT_CONFIGURATION=ON)
- [Work in progress] **CFORGE_ENABLE_DOCUMENTATION** — Generate the html documentation using Sphinx

## Contributing

If you want to get involved and suggest some additional features, signal a bug or submit a patch, please create
a pull request or open an issue on the [CForge Github repository](https://github.com/juliencombattelli/cforge).
