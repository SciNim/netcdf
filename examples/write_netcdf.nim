# this is just:
# https://www.unidata.ucar.edu/software/netcdf/docs/simple__xy__wr_8c_source.html

import netcdf
# This is the name of the data file we will create. */
const FILE_NAME = "simple_xy.nc"
# We are writing 2D data, a 6 x 12 grid. */
const NDIMS = 2
const NX = 6
const NY = 12

# Handle errors by printing an error message and exiting with a
# non-zero status.#/
const ERRCODE = 2
template ERR(e: untyped): untyped =
  echo "Error: ", strerror(e)
  quit(ERRCODE)

proc main() =
  # When we create netCDF variables and dimensions, we get back an
  # ID for each one.#/
  var
    ncid, x_dimid, y_dimid, varid: cint
    dimids: array[NDIMS, cint]

  # This is the data array we will write. It will be filled with a
  # progression of numbers for this example.#/
  var data_out: array[NX * NY, cint]

  # Loop indexes, and error handling.#/
  var x, y, retval: cint

  # Create some pretend data. If this wasn't an example program, we
  # would have some real data to write, for example, model
  # output.#/
  for x in 0 ..< NX:
    for y in 0 ..< NY:
      data_out[x * NY + y] = x.cint# NY + y;

  # Always check the return code of every netCDF function call. In
  # this example program, any retval which is not equal to NC_NOERR
  # (0) will cause the program to print an error message and exit
  # with a non-zero return code.#/

  # Create the file. The NC_CLOBBER parameter tells netCDF to
  # overwrite this file, if it already exists.*/
  retVal = create(FILE_NAME, NC_CLOBBER, ncid.unsafeaddr)
  if retval != 0:
    ERR(retval);

  # Define the dimensions. NetCDF will hand back an ID for each.#/
  retVal = def_dim(ncid, "x", NX, x_dimid.unsafeAddr)
  if retVal != 0:
     ERR(retval);
  retval = def_dim(ncid, "y", NY, y_dimid.unsafeAddr)
  if retVal != 0:
     ERR(retval);

  # The dimids array is used to pass the IDs of the dimensions of
  # the variable.#/
  dimids[0] = x_dimid;
  dimids[1] = y_dimid;

  # Define the variable. The type of the variable in this case is
  # NC_INT (4-byte integer).#/
  retval = def_var(ncid, "data", NC_INT, NDIMS,
                   dimids[0].unsafeAddr, varid.unsafeAddr)
  if retVal != 0:
     ERR(retval);

  # End define mode. This tells netCDF we are done defining
  # metadata.#/
  retval = enddef(ncid)
  if retVal != 0:
     ERR(retval);

  # Write the pretend data to the file. Although netCDF supports
  # reading and writing subsets of data, in this case we write all
  # the data in one operation.#/
  retval = put_var_int(ncid, varid, data_out[0].unsafeAddr)
  if retVal != 0:
     ERR(retval);

  # Close the file. This frees up any internal netCDF resources
  # associated with the file, and flushes any buffers.#/
  retval = close(ncid)
  if retVal != 0:
     ERR(retval);

  echo "*** SUCCESS writing example file simple_xy.nc!\n"

main()
