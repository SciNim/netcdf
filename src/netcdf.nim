import netcdf/error_handler

import netcdf/netcdf_bindings
export netcdf_bindings

import netcdf/shared_types
export shared_types

type
  OpenMode* = enum
    omNoWrite = NC_NOWRITE # read-only
    omWrite = NC_WRITE
    omShare = NC_SHARE
    omWriteShare = NC_WRITE or NC_SHARE

proc ncOpen*(path: string, mode = omNoWrite): NCid =
  handleError open(path, mode.cint, result.cint)

proc close*(ncid: NCid) =
  handleError close(ncid.cint)
