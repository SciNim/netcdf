import netcdf/[error_handler, netcdf_bindings, shared_types]

# Wrappers with Nim types for the C bindings

proc inqNdims*(ncid: NCId): int =
  var ndims: cint
  handleError inqNdims(ncid.cint, ndims)
  ndims.int

proc inqDimname*(ncid: NCId, dimid: DimId): string =
  result = newString(NC_MAX_NAME + 1)
  handleError inqDimname(ncid.cint, dimid.cint, result.cstring)
  result.setLen(result.cstring.len)

proc inqDimid*(ncid: NCid, name: string): DimId =
  handleError inqDimid(ncid.cint, name, result.cint)

proc inqDimlen*(ncid: NCId, dimid: DimId): int =
  var len: csize_t
  handleError inqDimlen(ncid.cint, dimid.cint, len)
  len.int


# Additional convenience procs

proc inqDimnames*(ncid: NCId): seq[string] =
  for dimid in 0 ..< inqNdims(ncid):
    result.add inqDimname(ncid, dimid.DimId)

proc inqDimlen*(ncid: NCId, name: string): int =
  inqDimlen(ncid, inqDimid(ncid, name))
