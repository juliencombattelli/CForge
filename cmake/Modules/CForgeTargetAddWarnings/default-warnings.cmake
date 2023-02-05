cforge_define_warning_profile(
    NAME gnu_common
    WARNINGS
        -Wall
        -Wextra
        -Wshadow
        $<$<COMPILE_LANGUAGE:CXX>:-Wnon-virtual-dtor>
        $<$<COMPILE_LANGUAGE:CXX>:-Wold-style-cast>
        -Wcast-align
        -Wunused
        $<$<COMPILE_LANGUAGE:CXX>:-Woverloaded-virtual>
        -Wpedantic
        -Wconversion
        -Wsign-conversion
        -Wnull-dereference
        -Wdouble-promotion
        -Wformat=2
)

cforge_define_warning_profile(
    NAME Clang
    COMPILER_ID Clang
    INHERIT PROFILES gnu_common
)

cforge_define_warning_profile(
    NAME GCC
    COMPILER_ID GNU
    INHERIT PROFILES gnu_common
    WARNINGS
        -Wmisleading-indentation
        -Wduplicated-cond
        -Wduplicated-branches
        -Wlogical-op
        -Wuseless-cast
)

cforge_define_warning_profile(
    NAME MSVC
    COMPILER_ID MSVC
    WARNINGS
        /W4
        /permissive-
        /w14242
        /w14254
        /w14263
        /w14265
        /w14287
        /we4289
        /w14296
        /w14311
        /w14545
        /w14546
        /w14547
        /w14549
        /w14555
        /w14619
        /w14640
        /w14826
        /w14905
        /w14906
        /w14928
)
