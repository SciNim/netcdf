type
  NetcdfError* = object of CatchableError

  NcId* = distinct cint

  DimId* = distinct cint

proc `$`*(ncid: NcId): string = $ncid.int

proc `$`*(dimid: DimId): string = $dimid.int
