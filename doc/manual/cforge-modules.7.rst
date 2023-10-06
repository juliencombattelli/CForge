.. cmake-manual-description: CForge Modules Reference

cforge-modules(7)
*****************

.. only:: html

   .. contents::

CForge modules importation
--------------------------

CForge provides multiple modules users can import after having included CForge
into their own project. This can be usually be done in three ways:

* with ``find_package(CForge)`` to locate a CForge local installation through the
  provided CMake config file
* with ``FetchContent`` API to download a specific revision or branch of CForge and
  include it to the user project
* with a manual ``add_subdirectory()`` of a CForge local source tree

No matter the way users may rely on, modules must not be automatically imported.
Users will have to use include() to explicitly import the module they want.
To make those inclusions easier, however, CForge adds the module path to
``CMAKE_MODULE_PATH``.


CForge modules writing guide
----------------------------

Modules location
^^^^^^^^^^^^^^^^

CForge modules that the user can import must be defined in
``cmake/Modules/<ModuleName>.cmake`` with file name in PascalCase and with
``.cmake`` extension.

Private modules that should not be imported directly by the user but can be
imported transitively must be located in subdirectories of ``cmake/Modules/``.

Private modules that should never be imported by the user (neither directly nor
transitively) must not be in ``cmake/Modules/`` but in another subdirectory of
``cmake/`` not included in ``CMAKE_MODULE_PATH`` and excluded from installation
and use through the CForge CMake config file.

Modules content
^^^^^^^^^^^^^^^

Each CForge module should have one unique purpose. They should only define
variables and functions, and not execute code by themselves unless strictly
required.

Functions should be preferred over macros as functions introduce a new variable
scope and use a more intuitive control-flow than macros.

For configuration, function parameters should be preferred over cache
variables and options to avoid having too much persistent states.

Each module importable directly by the user must contain a rst-formatted
documentation header explaining the functions and variables defined and any
other side-effect the module can have.

Identifiers naming rules
^^^^^^^^^^^^^^^^^^^^^^^^

Some identifiers might be defined globally. To guarantee their uniqueness and
avoid conflict, functions and variables name must follow some rules.

Past their end-of-recording statement, functions and macro can be called
in any enclosing scope. In other words, once defined they are global.
So it is very important to use unique names for them.
Functions and macros defined in CForge modules must be named in lower_snake_case
with the following format: ``cforge_<module_name>_<function_name>``.

The variables defined with a global visibility (through the cache, parent scope,
or any other mean) must be named in UPPER_SNAKE_CASE and must use the project
prefix variable ``CFORGE_PROJECT_PREFIX`` to avoid name conflict.
Even if not strictly required, it is recommended to do the same for variables
scoped to a function.
