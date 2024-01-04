.. cmake-manual-description: CForge Variables Reference

cforge-variables(7)
*******************

.. warning::

  Page under construction


.. only:: html

   .. contents::

This page documents variables that are provided by CMake
or have meaning to CMake when set by project code.

For general information on variables, see the
:ref:`Variables <CMake Language Variables>`
section in the cmake-language manual.

.. note::

  CForge reserves identifiers that:

  * begin with ``CFORGE_`` (upper-, lower-, or mixed-case), or
  * begin with ``_CFORGE_`` (upper-, lower-, or mixed-case).

CForge defines some internal variables that should never be modified by the
user. They must all start with the `_CFORGE_` prefix, and must not be visible to
the user (unless strictly necessary).

Variables dedicated to CForge must all start with the `CFORGE_` prefix, and must
not be visible to the user (unless strictly necessary). They may only be defined
from one of CForge CMakeLists.txt or included script, but never from a module
imported by the user (directly or transitively).

For variables defined in a module imported by the user (either directly or
transitively) refer to :ref:`manual/cforge-modules.7:Identifiers naming rules`
in the CForge modules manual page.
