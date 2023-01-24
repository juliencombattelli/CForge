import argparse
import pathlib
import ssl
import sphobjinv as soi
import urllib.request

from conf import intersphinx_mapping


parser = argparse.ArgumentParser(
    description='Patch the Sphinx inventory file provided by cmake.org')

parser.add_argument('patched_inv_file', type=pathlib.Path)
parser.add_argument('--no-check-certificate', action='store_true')
args = parser.parse_args()

# Disable certificate verification if asked
if args.no_check_certificate:
    ssl._create_default_https_context = ssl._create_unverified_context

# Download CMake's Sphinx inventory
cmake_doc_url = intersphinx_mapping['cmake.org'][0]
upstream_inv_file, _ = urllib.request.urlretrieve(
    cmake_doc_url + '/objects.inv')

# Parse the downloaded inventory file
inv = soi.Inventory(upstream_inv_file)

# For each objects belonging to 'cmake' domain, remove the prefix '<role>:'.
# <role> can be command, variable, module, etc.
# This allows the correct creation of external links to CMake's documentation
# while keeping the formatting capabilities of moderncmakedomain extension.
for obj in inv.objects:
    if obj.domain == 'cmake' and obj.name.startswith(f'{obj.role}:'):
        obj.name = obj.name[len(f'{obj.role}:'):]

# Write the resulting inventory objects into the output file
soi.writebytes(args.patched_inv_file, soi.compress(inv.data_file()))
