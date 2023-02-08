cmake_minimum_required(VERSION 3.20)
project(cforge_unit_coverage_test_project LANGUAGES NONE)

set(FOO "a;c;b") #[==[ Hello ]==] #[===[
hello
 <- this is not the closing bracket
]

]===]
set(BAR)

if(FOO)
    if(BAR)
        message("")
    elseif()
        message("")
    else()
        message("")
    endif()
else()
    message("")
endif()

# TODO Add more control statements

# A single line comment
include(CTest) #[==[ Hello ]==]

#[==[ Hello ]==] #[=[
    message("")
]=]

enable_testing()
#[==[ Hello ]==]
