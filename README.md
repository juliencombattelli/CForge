# CForge
Collection of CMake scripts and modules to forge robust and toolable build systems


## CForge test coverage

To run line and branch coverage for CForge, run the following commands:
```
cmake -S . -B build -DCFORGE_UNIT_RUN_TESTS_AT_CONFIGURATION=OFF --trace 2>trace.txt
cmake -DTRACEFILE=trace.txt -DLCOV_OUTPUT=output.lcov -DRUN_COVERAGE=1 -S . -B build_coverage
genhtml --rc lcov_branch_coverage=1 -o cov_out output.lcov --prefix $(pwd)
```