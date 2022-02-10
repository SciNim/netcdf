type
  NetcdfError* = object of CatchableError

  NcId* = distinct cint

proc `$`*(ncid: NcId): string = $ncid.int
