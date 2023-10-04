cmake_minimum_required(VERSION 3.20)
project(cforge_packaging_fetchcontent LANGUAGES NONE)

include(FetchContent)

message(NOTICE "Fetching local CForge sources from ${CFORGE_DIR}")

FetchContent_Declare(
    cforge
    URL ${CFORGE_DIR}
)
FetchContent_MakeAvailable(cforge)

if(COMMAND cforge_assert)
    message(SEND_ERROR "CForge functions are wrongly imported without a proper include()")
endif()

include(CForgeAssert)

if(NOT COMMAND cforge_assert)
    message(SEND_ERROR "CForge functions are not imported even with the appropriate include()")
endif()
