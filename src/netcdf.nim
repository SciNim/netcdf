import netcdf/dimensions
export dimensions

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

proc inq*(ncid: NCid): tuple[ndims, nvars, natts, unlimdimid: int] =
  var ndims, nvars, natts, unlimdimid: cint
  handleError inq(ncid.cint, ndims, nvars, natts, unlimdimid)
  (ndims.int, nvars.int, natts.int, unlimdimid.int)
