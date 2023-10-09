include(CForgeTargetEnableSanitizers)

# Force usage of GCC for the test
set(CMAKE_CXX_COMPILER_ID "GNU")

add_library(test_target INTERFACE)
cforge_target_enable_sanitizers(test_target)

include(CForgeAssert)

cforge_assert(
    CONDITION DEFINED ${CFORGE_PROJECT_PREFIX}_SANITIZE_test_target_address
    MESSAGE "Sanitize options shall be defined"
)
