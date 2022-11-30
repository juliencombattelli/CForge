CMake Modules
=============

The modules listed here are part of CForge project.
The CForge's *cmake/Modules/* directory must be added to the
:cmake:variable:`CMAKE_MODULE_PATH` CMake variable to use the provided modules.


Utility Modules
---------------

These modules are loaded using the :cmake:command:`include` command.

.. toctree::
    :maxdepth: 1
    :glob:

    CForge*


Find Modules
------------

These modules search for third-party software.
They are normally called through the :cmake:command:`find_package` command.

.. toctree::
    :maxdepth: 1
    :glob:

    Find*
