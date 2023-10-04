.. cmake-manual-description: CForge Modules Reference

cforge-modules(7)
*****************

.. warning::

  Page under contruction


.. only:: html

   .. contents::

CForge modules importation
--------------------------

After an add_subdirectory() of CForge, modules must not be automatically
imported. However, the CForge module path must be added to CMAKE_MODULE_PATH to
let the user include() a given module to use it, eg. include(CForgeAssert).
