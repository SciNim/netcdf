template handleError*(body: untyped) =
  let retval: cint = body
  if retval != 0:
    raise newException(NetcdfError, "Error " & $retval & ": " &
        $retval.strerror & ". Call: " & body.astToStr)
