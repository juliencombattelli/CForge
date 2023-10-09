include(CForgeTargetEnableSanitizers)

# Force usage of GCC for the test
set(CMAKE_CXX_COMPILER_ID "GNU")

# Enable address sanitizer
set(${CFORGE_PROJECT_PREFIX}_SANITIZE_test_target_address ON CACHE INTERNAL "" FORCE)

add_library(test_target INTERFACE)
cforge_target_enable_sanitizers(test_target)

include(CForgeAssert)

cforge_assert(
    CONDITION DEFINED ${CFORGE_PROJECT_PREFIX}_SANITIZE_test_target_address
    MESSAGE "Sanitize options shall be defined"
)

get_target_property(COMPILE_FLAGS test_target INTERFACE_COMPILE_OPTIONS)
cforge_assert(
    CONDITION "${COMPILE_FLAGS}" STREQUAL "-fsanitize=address"
    MESSAGE "Sanitize flag shall be preset in compile options"
)
