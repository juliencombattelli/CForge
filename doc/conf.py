# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import sys

# -- Project information ---------------------------------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information
# Values are provided by the build system using CMake's configure_file().

# NOTE This file does not have the usual .in extension in order to keep the VSCode html preview
# working: the real conf.py is generated inside the build tree while sources are stored in the doc/
# folder, and even if the lextudio.restructuredtext extension supports separate directories for
# config and sources, it does not seem to work well for the preview engine.
# Consequently the VSCode extension uses this template file to configure Sphinx (without .in ext to
# be a valid Sphinx's conf.py). Be aware that VSCode html preview will have the @variable@ below not
# replaced. For a full featured documentation, please run the provided `doc` target.


project = '@PROJECT_NAME@'
copyright = '@CURRENT_YEAR@, @PROJECT_AUTHOR@'
author = '@PROJECT_AUTHOR@'
version = '@PROJECT_VERSION_MAJOR@.@PROJECT_VERSION_MINOR@'
release = '@PROJECT_VERSION@'

# -- General configuration -------------------------------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

sys.path.append(os.path.abspath("_ext"))


extensions = [
    'sphinx.ext.intersphinx',
    'sphinxcontrib.moderncmakedomain',
    'sphinxemoji.sphinxemoji'
]

exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

nitpicky = True

# -- Options for HTML output -----------------------------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'classic'

# -- Intersphinx configuration ---------------------------------------------------------------------

intersphinx_mapping = {
    'cmake': ('https://cmake.org/cmake/help/latest', None)
}
