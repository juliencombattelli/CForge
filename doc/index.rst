Welcome to CForge's documentation!
==================================

CForge is a collection of CMake scripts and modules to help forging robust and
toolable build systems.

CMake Modules
-------------

The modules listed here are part of CForge project.
The CForge's *cmake/Modules/* directory must be added to the
:cmake:variable:`CMAKE_MODULE_PATH` CMake variable to use the provided modules.


Utility Modules
***************

These modules are loaded using the :cmake:command:`include` command.

.. toctree::
    :maxdepth: 1
    :glob:

    cmake/Modules/CForge*


Find Modules
************

These modules search for third-party software.
They are normally called through the :cmake:command:`find_package` command.

.. toctree::
    :maxdepth: 1
    :glob:

    cmake/Modules/Find*

Reference Manuals
-----------------

.. toctree::
    :maxdepth: 1

    manual/cforge-modules.7
    manual/cforge-variables.7

Release Notes
-------------

.. toctree::
    :maxdepth: 1

    release/index

Index and Search
----------------

* :ref:`genindex`
* :ref:`search`
