import sphobjinv as soi
import urllib.request
import sys
import pathlib

upstream_inv_file = pathlib.Path(sys.argv[1]) #build_directory / 'cmake-objects.inv'
patched_inv_file = pathlib.Path(sys.argv[2]) #build_directory / 'cmake-objects.patched.inv'

urllib.request.urlretrieve("https://cmake.org/cmake/help/latest/objects.inv", upstream_inv_file)

inv = soi.Inventory(upstream_inv_file)

for obj in inv.objects:
    if obj.domain == 'cmake' and obj.name.startswith(f'{obj.role}:'):
        obj.name = obj.name[len(f'{obj.role}:'):]

soi.writebytes(patched_inv_file, soi.compress(inv.data_file()))
