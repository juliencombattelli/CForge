# Common profiles definition with 0 to 3 warnings and 0 inherited profiles

cforge_define_warning_profile(
    NAME common0
)

cforge_define_warning_profile(
    NAME common1
    WARNINGS Common1A
)

cforge_define_warning_profile(
    NAME common2
    WARNINGS Common2A Common2B
)

cforge_define_warning_profile(
    NAME common3
    WARNINGS Common3A Common3B Common3C
)

# Common profiles definition with 0 to 2 warnings and 1 to 2 inherited profiles
# TODO is it necessary?

cforge_define_warning_profile(
    NAME common1_0
    INHERIT PROFILES common1
)

cforge_define_warning_profile(
    NAME common1_1
    INHERIT PROFILES common1
    WARNINGS Common1_1A
)

cforge_define_warning_profile(
    NAME common1+2_2
    INHERIT PROFILES common1 common2
    WARNINGS Common1+2A Common1+2B
)

# Profiles definition with 0 warning and 0 to 3 inherited profiles

cforge_define_warning_profile(
    NAME Profile0W0I
    COMPILER_ID Profile0W0I
)

cforge_define_warning_profile(
    NAME Profile0W1I
    COMPILER_ID Profile0W1I
    INHERIT PROFILES common1
)

cforge_define_warning_profile(
    NAME Profile0W2I
    COMPILER_ID Profile0W2I
    INHERIT PROFILES common1 common2
)

cforge_define_warning_profile(
    NAME Profile0W3I
    COMPILER_ID Profile0W3I
    INHERIT PROFILES common1 common2 common3
)

# Profiles definition with 1 warning and 0 to 3 inherited profiles

cforge_define_warning_profile(
    NAME Profile1W0I
    COMPILER_ID Profile1W0I
    WARNINGS Warning1A
)

cforge_define_warning_profile(
    NAME Profile1W1I
    COMPILER_ID Profile1W1I
    INHERIT PROFILES common1
    WARNINGS Warning1A
)

cforge_define_warning_profile(
    NAME Profile1W2I
    COMPILER_ID Profile1W2I
    INHERIT PROFILES common1 common2
    WARNINGS Warning1A
)

cforge_define_warning_profile(
    NAME Profile1W3I
    COMPILER_ID Profile1W3I
    INHERIT PROFILES common1 common2 common3
    WARNINGS Warning1A
)

# Profiles definition with 2 warnings and 0 to 3 inherited profiles

cforge_define_warning_profile(
    NAME Profile2W0I
    COMPILER_ID Profile2W0I
    WARNINGS Warning2A Warning2B
)

cforge_define_warning_profile(
    NAME Profile2W1I
    COMPILER_ID Profile2W1I
    INHERIT PROFILES common1
    WARNINGS Warning2A Warning2B
)

cforge_define_warning_profile(
    NAME Profile2W2I
    COMPILER_ID Profile2W2I
    INHERIT PROFILES common1 common2
    WARNINGS Warning2A Warning2B
)

cforge_define_warning_profile(
    NAME Profile2W3I
    COMPILER_ID Profile2W3I
    INHERIT PROFILES common1 common2 common3
    WARNINGS Warning2A Warning2B
)

# Profiles definition with 3 warnings and 0 to 3 inherited profiles

cforge_define_warning_profile(
    NAME Profile3W0I
    COMPILER_ID Profile3W0I
    WARNINGS Warning3A Warning3B Warning3C
)

cforge_define_warning_profile(
    NAME Profile3W1I
    COMPILER_ID Profile3W1I
    INHERIT PROFILES common1
    WARNINGS Warning3A Warning3B Warning3C
)

cforge_define_warning_profile(
    NAME Profile3W2I
    COMPILER_ID Profile3W2I
    INHERIT PROFILES common1 common2
    WARNINGS Warning3A Warning3B Warning3C
)

cforge_define_warning_profile(
    NAME Profile3W3I
    COMPILER_ID Profile3W3I
    INHERIT PROFILES common1 common2 common3
    WARNINGS Warning3A Warning3B Warning3C
)

# TODO add out of file inheritance using valid-profiles-common.cmake
