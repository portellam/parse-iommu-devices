#!/bin/bash

# tests

# TODO: check IOMMU groups output against expected.

# parse-iommu-devices --verbose --pcie --ignore-groups 1, --ignore-groups 2
# inclusive selection: get all pcie, remove group 1 and 2
# works as intended

# parse-iommu-devices --verbose --pcie --ignore-groups 1, --ignore-groups 2 --vendors nvidia
# does not work
# should be: inclusive selection: gets all pcie, first removes group 1 and 2, and adds back group 1.
