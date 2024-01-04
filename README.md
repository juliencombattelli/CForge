# CForge

[![Build & Tests](https://github.com/juliencombattelli/CForge/actions/workflows/build.yml/badge.svg)](https://github.com/juliencombattelli/CForge/actions/workflows/build.yml)

CForge is a collection of CMake scripts and modules to forge robust and toolable
build systems. Checkout the full CForge documentation on [ReadTheDocs](https://cforge.readthedocs.io).

## Features

### Utility modules

- [Missing doc] **CForgeAssert** — Provide a simple assertion mechanism
- [Not yet implemented] **CForgeConan** — Integrate the Conan package manager into a CMake project
- [Not yet implemented] **CForgeDoc** — Generate rst-formatted documentation using Sphinx
- [Not yet implemented] **CForgeFetchFmt** — Fetch the Fmt library using FetchContent
- [Not yet implemented] **CForgeFetchGoogleTest** — Fetch the GoogleTest framework using FetchContent
- [Not yet implemented] **CForgeFetchSpdlog** — Fetch the Spdlog library using FetchContent
- **CForgeForceColoredOutput** — Force some compilers to always produce ANSI-colored output
- [Work in progress] **CForgeJSON** — Provide helper functions to parse JSON content
- [Not yet implemented] **CForgeOption** — Provide a flexible way to declare project-wide options
- [Not yet implemented] **CForgeTargetAddPrecompiledHeaders** — Add precompiled headers to a target
- **CForgeTargetAddWarnings** — Add warnings to a target from a dedicated CMake configuration file
- [Not yet implemented] **CForgeTargetEnableCoverage** — Enable test coverage analysis for a target
- [Not yet implemented] **CForgeTargetEnableLTO** — Enable Link-Time Optimizations for a target
- **CForgeTargetEnableSanitizers** — Enable sanitizers for a target
- [Not yet implemented] **CForgeTargetEnableStaticAnalyzers** — Enable static analysis for a target
- [Missing doc] **CForgeUnit** — Provide a unit-test and test coverage framework for CMake code

### Find modules

- **FindGDB** — Find the GDB executable for the current toolchain
- **FindLCOV** — Find the LCOV code coverage report generation tool
- **FindOpenOCD** — Find the OpenOCD executable
- **FindSphinx** — Find the Sphinx documentation generator

### Toolchains

- [Not yet implemented] **Stm32Gcc** — A GCC-based toolchain for STM32 targets
  based on [ObKo/stm32-cmake](https://github.com/ObKo/stm32-cmake)

## Usage

### Integration

There are multiple ways to integrate CForge into a CMake project:

- **CForgeConfig.cmake** — Install CForge into your system and use
  [find_package(CForge)](https://cmake.org/cmake/help/latest/command/find_package.html)
  to locate it
- **FetchContent** — Use CMake's [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html)
  module to download CForge and include it to your project
- **Manual add_subdirectory** — Manually add CForge to your project (eg. by
  copying the sources or as a git-submodule) and use
  [add_subdirectory()](https://cmake.org/cmake/help/latest/command/add_subdirectory.html)
  to include it

### Requirements

Requirements depend on:
- how CForge is used (see [Integration](#Integration) above),
- which CForge modules are used.

To build and install CForge, or to use CForge using add_subdirectory() or
FetchContent, CMake 3.21+ is required. Other dependencies might be needed
depending on the build options and modules used.

CForge modules installed and used through CForgeConfig.cmake might require a
different CMake version (minimum required version for some modules can be lesser
or greater than 3.21) and additional software requirements might be needed.

Check the modules documentation for further information.

### Options

- **CFORGE_ENABLE_TESTING** — Build the unit tests (default: ON)
- **CFORGE_ENABLE_TESTING_AT_CONF** — Run CForge test suite at configuration
  instead of during CTest phase (default: OFF, needs CFORGE_ENABLE_TESTING=ON)
- [Not yet implemented] **CFORGE_ENABLE_FUZZING** — Build the fuzzy tests
  (default: OFF, needs CFORGE_ENABLE_TESTING=ON)
- **CFORGE_ENABLE_COVERAGE** — Build with test coverage analysis
  (default: OFF, needs CFORGE_ENABLE_TESTING=ON)
- **CFORGE_ENABLE_DOCUMENTATION** — Generate the html documentation using Sphinx
  (default: OFF)
- [Not yet implemented] **CFORGE_ENABLE_MIN_VERSION_CHECK** — Add tests checking if the CMake minimum
  required versions are correctly set in CForge modules, using [cmake_min_version](https://github.com/nlohmann/cmake_min_version)
  (default: OFF, needs CFORGE_ENABLE_TESTING=ON)

## Contributing

If you want to get involved and suggest some additional features, signal a bug
or submit a patch, please create a pull request or open an issue on the
[CForge Github repository](https://github.com/juliencombattelli/cforge).

Please follow the guidelines in [CONTRIBUTING.md](./CONTRIBUTING.md).
