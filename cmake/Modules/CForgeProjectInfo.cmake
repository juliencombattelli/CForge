#[=================================================================================================[.rst:
CForgeProjectInfo
-----------------

Provide general information and project-wide configurations of CForge.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables are set:

``CFORGE_PROJECT_PREFIX``
  Prefix used for all options defined in CForge modules to avoid naming
  conflict. Can be adjusted by the user, defaults to a capitalized form of
  ``${PROJECT_NAME}_CFORGE`` for users of CForge, and to ``CFORGE`` when
  building CForge in standalone.

#]=================================================================================================]

include_guard(GLOBAL)

if(PROJECT_NAME STREQUAL "CForge")
    set(_CFORGE_PROJECT_PREFIX "CFORGE")
else()
    set(_CFORGE_PROJECT_PREFIX "${PROJECT_NAME}_CFORGE")
    string(TOUPPER "${_CFORGE_PROJECT_PREFIX}" _CFORGE_PROJECT_PREFIX)
endif()

set(CFORGE_PROJECT_PREFIX "${_CFORGE_PROJECT_PREFIX}"
    CACHE STRING "Prefix used for options defined in CForge modules")
