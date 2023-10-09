include(CForgeTargetEnableSanitizers)

# Use a compiler ID not matching any known compiler
set(CMAKE_CXX_COMPILER_ID "A random compiler")

add_library(test_target INTERFACE)
cforge_target_enable_sanitizers(test_target)

include(CForgeAssert)

cforge_assert(
    CONDITION NOT DEFINED ${CFORGE_PROJECT_PREFIX}_SANITIZE_test_target_address
    MESSAGE "Sanitize options shall not be defined"
)
