include(TestSetup.cmake)

# This test shall result in a fatal error
cforge_assert(MESSAGE "This won't work")
