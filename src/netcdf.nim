import netcdf/netcdf_bindings
export netcdf_bindings

type
  NetcdfError* = object of CatchableError

  NcId* = distinct cint

  OpenMode* = enum
    omNoWrite = NC_NOWRITE # read-only
    omWrite = NC_WRITE
    omShare = NC_SHARE
    omWriteShare = NC_WRITE or NC_SHARE

template handleError(body: untyped) =
  let retval: cint = body
  if retval != 0:
    raise newException(NetcdfError, "Error " & $retval & ": " & $retval.strerror & ". Call: " & body.astToStr)

proc `$`*(ncid: NcId): string = $ncid.int

proc ncOpen*(path: string, mode = omNoWrite): NCid =
  handleError open(path, mode.cint, result.cint)

proc close*(ncid: NCid) =
  handleError close(ncid.cint)
