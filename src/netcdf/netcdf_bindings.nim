## ! \file
##
## Main header file for the C API.
##
## Copyright 2018, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002,
## 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014,
## 2015, 2016, 2017, 2018, 2019
## University Corporation for Atmospheric Research/Unidata.
##
## See \ref copyright file for more info.
##

##  Required for alloca on Windows

#when defined(_WIN32) or defined(_WIN64):
#  discard
### ! The nc_type type is just an int.

when defined(windows):
  const
    libSuffix = ".dll"
    libPrefix = ""
elif defined(macosx):
  const
    libSuffix = ".dylib"
    libPrefix = "lib"
else:
  const
    libSuffix = ".so(||.15)"
    libPrefix = "lib"
const
  netcdf {.strdefine.} = "netcdf"
  ## TODO: allow more options
  libnetcdf* = libPrefix & netcdf & libSuffix


type
  `type`* = cint

## `ptrdiff_t` apparently is the type that you get when subtracting two pointers.
## So I suppose a distinct `int` / `int32` sounds reasonable for now
when sizeof(pointer) == 8:
  type
    ptrdiff_t* {.importc: "ptrdiff_t", header: "stddef.h".} = distinct int
elif sizeof(pointer) == 4:
  type
    ptrdiff_t* {.importc: "ptrdiff_t", header: "stddef.h".} = distinct int32
else:
  {.error: "Unsupported architecture with pointer size of " & $sizeof(pointer).}
##
##   The netcdf external data types
##

const
  NC_NAT* = 0
  NC_BYTE* = 1
  NC_CHAR* = 2
  NC_SHORT* = 3
  NC_INT* = 4
  NC_LONG* = NC_INT
  NC_FLOAT* = 5
  NC_DOUBLE* = 6
  NC_UBYTE* = 7
  NC_USHORT* = 8
  NC_UINT* = 9
  NC_INT64* = 10
  NC_UINT64* = 11
  NC_STRING* = 12
  NC_MAX_ATOMIC_TYPE* = NC_STRING

##  The following are use internally in support of user-defines
##  types. They are also the class returned by nc_inq_user_type.

const
  NC_VLEN* = 13
  NC_OPAQUE* = 14
  NC_ENUM* = 15
  NC_COMPOUND* = 16

## * @internal Define the first user defined type id (leave some
##  room)

const
  NC_FIRSTUSERTYPEID* = 32

## * Default fill value. This is used unless _FillValue attribute
##  is set.  These values are stuffed into newly allocated space as
##  appropriate.  The hope is that one might use these to notice that a
##  particular datum has not been set.
## *@{

const
  NC_FILL_BYTE* = (cast[cchar](-127))
  NC_FILL_CHAR* = (cast[char](0))
  NC_FILL_SHORT* = (-32767).cshort
  NC_FILL_INT* = (-2147483647)
  NC_FILL_FLOAT* = (9.9692099683868690e+36f) ##  near 15 * 2^119
  NC_FILL_DOUBLE* = (9.9692099683868690e+36)
  NC_FILL_UBYTE* = (255)
  NC_FILL_USHORT* = (65535)
  NC_FILL_UINT* = (4294967295'u)
  NC_FILL_INT64* = (cast[clonglong](-9223372036854775806'i64))
  NC_FILL_UINT64* = (cast[culonglong](18446744073709551614'u64))
  NC_FILL_STRING* = (cast[cstring](""))

## *@}
## ! Max or min values for a type. Nothing greater/smaller can be
##  stored in a netCDF file for their associated types. Recall that a C
##  compiler may define int to be any length it wants, but a NC_INT is
##  *always* a 4 byte signed int. On a platform with 64 bit ints,
##  there will be many ints which are outside the range supported by
##  NC_INT. But since NC_INT is an external format, it has to mean the
##  same thing everywhere.
## *@{

const
  NC_MAX_BYTE* = 127
  NC_MIN_BYTE* = (-NC_MAX_BYTE - 1)
  NC_MAX_CHAR* = 255
  NC_MAX_SHORT* = 32767
  NC_MIN_SHORT* = (-NC_MAX_SHORT - 1)
  NC_MAX_INT* = 2147483647
  NC_MIN_INT* = (-NC_MAX_INT - 1)
  NC_MAX_FLOAT* = 3.402823466e+38f
  NC_MIN_FLOAT* = (-NC_MAX_FLOAT)
  NC_MAX_DOUBLE* = 1.7976931348623157e+308
  NC_MIN_DOUBLE* = (-NC_MAX_DOUBLE)
  NC_MAX_UBYTE* = NC_MAX_CHAR
  NC_MAX_USHORT* = 65535'u
  NC_MAX_UINT* = 4294967295'u
  NC_MAX_INT64* = (9223372036854775807'i64)
  NC_MIN_INT64* = (-9223372036854775807'i64 - 1)
  NC_MAX_UINT64* = (18446744073709551615'u64)

## *@}
## * Name of fill value attribute.  If you wish a variable to use a
##  different value than the above defaults, create an attribute with
##  the same type as the variable and this reserved name. The value you
##  give the attribute will be used as the fill value for that
##  variable.

const
  FillValue* = "_FillValue"
  NC_FILL* = 0
  NC_NOFILL* = 0x100

##  Define the ioflags bits for nc_create and nc_open.
##    Currently unused in lower 16 bits:
##         0x0002
##    All upper 16 bits are unused except
##         0x20000
##
##  Lower 16 bits

const
  NC_NOWRITE* = 0x0000
  NC_WRITE* = 0x0001
  NC_CLOBBER* = 0x0000
  NC_NOCLOBBER* = 0x0004
  NC_DISKLESS* = 0x0008
  NC_MMAP* = 0x0010
  NC_64BIT_DATA* = 0x0020
  NC_CDF5* = NC_64BIT_DATA
  NC_UDF0* = 0x0040
  NC_UDF1* = 0x0080
  NC_CLASSIC_MODEL* = 0x0100
  NC_64BIT_OFFSET* = 0x0200

## * \deprecated The following flag currently is ignored, but use in
##  nc_open() or nc_create() may someday support use of advisory
##  locking to prevent multiple writers from clobbering a file
##

const
  NC_LOCK* = 0x0400

## * Share updates, limit caching.
## Use this in mode flags for both nc_create() and nc_open().

const
  NC_SHARE* = 0x0800
  NC_NETCDF4* = 0x1000

## * The following 3 flags are deprecated as of 4.6.2. Parallel I/O is now
##  initiated by calling nc_create_par and nc_open_par, no longer by flags.
##

const
  NC_MPIIO* = 0x2000
  NC_MPIPOSIX* = NC_MPIIO
  NC_PNETCDF* = (NC_MPIIO)      ## *< \deprecated
  NC_PERSIST* = 0x4000
  NC_INMEMORY* = 0x8000

##  Upper 16 bits

const
  NC_NOATTCREORD* = 0x20000
  NC_MAX_MAGIC_NUMBER_LEN* = 8

## * Format specifier for nc_set_default_format() and returned
##   by nc_inq_format. This returns the format as provided by
##   the API. See nc_inq_format_extended to see the true file format.
##   Starting with version 3.6, there are different format netCDF files.
##   4.0 introduces the third one. \see netcdf_format
##
## *@{

const
  NC_FORMAT_CLASSIC* = (1)

##  After adding CDF5 support, the NC_FORMAT_64BIT
##    flag is somewhat confusing. So, it is renamed.
##    Note that the name in the contributed code
##    NC_FORMAT_64BIT was renamed to NC_FORMAT_CDF2
##

const
  NC_FORMAT_64BIT_OFFSET* = (2)
  NC_FORMAT_64BIT* = (NC_FORMAT_64BIT_OFFSET) ## *< \deprecated Saved for compatibility.  Use NC_FORMAT_64BIT_OFFSET or NC_FORMAT_64BIT_DATA, from netCDF 4.4.0 onwards.
  NC_FORMAT_NETCDF4* = (3)
  NC_FORMAT_NETCDF4_CLASSIC* = (4)
  NC_FORMAT_64BIT_DATA* = (5)

##  Alias

const
  NC_FORMAT_CDF5* = NC_FORMAT_64BIT_DATA

##  Define a mask covering format flags only

const
  NC_FORMAT_ALL* = (NC_64BIT_OFFSET or NC_64BIT_DATA or NC_CLASSIC_MODEL or
      NC_NETCDF4 or NC_UDF0 or NC_UDF1)

## *@}
## * Extended format specifier returned by  nc_inq_format_extended()
##   Added in version 4.3.1. This returns the true format of the
##   underlying data.
##  The function returns two values
##  1. a small integer indicating the underlying source type
##     of the data. Note that this may differ from what the user
##     sees from nc_inq_format() because this latter function
##     returns what the user can expect to see thru the API.
##  2. A mode value indicating what mode flags are effectively
##     set for this dataset. This usually will be a superset
##     of the mode flags used as the argument to nc_open
##     or nc_create.
##  More or less, the #1 values track the set of dispatch tables.
##  The #1 values are as follows.
##  Note that CDF-5 returns NC_FORMAT_NC3, but sets the mode flag properly.
##
## *@{

const
  NC_FORMATX_NC3* = (1)
  NC_FORMATX_NC_HDF5* = (2)     ## *< netCDF-4 subset of HDF5
  NC_FORMATX_NC4* = NC_FORMATX_NC_HDF5
  NC_FORMATX_NC_HDF4* = (3)     ## *< netCDF-4 subset of HDF4
  NC_FORMATX_PNETCDF* = (4)
  NC_FORMATX_DAP2* = (5)
  NC_FORMATX_DAP4* = (6)
  NC_FORMATX_UDF0* = (8)
  NC_FORMATX_UDF1* = (9)
  NC_FORMATX_NCZARR* = (10)
  NC_FORMATX_UNDEFINED* = (0)

##  To avoid breaking compatibility (such as in the python library),
##    we need to retain the NC_FORMAT_xxx format as well. This may come
##   out eventually, as the NC_FORMATX is more clear that it's an extended
##   format specifier.

const
  NC_FORMAT_NC3* = NC_FORMATX_NC3
  NC_FORMAT_NC_HDF5* = NC_FORMATX_NC_HDF5
  NC_FORMAT_NC4* = NC_FORMATX_NC4
  NC_FORMAT_NC_HDF4* = NC_FORMATX_NC_HDF4
  NC_FORMAT_PNETCDF* = NC_FORMATX_PNETCDF
  NC_FORMAT_DAP2* = NC_FORMATX_DAP2
  NC_FORMAT_DAP4* = NC_FORMATX_DAP4
  NC_FORMAT_UNDEFINED* = NC_FORMATX_UNDEFINED

## *@}
## * Let nc__create() or nc__open() figure out a suitable buffer size.

const
  NC_SIZEHINT_DEFAULT* = 0

## * In nc__enddef(), align to the buffer size.

const
  NC_ALIGN_CHUNK* = csize_t.high

## * Size argument to nc_def_dim() for an unlimited dimension.

const
  NC_UNLIMITED* = 0'i32

## * Attribute id to put/get a global attribute.

const
  NC_GLOBAL* = -1

## *
## Maximum for classic library.
##
## In the classic netCDF model there are maximum values for the number of
## dimensions in the file (\ref NC_MAX_DIMS), the number of global or per
## variable attributes (\ref NC_MAX_ATTRS), the number of variables in
## the file (\ref NC_MAX_VARS), and the length of a name (\ref
## NC_MAX_NAME).
##
## These maximums are enforced by the interface, to facilitate writing
## applications and utilities.  However, nothing is statically allocated
## to these sizes internally.
##
## These maximums are not used for netCDF-4/HDF5 files unless they were
## created with the ::NC_CLASSIC_MODEL flag.
##
## As a rule, NC_MAX_VAR_DIMS <= NC_MAX_DIMS.
##
## NOTE: The NC_MAX_DIMS, NC_MAX_ATTRS, and NC_MAX_VARS limits
##       are *not* enforced after version 4.5.0
##
## *@{

const
  NC_MAX_DIMS* = 1024
  NC_MAX_ATTRS* = 8192
  NC_MAX_VARS* = 8192
  NC_MAX_NAME* = 256
  NC_MAX_VAR_DIMS* = 1024

## *@}
## * The max size of an SD dataset name in HDF4 (from HDF4
##  documentation) is 64. But in in the wild we have encountered longer
##  names. As long as the HDF4 name is not greater than NC_MAX_NAME,
##  our code will be OK.

const
  NC_MAX_HDF4_NAME* = NC_MAX_NAME

## * In HDF5 files you can set the endianness of variables with
##     nc_def_var_endian(). This define is used there.
## *@{

const
  NC_ENDIAN_NATIVE* = 0
  NC_ENDIAN_LITTLE* = 1
  NC_ENDIAN_BIG* = 2

## *@}
## * In HDF5 files you can set storage for each variable to be either
##  contiguous or chunked, with nc_def_var_chunking().  This define is
##  used there. Unknown storage is used for further extensions of HDF5
##  storage models, which should be handled transparently by netcdf
## *@{

const
  NC_CHUNKED* = 0
  NC_CONTIGUOUS* = 1
  NC_COMPACT* = 2
  NC_UNKNOWN_STORAGE* = 3
  NC_VIRTUAL* = 4

## *@}
## * In HDF5 files you can set check-summing for each variable.
## Currently the only checksum available is Fletcher-32, which can be set
## with the function nc_def_var_fletcher32.  These defines are used
## there.
## *@{

const
  NC_NOCHECKSUM* = 0
  NC_FLETCHER32* = 1

## *@}
## *@{
## * Control the HDF5 shuffle filter. In HDF5 files you can specify
##  that a shuffle filter should be used on each chunk of a variable to
##  improve compression for that variable. This per-variable shuffle
##  property can be set with the function nc_def_var_deflate().

const
  NC_NOSHUFFLE* = 0
  NC_SHUFFLE* = 1

## *@}

const
  NC_MIN_DEFLATE_LEVEL* = 0
  NC_MAX_DEFLATE_LEVEL* = 9
  NC_NOQUANTIZE* = 0
  NC_QUANTIZE_BITGROOM* = 1
  NC_QUANTIZE_GRANULARBG* = 2

## * When quantization is used for a variable, an attribute of the
##  appropriate name is added.

const
  NC_QUANTIZE_BITGROOM_ATT_NAME* = "_QuantizeBitgroomNumberOfSignificantDigits"
  NC_QUANTIZE_GRANULARBG_ATT_NAME* = "_QuantizeGranularBitGroomNumberOfSignificantDigits"

## * For quantization, the allowed value of number of significant
##  digits for float.

const
  NC_QUANTIZE_MAX_FLOAT_NSD* = (7)

## * For quantization, the allowed value of number of significant
##  digits for double.

const
  NC_QUANTIZE_MAX_DOUBLE_NSD* = (15)

## * The netcdf version 3 functions all return integer error status.
##  These are the possible values, in addition to certain values from
##  the system errno.h.
##

template NC_ISSYSERR*(err: untyped): untyped =
  ((err) > 0)

const
  NC_NOERR* = 0
  NC2_ERR* = (-1)               ## *< Returned for all errors in the v2 API.

## * Not a netcdf id.
##
## The specified netCDF ID does not refer to an
## open netCDF dataset.

const
  NC_EBADID* = (-33)
  NC_ENFILE* = (-34)            ## *< Too many netcdfs open
  NC_EEXIST* = (-35)            ## *< netcdf file exists && NC_NOCLOBBER
  NC_EINVAL* = (-36)            ## *< Invalid Argument
  NC_EPERM* = (-37)             ## *< Write to read only

## * Operation not allowed in data mode. This is returned for netCDF
## classic or 64-bit offset files, or for netCDF-4 files, when they were
## been created with ::NC_CLASSIC_MODEL flag in nc_create().

const
  NC_ENOTINDEFINE* = (-38)

## * Operation not allowed in define mode.
##
## The specified netCDF is in define mode rather than data mode.
##
## With netCDF-4/HDF5 files, this error will not occur, unless
## ::NC_CLASSIC_MODEL was used in nc_create().
##

const
  NC_EINDEFINE* = (-39)

## * Index exceeds dimension bound.
##
## The specified corner indices were out of range for the rank of the
## specified variable. For example, a negative index or an index that is
## larger than the corresponding dimension length will cause an error.

const
  NC_EINVALCOORDS* = (-40)

## * NC_MAX_DIMS exceeded. Max number of dimensions exceeded in a
## classic or 64-bit offset file, or an netCDF-4 file with
## ::NC_CLASSIC_MODEL on.

const
  NC_EMAXDIMS* = (-41)          ##  not enforced after 4.5.0
  NC_ENAMEINUSE* = (-42)        ## *< String match to name in use
  NC_ENOTATT* = (-43)           ## *< Attribute not found
  NC_EMAXATTS* = (-44)          ## *< NC_MAX_ATTRS exceeded - not enforced after 4.5.0
  NC_EBADTYPE* = (-45)          ## *< Not a netcdf data type
  NC_EBADDIM* = (-46)           ## *< Invalid dimension id or name
  NC_EUNLIMPOS* = (-47)         ## *< NC_UNLIMITED in the wrong index

## * NC_MAX_VARS exceeded. Max number of variables exceeded in a
## classic or 64-bit offset file, or an netCDF-4 file with
## ::NC_CLASSIC_MODEL on.

const
  NC_EMAXVARS* = (-48)          ##  not enforced after 4.5.0

## * Variable not found.
##
## The variable ID is invalid for the specified netCDF dataset.

const
  NC_ENOTVAR* = (-49)
  NC_EGLOBAL* = (-50)           ## *< Action prohibited on NC_GLOBAL varid
  NC_ENOTNC* = (-51)            ## *< Not a netcdf file
  NC_ESTS* = (-52)              ## *< In Fortran, string too short
  NC_EMAXNAME* = (-53)          ## *< NC_MAX_NAME exceeded
  NC_EUNLIMIT* = (-54)          ## *< NC_UNLIMITED size already in use
  NC_ENORECVARS* = (-55)        ## *< nc_rec op when there are no record vars
  NC_ECHAR* = (-56)             ## *< Attempt to convert between text & numbers

## * Start+count exceeds dimension bound.
##
## The specified edge lengths added to the specified corner would have
## referenced data out of range for the rank of the specified
## variable. For example, an edge length that is larger than the
## corresponding dimension length minus the corner index will cause an
## error.

const
  NC_EEDGE* = (-57)             ## *< Start+count exceeds dimension bound.
  NC_ESTRIDE* = (-58)           ## *< Illegal stride
  NC_EBADNAME* = (-59)          ## *< Attribute or variable name contains illegal characters

##  N.B. following must match value in ncx.h
## * Math result not representable.
##
## One or more of the values are out of the range of values representable
## by the desired type.

const
  NC_ERANGE* = (-60)
  NC_ENOMEM* = (-61)            ## *< Memory allocation (malloc) failure
  NC_EVARSIZE* = (-62)          ## *< One or more variable sizes violate format constraints
  NC_EDIMSIZE* = (-63)          ## *< Invalid dimension size
  NC_ETRUNC* = (-64)            ## *< File likely truncated or possibly corrupted
  NC_EAXISTYPE* = (-65)         ## *< Unknown axis type.

##  Following errors are added for DAP

const
  NC_EDAP* = (-66)              ## *< Generic DAP error
  NC_ECURL* = (-67)             ## *< Generic libcurl error
  NC_EIO* = (-68)               ## *< Generic IO error
  NC_ENODATA* = (-69)           ## *< Attempt to access variable with no data
  NC_EDAPSVC* = (-70)           ## *< DAP server error
  NC_EDAS* = (-71)              ## *< Malformed or inaccessible DAS
  NC_EDDS* = (-72)              ## *< Malformed or inaccessible DDS
  NC_EDMR* = NC_EDDS
  NC_EDATADDS* = (-73)          ## *< Malformed or inaccessible DATADDS
  NC_EDATADAP* = NC_EDATADDS
  NC_EDAPURL* = (-74)           ## *< Malformed DAP URL
  NC_EDAPCONSTRAINT* = (-75)    ## *< Malformed DAP Constraint
  NC_ETRANSLATION* = (-76)      ## *< Untranslatable construct
  NC_EACCESS* = (-77)           ## *< Access Failure
  NC_EAUTH* = (-78)             ## *< Authorization Failure

##  Misc. additional errors

const
  NC_ENOTFOUND* = (-90)         ## *< No such file
  NC_ECANTREMOVE* = (-91)       ## *< Can't remove file
  NC_EINTERNAL* = (-92)         ## *< NetCDF Library Internal Error
  NC_EPNETCDF* = (-93)          ## *< Error at PnetCDF layer

##  The following was added in support of netcdf-4. Make all netcdf-4
##    error codes < -100 so that errors can be added to netcdf-3 if
##    needed.

const
  NC4_FIRST_ERROR* = (-100)     ## *< @internal All HDF5 errors < this.
  NC_EHDFERR* = (-101)          ## *< Error at HDF5 layer.
  NC_ECANTREAD* = (-102)        ## *< Can't read.
  NC_ECANTWRITE* = (-103)       ## *< Can't write.
  NC_ECANTCREATE* = (-104)      ## *< Can't create.
  NC_EFILEMETA* = (-105)        ## *< Problem with file metadata.
  NC_EDIMMETA* = (-106)         ## *< Problem with dimension metadata.
  NC_EATTMETA* = (-107)         ## *< Problem with attribute metadata.
  NC_EVARMETA* = (-108)         ## *< Problem with variable metadata.
  NC_ENOCOMPOUND* = (-109)      ## *< Not a compound type.
  NC_EATTEXISTS* = (-110)       ## *< Attribute already exists.
  NC_ENOTNC4* = (-111)          ## *< Attempting netcdf-4 operation on netcdf-3 file.
  NC_ESTRICTNC3* = (-112)       ## *< Attempting netcdf-4 operation on strict nc3 netcdf-4 file.
  NC_ENOTNC3* = (-113)          ## *< Attempting netcdf-3 operation on netcdf-4 file.
  NC_ENOPAR* = (-114)           ## *< Parallel operation on file opened for non-parallel access.
  NC_EPARINIT* = (-115)         ## *< Error initializing for parallel access.
  NC_EBADGRPID* = (-116)        ## *< Bad group ID.
  NC_EBADTYPID* = (-117)        ## *< Bad type ID.
  NC_ETYPDEFINED* = (-118)      ## *< Type has already been defined and may not be edited.
  NC_EBADFIELD* = (-119)        ## *< Bad field ID.
  NC_EBADCLASS* = (-120)        ## *< Bad class.
  NC_EMAPTYPE* = (-121)         ## *< Mapped access for atomic types only.
  NC_ELATEFILL* = (-122)        ## *< Attempt to define fill value when data already exists.
  NC_ELATEDEF* = (-123)         ## *< Attempt to define var properties, like deflate, after enddef.
  NC_EDIMSCALE* = (-124)        ## *< Problem with HDF5 dimscales.
  NC_ENOGRP* = (-125)           ## *< No group found.
  NC_ESTORAGE* = (-126)         ## *< Can't specify both contiguous and chunking.
  NC_EBADCHUNK* = (-127)        ## *< Bad chunksize.
  NC_ENOTBUILT* = (-128)        ## *< Attempt to use feature that was not turned on when netCDF was built.
  NC_EDISKLESS* = (-129)        ## *< Error in using diskless  access.
  NC_ECANTEXTEND* = (-130)      ## *< Attempt to extend dataset during ind. I/O operation.
  NC_EMPI* = (-131)             ## *< MPI operation failed.
  NC_EFILTER* = (-132)          ## *< Filter operation failed.
  NC_ERCFILE* = (-133)          ## *< RC file failure
  NC_ENULLPAD* = (-134)         ## *< Header Bytes not Null-Byte padded
  NC_EINMEMORY* = (-135)        ## *< In-memory file error
  NC_ENOFILTER* = (-136)        ## *< Filter not defined on variable.
  NC_ENCZARR* = (-137)          ## *< Error at NCZarr layer.
  NC_ES3* = (-138)              ## *< Generic S3 error
  NC_EEMPTY* = (-139)           ## *< Attempt to read empty NCZarr map key
  NC_EOBJECT* = (-140)          ## *< Some object exists when it should not
  NC_ENOOBJECT* = (-141)        ## *< Some object not found
  NC_EPLUGIN* = (-142)          ## *< Unclassified failure in accessing a dynamically loaded plugin>
  NC4_LAST_ERROR* = (-142)      ## *< @internal All netCDF errors > this.

##  Errors for all remote access methods(e.g. DAP and CDMREMOTE)

const
  NC_EURL* = (NC_EDAPURL)       ## *< Malformed URL
  NC_ECONSTRAINT* = (NC_EDAPCONSTRAINT) ## *< Malformed Constraint

## * @internal This is used in netCDF-4 files for dimensions without
##  coordinate vars.

const
  DIM_WITHOUT_VARIABLE* = "This is a netCDF dimension but not a netCDF variable."

## * @internal This is here at the request of the NCO team to support
##  our mistake of having chunksizes be first ints, then
##  size_t. Doh!

const
  NC_HAVE_NEW_CHUNKING_API* = 1

##
##  The Interface
##
##  Declaration modifiers for DLL support (MSC et al)
##  #if defined(DLL_NETCDF) /* define when library is a DLL */
##  #  if defined(DLL_EXPORT) /* define when building the library */
##  #   define MSC_EXTRA __declspec(dllexport)
##  #  else
##  #   define MSC_EXTRA __declspec(dllimport)
##  #  endif
##  #  include <io.h>
##  #else
##  #define MSC_EXTRA  /**< Needed for DLL build. */
##  #endif  /* defined(DLL_NETCDF) */
##  #define EXTERNL MSC_EXTRA extern /**< Needed for DLL build. */

when defined(DLL_NETCDF):      ##  define when library is a DLL
  var ncerr* {.importc: "ncerr", dynlib: libnetcdf.}: cint
  var ncopts* {.importc: "ncopts", dynlib: libnetcdf.}: cint
proc inq_libvers*(): cstring {.importc: "nc_inq_libvers", dynlib: libnetcdf.}
proc strerror*(ncerr: cint): cstring {.importc: "nc_strerror", dynlib: libnetcdf.}
##  Set up user-defined format.


type
  NC_Dispatch = object
proc def_user_format*(mode_flag: cint; dispatch_table: ptr NC_Dispatch;
                     magic_number: cstring): cint {.importc: "nc_def_user_format",
    dynlib: libnetcdf.}
proc inq_user_format*(mode_flag: cint; dispatch_table: ptr ptr NC_Dispatch;
                     magic_number: cstring): cint {.importc: "nc_inq_user_format",
    dynlib: libnetcdf.}
proc nc_create*(path: cstring; cmode: cint; initialsz: csize_t;
             chunksizehintp: ptr csize_t; ncidp: ptr cint): cint {.
    importc: "nc__create", dynlib: libnetcdf.}
proc create*(path: cstring; cmode: cint; ncidp: ptr cint): cint {.importc: "nc_create",
    dynlib: libnetcdf.}
proc nc_open*(path: cstring; mode: cint; chunksizehintp: ptr csize_t; ncidp: ptr cint): cint {.
    importc: "nc__open", dynlib: libnetcdf.}
proc open*(path: cstring; mode: cint; ncidp: var cint): cint {.importc: "nc_open",
    dynlib: libnetcdf.}
##  Learn the path used to open/create the file.

proc inq_path*(ncid: cint; pathlen: ptr csize_t; path: cstring): cint {.
    importc: "nc_inq_path", dynlib: libnetcdf.}
##  Given an ncid and group name (NULL gets root group), return
##  locid.

proc inq_ncid*(ncid: cint; name: cstring; grp_ncid: ptr cint): cint {.
    importc: "nc_inq_ncid", dynlib: libnetcdf.}
##  Given a location id, return the number of groups it contains, and
##  an array of their locids.

proc inq_grps*(ncid: cint; numgrps: ptr cint; ncids: ptr cint): cint {.
    importc: "nc_inq_grps", dynlib: libnetcdf.}
##  Given locid, find name of group. (Root group is named "/".)

proc inq_grpname*(ncid: cint; name: cstring): cint {.importc: "nc_inq_grpname",
    dynlib: libnetcdf.}
##  Given ncid, find full name and len of full name. (Root group is
##  named "/", with length 1.)

proc inq_grpname_full*(ncid: cint; lenp: ptr csize_t; full_name: cstring): cint {.
    importc: "nc_inq_grpname_full", dynlib: libnetcdf.}
##  Given ncid, find len of full name.

proc inq_grpname_len*(ncid: cint; lenp: ptr csize_t): cint {.
    importc: "nc_inq_grpname_len", dynlib: libnetcdf.}
##  Given an ncid, find the ncid of its parent group.

proc inq_grp_parent*(ncid: cint; parent_ncid: ptr cint): cint {.
    importc: "nc_inq_grp_parent", dynlib: libnetcdf.}
##  Given a name and parent ncid, find group ncid.

proc inq_grp_ncid*(ncid: cint; grp_name: cstring; grp_ncid: ptr cint): cint {.
    importc: "nc_inq_grp_ncid", dynlib: libnetcdf.}
##  Given a full name and ncid, find group ncid.

proc inq_grp_full_ncid*(ncid: cint; full_name: cstring; grp_ncid: ptr cint): cint {.
    importc: "nc_inq_grp_full_ncid", dynlib: libnetcdf.}
##  Get a list of ids for all the variables in a group.

proc inq_varids*(ncid: cint; nvars: ptr cint; varids: ptr cint): cint {.
    importc: "nc_inq_varids", dynlib: libnetcdf.}
##  Find all dimids for a location. This finds all dimensions in a
##  group, or any of its parents.

proc inq_dimids*(ncid: cint; ndims: ptr cint; dimids: ptr cint; include_parents: cint): cint {.
    importc: "nc_inq_dimids", dynlib: libnetcdf.}
##  Find all user-defined types for a location. This finds all
##  user-defined types in a group.

proc inq_typeids*(ncid: cint; ntypes: ptr cint; typeids: ptr cint): cint {.
    importc: "nc_inq_typeids", dynlib: libnetcdf.}
##  Are two types equal?

proc inq_type_equal*(ncid1: cint; typeid1: `type`; ncid2: cint; typeid2: `type`;
                    equal: ptr cint): cint {.importc: "nc_inq_type_equal",
    dynlib: libnetcdf.}
##  Create a group. its ncid is returned in the new_ncid pointer.

proc def_grp*(parent_ncid: cint; name: cstring; new_ncid: ptr cint): cint {.
    importc: "nc_def_grp", dynlib: libnetcdf.}
##  Rename a group

proc rename_grp*(grpid: cint; name: cstring): cint {.importc: "nc_rename_grp",
    dynlib: libnetcdf.}
##  Here are functions for dealing with compound types.
##  Create a compound type.

proc def_compound*(ncid: cint; size: csize_t; name: cstring; typeidp: ptr `type`): cint {.
    importc: "nc_def_compound", dynlib: libnetcdf.}
##  Insert a named field into a compound type.

proc insert_compound*(ncid: cint; xtype: `type`; name: cstring; offset: csize_t;
                     field_typeid: `type`): cint {.importc: "nc_insert_compound",
    dynlib: libnetcdf.}
##  Insert a named array into a compound type.

proc insert_array_compound*(ncid: cint; xtype: `type`; name: cstring; offset: csize_t;
                           field_typeid: `type`; ndims: cint; dim_sizes: ptr cint): cint {.
    importc: "nc_insert_array_compound", dynlib: libnetcdf.}
##  Get the name and size of a type.

proc inq_type*(ncid: cint; xtype: `type`; name: cstring; size: ptr csize_t): cint {.
    importc: "nc_inq_type", dynlib: libnetcdf.}
##  Get the id of a type from the name, which might be a fully qualified name

proc inq_typeid*(ncid: cint; name: cstring; typeidp: ptr `type`): cint {.
    importc: "nc_inq_typeid", dynlib: libnetcdf.}
##  Get the name, size, and number of fields in a compound type.

proc inq_compound*(ncid: cint; xtype: `type`; name: cstring; sizep: ptr csize_t;
                  nfieldsp: ptr csize_t): cint {.importc: "nc_inq_compound",
    dynlib: libnetcdf.}
##  Get the name of a compound type.

proc inq_compound_name*(ncid: cint; xtype: `type`; name: cstring): cint {.
    importc: "nc_inq_compound_name", dynlib: libnetcdf.}
##  Get the size of a compound type.

proc inq_compound_size*(ncid: cint; xtype: `type`; sizep: ptr csize_t): cint {.
    importc: "nc_inq_compound_size", dynlib: libnetcdf.}
##  Get the number of fields in this compound type.

proc inq_compound_nfields*(ncid: cint; xtype: `type`; nfieldsp: ptr csize_t): cint {.
    importc: "nc_inq_compound_nfields", dynlib: libnetcdf.}
##  Given the xtype and the fieldid, get all info about it.

proc inq_compound_field*(ncid: cint; xtype: `type`; fieldid: cint; name: cstring;
                        offsetp: ptr csize_t; field_typeidp: ptr `type`;
                        ndimsp: ptr cint; dim_sizesp: ptr cint): cint {.
    importc: "nc_inq_compound_field", dynlib: libnetcdf.}
##  Given the typeid and the fieldid, get the name.

proc inq_compound_fieldname*(ncid: cint; xtype: `type`; fieldid: cint; name: cstring): cint {.
    importc: "nc_inq_compound_fieldname", dynlib: libnetcdf.}
##  Given the xtype and the name, get the fieldid.

proc inq_compound_fieldindex*(ncid: cint; xtype: `type`; name: cstring;
                             fieldidp: ptr cint): cint {.
    importc: "nc_inq_compound_fieldindex", dynlib: libnetcdf.}
##  Given the xtype and fieldid, get the offset.

proc inq_compound_fieldoffset*(ncid: cint; xtype: `type`; fieldid: cint;
                              offsetp: ptr csize_t): cint {.
    importc: "nc_inq_compound_fieldoffset", dynlib: libnetcdf.}
##  Given the xtype and the fieldid, get the type of that field.

proc inq_compound_fieldtype*(ncid: cint; xtype: `type`; fieldid: cint;
                            field_typeidp: ptr `type`): cint {.
    importc: "nc_inq_compound_fieldtype", dynlib: libnetcdf.}
##  Given the xtype and the fieldid, get the number of dimensions for
##  that field (scalars are 0).

proc inq_compound_fieldndims*(ncid: cint; xtype: `type`; fieldid: cint;
                             ndimsp: ptr cint): cint {.
    importc: "nc_inq_compound_fieldndims", dynlib: libnetcdf.}
##  Given the xtype and the fieldid, get the sizes of dimensions for
##  that field. User must have allocated storage for the dim_sizes.

proc inq_compound_fielddim_sizes*(ncid: cint; xtype: `type`; fieldid: cint;
                                 dim_sizes: ptr cint): cint {.
    importc: "nc_inq_compound_fielddim_sizes", dynlib: libnetcdf.}
## * This is the type of arrays of vlens.

type
  vlen_t* {.bycopy.} = object
    len*: csize_t              ## *< Length of VL data (in base type units)
    p*: pointer                ## *< Pointer to VL data


## * Calculate an offset for creating a compound type. This calls a
##  mysterious C macro which was found carved into one of the blocks of
##  the Newgrange passage tomb in County Meath, Ireland. This code has
##  been carbon dated to 3200 B.C.E.

template NC_COMPOUND_OFFSET*(S, M: untyped): untyped =
  (offsetof(S, M))

##  Create a variable length type.

proc def_vlen*(ncid: cint; name: cstring; base_typeid: `type`; xtypep: ptr `type`): cint {.
    importc: "nc_def_vlen", dynlib: libnetcdf.}
##  Find out about a vlen.

proc inq_vlen*(ncid: cint; xtype: `type`; name: cstring; datum_sizep: ptr csize_t;
              base_nc_typep: ptr `type`): cint {.importc: "nc_inq_vlen",
    dynlib: libnetcdf.}
##  When you read VLEN type the library will actually allocate the
##  storage space for the data. This storage space must be freed, so
##  pass the pointer back to this function, when you're done with the
##  data, and it will free the vlen memory.
##  These two functions are deprecated in favor of the nc_reclaim_data function.
##

proc free_vlen*(vl: ptr vlen_t): cint {.importc: "nc_free_vlen", dynlib: libnetcdf.}
proc free_vlens*(len: csize_t; vlens: ptr vlen_t): cint {.importc: "nc_free_vlens",
    dynlib: libnetcdf.}
##  Put or get one element in a vlen array.

proc put_vlen_element*(ncid: cint; typeid1: cint; vlen_element: pointer; len: csize_t;
                      data: pointer): cint {.importc: "nc_put_vlen_element",
    dynlib: libnetcdf.}
proc get_vlen_element*(ncid: cint; typeid1: cint; vlen_element: pointer;
                      len: ptr csize_t; data: pointer): cint {.
    importc: "nc_get_vlen_element", dynlib: libnetcdf.}
##  When you read the string type the library will allocate the storage
##  space for the data. This storage space must be freed, so pass the
##  pointer back to this function, when you're done with the data, and
##  it will free the string memory.
##  This function is deprecated in favor of the nc_reclaim_data function.
##

proc free_string*(len: csize_t; data: cstringArray): cint {.importc: "nc_free_string",
    dynlib: libnetcdf.}
##  Find out about a user defined type.

proc inq_user_type*(ncid: cint; xtype: `type`; name: cstring; size: ptr csize_t;
                   base_nc_typep: ptr `type`; nfieldsp: ptr csize_t; classp: ptr cint): cint {.
    importc: "nc_inq_user_type", dynlib: libnetcdf.}
##  Write an attribute of any type.

proc put_att*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
             op: pointer): cint {.importc: "nc_put_att", dynlib: libnetcdf.}
##  Read an attribute of any type.

proc get_att*(ncid: cint; varid: cint; name: cstring; ip: pointer): cint {.
    importc: "nc_get_att", dynlib: libnetcdf.}
##  Enum type.
##  Create an enum type. Provide a base type and a name. At the moment
##  only ints are accepted as base types.

proc def_enum*(ncid: cint; base_typeid: `type`; name: cstring; typeidp: ptr `type`): cint {.
    importc: "nc_def_enum", dynlib: libnetcdf.}
##  Insert a named value into an enum type. The value must fit within
##  the size of the enum type, the name size must be <= NC_MAX_NAME.

proc insert_enum*(ncid: cint; xtype: `type`; name: cstring; value: pointer): cint {.
    importc: "nc_insert_enum", dynlib: libnetcdf.}
##  Get information about an enum type: its name, base type and the
##  number of members defined.

proc inq_enum*(ncid: cint; xtype: `type`; name: cstring; base_nc_typep: ptr `type`;
              base_sizep: ptr csize_t; num_membersp: ptr csize_t): cint {.
    importc: "nc_inq_enum", dynlib: libnetcdf.}
##  Get information about an enum member: a name and value. Name size
##  will be <= NC_MAX_NAME.

proc inq_enum_member*(ncid: cint; xtype: `type`; idx: cint; name: cstring; value: pointer): cint {.
    importc: "nc_inq_enum_member", dynlib: libnetcdf.}
##  Get enum name from enum value. Name size will be <= NC_MAX_NAME.

proc inq_enum_ident*(ncid: cint; xtype: `type`; value: clonglong; identifier: cstring): cint {.
    importc: "nc_inq_enum_ident", dynlib: libnetcdf.}
##  Opaque type.
##  Create an opaque type. Provide a size and a name.

proc def_opaque*(ncid: cint; size: csize_t; name: cstring; xtypep: ptr `type`): cint {.
    importc: "nc_def_opaque", dynlib: libnetcdf.}
##  Get information about an opaque type.

proc inq_opaque*(ncid: cint; xtype: `type`; name: cstring; sizep: ptr csize_t): cint {.
    importc: "nc_inq_opaque", dynlib: libnetcdf.}
##  Write entire var of any type.

proc put_var*(ncid: cint; varid: cint; op: pointer): cint {.importc: "nc_put_var",
    dynlib: libnetcdf.}
##  Read entire var of any type.

proc get_var*(ncid: cint; varid: cint; ip: pointer): cint {.importc: "nc_get_var",
    dynlib: libnetcdf.}
##  Write one value.

proc put_var1*(ncid: cint; varid: cint; indexp: ptr csize_t; op: pointer): cint {.
    importc: "nc_put_var1", dynlib: libnetcdf.}
##  Read one value.

proc get_var1*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: pointer): cint {.
    importc: "nc_get_var1", dynlib: libnetcdf.}
##  Write an array of values.

proc put_vara*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
              op: pointer): cint {.importc: "nc_put_vara", dynlib: libnetcdf.}
##  Read an array of values.

proc get_vara*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
              ip: pointer): cint {.importc: "nc_get_vara", dynlib: libnetcdf.}
##  Write slices of an array of values.

proc put_vars*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
              stridep: ptr ptrdiff_t; op: pointer): cint {.importc: "nc_put_vars",
    dynlib: libnetcdf.}
##  Read slices of an array of values.

proc get_vars*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
              stridep: ptr ptrdiff_t; ip: pointer): cint {.importc: "nc_get_vars",
    dynlib: libnetcdf.}
##  Write mapped slices of an array of values.

proc put_varm*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
              stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: pointer): cint {.
    importc: "nc_put_varm", dynlib: libnetcdf.}
##  Read mapped slices of an array of values.

proc get_varm*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
              stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: pointer): cint {.
    importc: "nc_get_varm", dynlib: libnetcdf.}
##  Extra netcdf-4 stuff.
##  Set quantization settings for a variable. Quantizing data improves
##  later compression. Must be called after nc_def_var and before
##  nc_enddef.

proc def_var_quantize*(ncid: cint; varid: cint; quantize_mode: cint; nsd: cint): cint {.
    importc: "nc_def_var_quantize", dynlib: libnetcdf.}
##  Find out quantization settings of a var.

proc inq_var_quantize*(ncid: cint; varid: cint; quantize_modep: ptr cint; nsdp: ptr cint): cint {.
    importc: "nc_inq_var_quantize", dynlib: libnetcdf.}
##  Set compression settings for a variable. Lower is faster, higher is
##  better. Must be called after nc_def_var and before nc_enddef.

proc def_var_deflate*(ncid: cint; varid: cint; shuffle: cint; deflate: cint;
                     deflate_level: cint): cint {.importc: "nc_def_var_deflate",
    dynlib: libnetcdf.}
##  Find out compression settings of a var.

proc inq_var_deflate*(ncid: cint; varid: cint; shufflep: ptr cint; deflatep: ptr cint;
                     deflate_levelp: ptr cint): cint {.
    importc: "nc_inq_var_deflate", dynlib: libnetcdf.}
##  Set szip compression for a variable.

proc def_var_szip*(ncid: cint; varid: cint; options_mask: cint; pixels_per_block: cint): cint {.
    importc: "nc_def_var_szip", dynlib: libnetcdf.}
##  Find out szip settings of a var.

proc inq_var_szip*(ncid: cint; varid: cint; options_maskp: ptr cint;
                  pixels_per_blockp: ptr cint): cint {.importc: "nc_inq_var_szip",
    dynlib: libnetcdf.}
##  Set fletcher32 checksum for a var. This must be done after nc_def_var
##    and before nc_enddef.

proc def_var_fletcher32*(ncid: cint; varid: cint; fletcher32: cint): cint {.
    importc: "nc_def_var_fletcher32", dynlib: libnetcdf.}
##  Inquire about fletcher32 checksum for a var.

proc inq_var_fletcher32*(ncid: cint; varid: cint; fletcher32p: ptr cint): cint {.
    importc: "nc_inq_var_fletcher32", dynlib: libnetcdf.}
##  Define chunking for a variable. This must be done after nc_def_var
##    and before nc_enddef.

proc def_var_chunking*(ncid: cint; varid: cint; storage: cint; chunksizesp: ptr csize_t): cint {.
    importc: "nc_def_var_chunking", dynlib: libnetcdf.}
##  Inq chunking stuff for a var.

proc inq_var_chunking*(ncid: cint; varid: cint; storagep: ptr cint;
                      chunksizesp: ptr csize_t): cint {.
    importc: "nc_inq_var_chunking", dynlib: libnetcdf.}
##  Define fill value behavior for a variable. This must be done after
##    nc_def_var and before nc_enddef.

proc def_var_fill*(ncid: cint; varid: cint; no_fill: cint; fill_value: pointer): cint {.
    importc: "nc_def_var_fill", dynlib: libnetcdf.}
##  Inq fill value setting for a var.

proc inq_var_fill*(ncid: cint; varid: cint; no_fill: ptr cint; fill_valuep: pointer): cint {.
    importc: "nc_inq_var_fill", dynlib: libnetcdf.}
##  Define the endianness of a variable.

proc def_var_endian*(ncid: cint; varid: cint; endian: cint): cint {.
    importc: "nc_def_var_endian", dynlib: libnetcdf.}
##  Learn about the endianness of a variable.

proc inq_var_endian*(ncid: cint; varid: cint; endianp: ptr cint): cint {.
    importc: "nc_inq_var_endian", dynlib: libnetcdf.}
##  Define a filter for a variable

proc def_var_filter*(ncid: cint; varid: cint; id: cuint; nparams: csize_t;
                    parms: ptr cuint): cint {.importc: "nc_def_var_filter",
    dynlib: libnetcdf.}
##  Learn about the first filter on a variable

proc inq_var_filter*(ncid: cint; varid: cint; idp: ptr cuint; nparams: ptr csize_t;
                    params: ptr cuint): cint {.importc: "nc_inq_var_filter",
    dynlib: libnetcdf.}
##  Set the fill mode (classic or 64-bit offset files only).

proc set_fill*(ncid: cint; fillmode: cint; old_modep: ptr cint): cint {.
    importc: "nc_set_fill", dynlib: libnetcdf.}
##  Set the default nc_create format to NC_FORMAT_CLASSIC, NC_FORMAT_64BIT,
##  NC_FORMAT_CDF5, NC_FORMAT_NETCDF4, or NC_FORMAT_NETCDF4_CLASSIC

proc set_default_format*(format: cint; old_formatp: ptr cint): cint {.
    importc: "nc_set_default_format", dynlib: libnetcdf.}
##  Set the cache size, nelems, and preemption policy.

proc set_chunk_cache*(size: csize_t; nelems: csize_t; preemption: cfloat): cint {.
    importc: "nc_set_chunk_cache", dynlib: libnetcdf.}
##  Get the cache size, nelems, and preemption policy.

proc get_chunk_cache*(sizep: ptr csize_t; nelemsp: ptr csize_t; preemptionp: ptr cfloat): cint {.
    importc: "nc_get_chunk_cache", dynlib: libnetcdf.}
##  Set the per-variable cache size, nelems, and preemption policy.

proc set_var_chunk_cache*(ncid: cint; varid: cint; size: csize_t; nelems: csize_t;
                         preemption: cfloat): cint {.
    importc: "nc_set_var_chunk_cache", dynlib: libnetcdf.}
##  Get the per-variable cache size, nelems, and preemption policy.

proc get_var_chunk_cache*(ncid: cint; varid: cint; sizep: ptr csize_t;
                         nelemsp: ptr csize_t; preemptionp: ptr cfloat): cint {.
    importc: "nc_get_var_chunk_cache", dynlib: libnetcdf.}
proc redef*(ncid: cint): cint {.importc: "nc_redef", dynlib: libnetcdf.}
##  Is this ever used? Convert to parameter form

proc nc_enddef*(ncid: cint; h_minfree: csize_t; v_align: csize_t; v_minfree: csize_t;
             r_align: csize_t): cint {.importc: "nc__enddef", dynlib: libnetcdf.}
proc enddef*(ncid: cint): cint {.importc: "nc_enddef", dynlib: libnetcdf.}
proc sync*(ncid: cint): cint {.importc: "nc_sync", dynlib: libnetcdf.}
proc abort*(ncid: cint): cint {.importc: "nc_abort", dynlib: libnetcdf.}
proc close*(ncid: cint): cint {.importc: "nc_close", dynlib: libnetcdf.}
proc inq*(ncid: cint; ndimsp, nvarsp, nattsp,
    unlimdimidp: var cint): cint {.importc: "nc_inq", dynlib: libnetcdf.}
proc inq_ndims*(ncid: cint; ndimsp: var cint): cint {.importc: "nc_inq_ndims",
    dynlib: libnetcdf.}
proc inq_nvars*(ncid: cint; nvarsp: ptr cint): cint {.importc: "nc_inq_nvars",
    dynlib: libnetcdf.}
proc inq_natts*(ncid: cint; nattsp: ptr cint): cint {.importc: "nc_inq_natts",
    dynlib: libnetcdf.}
proc inq_unlimdim*(ncid: cint; unlimdimidp: ptr cint): cint {.
    importc: "nc_inq_unlimdim", dynlib: libnetcdf.}
##  The next function is for NetCDF-4 only

proc inq_unlimdims*(ncid: cint; nunlimdimsp: ptr cint; unlimdimidsp: ptr cint): cint {.
    importc: "nc_inq_unlimdims", dynlib: libnetcdf.}
##  Added in 3.6.1 to return format of netCDF file.

proc inq_format*(ncid: cint; formatp: ptr cint): cint {.importc: "nc_inq_format",
    dynlib: libnetcdf.}
##  Added in 4.3.1 to return additional format info

proc inq_format_extended*(ncid: cint; formatp: ptr cint; modep: ptr cint): cint {.
    importc: "nc_inq_format_extended", dynlib: libnetcdf.}
##  Begin _dim

proc def_dim*(ncid: cint; name: cstring; len: csize_t; idp: ptr cint): cint {.
    importc: "nc_def_dim", dynlib: libnetcdf.}
proc inq_dimid*(ncid: cint; name: cstring; idp: var cint): cint {.
    importc: "nc_inq_dimid", dynlib: libnetcdf.}
proc inq_dim*(ncid: cint; dimid: cint; name: cstring; lenp: ptr csize_t): cint {.
    importc: "nc_inq_dim", dynlib: libnetcdf.}
proc inq_dimname*(ncid: cint; dimid: cint; name: cstring): cint {.
    importc: "nc_inq_dimname", dynlib: libnetcdf.}
proc inq_dimlen*(ncid: cint; dimid: cint; lenp: var csize_t): cint {.
    importc: "nc_inq_dimlen", dynlib: libnetcdf.}
proc rename_dim*(ncid: cint; dimid: cint; name: cstring): cint {.
    importc: "nc_rename_dim", dynlib: libnetcdf.}
##  End _dim
##  Begin _att

proc inq_att*(ncid: cint; varid: cint; name: cstring; xtypep: ptr `type`;
             lenp: ptr csize_t): cint {.importc: "nc_inq_att", dynlib: libnetcdf.}
proc inq_attid*(ncid: cint; varid: cint; name: cstring; idp: ptr cint): cint {.
    importc: "nc_inq_attid", dynlib: libnetcdf.}
proc inq_atttype*(ncid: cint; varid: cint; name: cstring; xtypep: ptr `type`): cint {.
    importc: "nc_inq_atttype", dynlib: libnetcdf.}
proc inq_attlen*(ncid: cint; varid: cint; name: cstring; lenp: ptr csize_t): cint {.
    importc: "nc_inq_attlen", dynlib: libnetcdf.}
proc inq_attname*(ncid: cint; varid: cint; attnum: cint; name: cstring): cint {.
    importc: "nc_inq_attname", dynlib: libnetcdf.}
proc copy_att*(ncid_in: cint; varid_in: cint; name: cstring; ncid_out: cint;
              varid_out: cint): cint {.importc: "nc_copy_att", dynlib: libnetcdf.}
proc rename_att*(ncid: cint; varid: cint; name: cstring; newname: cstring): cint {.
    importc: "nc_rename_att", dynlib: libnetcdf.}
proc del_att*(ncid: cint; varid: cint; name: cstring): cint {.importc: "nc_del_att",
    dynlib: libnetcdf.}
##  End _att
##  Begin {put,get}_att

proc put_att_text*(ncid: cint; varid: cint; name: cstring; len: csize_t; op: cstring): cint {.
    importc: "nc_put_att_text", dynlib: libnetcdf.}
proc get_att_text*(ncid: cint; varid: cint; name: cstring; ip: cstring): cint {.
    importc: "nc_get_att_text", dynlib: libnetcdf.}
proc put_att_string*(ncid: cint; varid: cint; name: cstring; len: csize_t;
                    op: cstringArray): cint {.importc: "nc_put_att_string",
    dynlib: libnetcdf.}
proc get_att_string*(ncid: cint; varid: cint; name: cstring; ip: cstringArray): cint {.
    importc: "nc_get_att_string", dynlib: libnetcdf.}
proc put_att_uchar*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                   op: ptr char): cint {.importc: "nc_put_att_uchar",
                                       dynlib: libnetcdf.}
proc get_att_uchar*(ncid: cint; varid: cint; name: cstring; ip: ptr char): cint {.
    importc: "nc_get_att_uchar", dynlib: libnetcdf.}
proc put_att_schar*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                   op: ptr cchar): cint {.importc: "nc_put_att_schar",
                                      dynlib: libnetcdf.}
proc get_att_schar*(ncid: cint; varid: cint; name: cstring; ip: ptr cchar): cint {.
    importc: "nc_get_att_schar", dynlib: libnetcdf.}
proc put_att_short*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                   op: ptr cshort): cint {.importc: "nc_put_att_short",
                                       dynlib: libnetcdf.}
proc get_att_short*(ncid: cint; varid: cint; name: cstring; ip: ptr cshort): cint {.
    importc: "nc_get_att_short", dynlib: libnetcdf.}
proc put_att_int*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                 op: ptr cint): cint {.importc: "nc_put_att_int", dynlib: libnetcdf.}
proc get_att_int*(ncid: cint; varid: cint; name: cstring; ip: ptr cint): cint {.
    importc: "nc_get_att_int", dynlib: libnetcdf.}
proc put_att_long*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                  op: ptr clong): cint {.importc: "nc_put_att_long", dynlib: libnetcdf.}
proc get_att_long*(ncid: cint; varid: cint; name: cstring; ip: ptr clong): cint {.
    importc: "nc_get_att_long", dynlib: libnetcdf.}
proc put_att_float*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                   op: ptr cfloat): cint {.importc: "nc_put_att_float",
                                       dynlib: libnetcdf.}
proc get_att_float*(ncid: cint; varid: cint; name: cstring; ip: ptr cfloat): cint {.
    importc: "nc_get_att_float", dynlib: libnetcdf.}
proc put_att_double*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                    op: ptr cdouble): cint {.importc: "nc_put_att_double",
    dynlib: libnetcdf.}
proc get_att_double*(ncid: cint; varid: cint; name: cstring; ip: ptr cdouble): cint {.
    importc: "nc_get_att_double", dynlib: libnetcdf.}
proc put_att_ushort*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                    op: ptr cushort): cint {.importc: "nc_put_att_ushort",
    dynlib: libnetcdf.}
proc get_att_ushort*(ncid: cint; varid: cint; name: cstring; ip: ptr cushort): cint {.
    importc: "nc_get_att_ushort", dynlib: libnetcdf.}
proc put_att_uint*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                  op: ptr cuint): cint {.importc: "nc_put_att_uint", dynlib: libnetcdf.}
proc get_att_uint*(ncid: cint; varid: cint; name: cstring; ip: ptr cuint): cint {.
    importc: "nc_get_att_uint", dynlib: libnetcdf.}
proc put_att_longlong*(ncid: cint; varid: cint; name: cstring; xtype: `type`;
                      len: csize_t; op: ptr clonglong): cint {.
    importc: "nc_put_att_longlong", dynlib: libnetcdf.}
proc get_att_longlong*(ncid: cint; varid: cint; name: cstring; ip: ptr clonglong): cint {.
    importc: "nc_get_att_longlong", dynlib: libnetcdf.}
proc put_att_ulonglong*(ncid: cint; varid: cint; name: cstring; xtype: `type`;
                       len: csize_t; op: ptr culonglong): cint {.
    importc: "nc_put_att_ulonglong", dynlib: libnetcdf.}
proc get_att_ulonglong*(ncid: cint; varid: cint; name: cstring; ip: ptr culonglong): cint {.
    importc: "nc_get_att_ulonglong", dynlib: libnetcdf.}
##  End {put,get}_att
##  Begin _var

proc def_var*(ncid: cint; name: cstring; xtype: `type`; ndims: cint; dimidsp: ptr cint;
             varidp: ptr cint): cint {.importc: "nc_def_var", dynlib: libnetcdf.}
proc inq_var*(ncid: cint; varid: cint; name: cstring; xtypep: ptr `type`;
             ndimsp: ptr cint; dimidsp: ptr cint; nattsp: ptr cint): cint {.
    importc: "nc_inq_var", dynlib: libnetcdf.}
proc inq_varid*(ncid: cint; name: cstring; varidp: ptr cint): cint {.
    importc: "nc_inq_varid", dynlib: libnetcdf.}
proc inq_varname*(ncid: cint; varid: cint; name: cstring): cint {.
    importc: "nc_inq_varname", dynlib: libnetcdf.}
proc inq_vartype*(ncid: cint; varid: cint; xtypep: ptr `type`): cint {.
    importc: "nc_inq_vartype", dynlib: libnetcdf.}
proc inq_varndims*(ncid: cint; varid: cint; ndimsp: ptr cint): cint {.
    importc: "nc_inq_varndims", dynlib: libnetcdf.}
proc inq_vardimid*(ncid: cint; varid: cint; dimidsp: ptr cint): cint {.
    importc: "nc_inq_vardimid", dynlib: libnetcdf.}
proc inq_varnatts*(ncid: cint; varid: cint; nattsp: ptr cint): cint {.
    importc: "nc_inq_varnatts", dynlib: libnetcdf.}
proc rename_var*(ncid: cint; varid: cint; name: cstring): cint {.
    importc: "nc_rename_var", dynlib: libnetcdf.}
proc copy_var*(ncid_in: cint; varid: cint; ncid_out: cint): cint {.
    importc: "nc_copy_var", dynlib: libnetcdf.}
when not defined(ncvarcpy):
  ##  support the old name for now
  template ncvarcpy*(ncid_in, varid, ncid_out: untyped): untyped =
    ncvarcopy((ncid_in), (varid), (ncid_out))

##  End _var
##  Begin {put,get}_var1

proc put_var1_text*(ncid: cint; varid: cint; indexp: ptr csize_t; op: cstring): cint {.
    importc: "nc_put_var1_text", dynlib: libnetcdf.}
proc get_var1_text*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: cstring): cint {.
    importc: "nc_get_var1_text", dynlib: libnetcdf.}
proc put_var1_uchar*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr char): cint {.
    importc: "nc_put_var1_uchar", dynlib: libnetcdf.}
proc get_var1_uchar*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr char): cint {.
    importc: "nc_get_var1_uchar", dynlib: libnetcdf.}
proc put_var1_schar*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr cchar): cint {.
    importc: "nc_put_var1_schar", dynlib: libnetcdf.}
proc get_var1_schar*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr cchar): cint {.
    importc: "nc_get_var1_schar", dynlib: libnetcdf.}
proc put_var1_short*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr cshort): cint {.
    importc: "nc_put_var1_short", dynlib: libnetcdf.}
proc get_var1_short*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr cshort): cint {.
    importc: "nc_get_var1_short", dynlib: libnetcdf.}
proc put_var1_int*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr cint): cint {.
    importc: "nc_put_var1_int", dynlib: libnetcdf.}
proc get_var1_int*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr cint): cint {.
    importc: "nc_get_var1_int", dynlib: libnetcdf.}
proc put_var1_long*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr clong): cint {.
    importc: "nc_put_var1_long", dynlib: libnetcdf.}
proc get_var1_long*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr clong): cint {.
    importc: "nc_get_var1_long", dynlib: libnetcdf.}
proc put_var1_float*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr cfloat): cint {.
    importc: "nc_put_var1_float", dynlib: libnetcdf.}
proc get_var1_float*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr cfloat): cint {.
    importc: "nc_get_var1_float", dynlib: libnetcdf.}
proc put_var1_double*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr cdouble): cint {.
    importc: "nc_put_var1_double", dynlib: libnetcdf.}
proc get_var1_double*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr cdouble): cint {.
    importc: "nc_get_var1_double", dynlib: libnetcdf.}
proc put_var1_ushort*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr cushort): cint {.
    importc: "nc_put_var1_ushort", dynlib: libnetcdf.}
proc get_var1_ushort*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr cushort): cint {.
    importc: "nc_get_var1_ushort", dynlib: libnetcdf.}
proc put_var1_uint*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr cuint): cint {.
    importc: "nc_put_var1_uint", dynlib: libnetcdf.}
proc get_var1_uint*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr cuint): cint {.
    importc: "nc_get_var1_uint", dynlib: libnetcdf.}
proc put_var1_longlong*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr clonglong): cint {.
    importc: "nc_put_var1_longlong", dynlib: libnetcdf.}
proc get_var1_longlong*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr clonglong): cint {.
    importc: "nc_get_var1_longlong", dynlib: libnetcdf.}
proc put_var1_ulonglong*(ncid: cint; varid: cint; indexp: ptr csize_t;
                        op: ptr culonglong): cint {.
    importc: "nc_put_var1_ulonglong", dynlib: libnetcdf.}
proc get_var1_ulonglong*(ncid: cint; varid: cint; indexp: ptr csize_t;
                        ip: ptr culonglong): cint {.
    importc: "nc_get_var1_ulonglong", dynlib: libnetcdf.}
proc put_var1_string*(ncid: cint; varid: cint; indexp: ptr csize_t; op: cstringArray): cint {.
    importc: "nc_put_var1_string", dynlib: libnetcdf.}
proc get_var1_string*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: cstringArray): cint {.
    importc: "nc_get_var1_string", dynlib: libnetcdf.}
##  End {put,get}_var1
##  Begin {put,get}_vara

proc put_vara_text*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   op: cstring): cint {.importc: "nc_put_vara_text",
                                     dynlib: libnetcdf.}
proc get_vara_text*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   ip: cstring): cint {.importc: "nc_get_vara_text",
                                     dynlib: libnetcdf.}
proc put_vara_uchar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    op: ptr char): cint {.importc: "nc_put_vara_uchar",
                                        dynlib: libnetcdf.}
proc get_vara_uchar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    ip: ptr char): cint {.importc: "nc_get_vara_uchar",
                                        dynlib: libnetcdf.}
proc put_vara_schar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    op: ptr cchar): cint {.importc: "nc_put_vara_schar",
                                       dynlib: libnetcdf.}
proc get_vara_schar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    ip: ptr cchar): cint {.importc: "nc_get_vara_schar",
                                       dynlib: libnetcdf.}
proc put_vara_short*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    op: ptr cshort): cint {.importc: "nc_put_vara_short",
                                        dynlib: libnetcdf.}
proc get_vara_short*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    ip: ptr cshort): cint {.importc: "nc_get_vara_short",
                                        dynlib: libnetcdf.}
proc put_vara_int*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                  op: ptr cint): cint {.importc: "nc_put_vara_int", dynlib: libnetcdf.}
proc get_vara_int*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                  ip: ptr cint): cint {.importc: "nc_get_vara_int", dynlib: libnetcdf.}
proc put_vara_long*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   op: ptr clong): cint {.importc: "nc_put_vara_long",
                                      dynlib: libnetcdf.}
proc get_vara_long*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   ip: ptr clong): cint {.importc: "nc_get_vara_long",
                                      dynlib: libnetcdf.}
proc put_vara_float*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    op: ptr cfloat): cint {.importc: "nc_put_vara_float",
                                        dynlib: libnetcdf.}
proc get_vara_float*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    ip: ptr cfloat): cint {.importc: "nc_get_vara_float",
                                        dynlib: libnetcdf.}
proc put_vara_double*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     op: ptr cdouble): cint {.importc: "nc_put_vara_double",
    dynlib: libnetcdf.}
proc get_vara_double*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     ip: ptr cdouble): cint {.importc: "nc_get_vara_double",
    dynlib: libnetcdf.}
proc put_vara_ushort*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     op: ptr cushort): cint {.importc: "nc_put_vara_ushort",
    dynlib: libnetcdf.}
proc get_vara_ushort*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     ip: ptr cushort): cint {.importc: "nc_get_vara_ushort",
    dynlib: libnetcdf.}
proc put_vara_uint*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   op: ptr cuint): cint {.importc: "nc_put_vara_uint",
                                      dynlib: libnetcdf.}
proc get_vara_uint*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   ip: ptr cuint): cint {.importc: "nc_get_vara_uint",
                                      dynlib: libnetcdf.}
proc put_vara_longlong*(ncid: cint; varid: cint; startp: ptr csize_t;
                       countp: ptr csize_t; op: ptr clonglong): cint {.
    importc: "nc_put_vara_longlong", dynlib: libnetcdf.}
proc get_vara_longlong*(ncid: cint; varid: cint; startp: ptr csize_t;
                       countp: ptr csize_t; ip: ptr clonglong): cint {.
    importc: "nc_get_vara_longlong", dynlib: libnetcdf.}
proc put_vara_ulonglong*(ncid: cint; varid: cint; startp: ptr csize_t;
                        countp: ptr csize_t; op: ptr culonglong): cint {.
    importc: "nc_put_vara_ulonglong", dynlib: libnetcdf.}
proc get_vara_ulonglong*(ncid: cint; varid: cint; startp: ptr csize_t;
                        countp: ptr csize_t; ip: ptr culonglong): cint {.
    importc: "nc_get_vara_ulonglong", dynlib: libnetcdf.}
proc put_vara_string*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     op: cstringArray): cint {.importc: "nc_put_vara_string",
    dynlib: libnetcdf.}
proc get_vara_string*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     ip: cstringArray): cint {.importc: "nc_get_vara_string",
    dynlib: libnetcdf.}
##  End {put,get}_vara
##  Begin {put,get}_vars

proc put_vars_text*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; op: cstring): cint {.
    importc: "nc_put_vars_text", dynlib: libnetcdf.}
proc get_vars_text*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; ip: cstring): cint {.
    importc: "nc_get_vars_text", dynlib: libnetcdf.}
proc put_vars_uchar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; op: ptr char): cint {.
    importc: "nc_put_vars_uchar", dynlib: libnetcdf.}
proc get_vars_uchar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; ip: ptr char): cint {.
    importc: "nc_get_vars_uchar", dynlib: libnetcdf.}
proc put_vars_schar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; op: ptr cchar): cint {.
    importc: "nc_put_vars_schar", dynlib: libnetcdf.}
proc get_vars_schar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; ip: ptr cchar): cint {.
    importc: "nc_get_vars_schar", dynlib: libnetcdf.}
proc put_vars_short*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; op: ptr cshort): cint {.
    importc: "nc_put_vars_short", dynlib: libnetcdf.}
proc get_vars_short*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; ip: ptr cshort): cint {.
    importc: "nc_get_vars_short", dynlib: libnetcdf.}
proc put_vars_int*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                  stridep: ptr ptrdiff_t; op: ptr cint): cint {.
    importc: "nc_put_vars_int", dynlib: libnetcdf.}
proc get_vars_int*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                  stridep: ptr ptrdiff_t; ip: ptr cint): cint {.
    importc: "nc_get_vars_int", dynlib: libnetcdf.}
proc put_vars_long*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; op: ptr clong): cint {.
    importc: "nc_put_vars_long", dynlib: libnetcdf.}
proc get_vars_long*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; ip: ptr clong): cint {.
    importc: "nc_get_vars_long", dynlib: libnetcdf.}
proc put_vars_float*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; op: ptr cfloat): cint {.
    importc: "nc_put_vars_float", dynlib: libnetcdf.}
proc get_vars_float*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; ip: ptr cfloat): cint {.
    importc: "nc_get_vars_float", dynlib: libnetcdf.}
proc put_vars_double*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; op: ptr cdouble): cint {.
    importc: "nc_put_vars_double", dynlib: libnetcdf.}
proc get_vars_double*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; ip: ptr cdouble): cint {.
    importc: "nc_get_vars_double", dynlib: libnetcdf.}
proc put_vars_ushort*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; op: ptr cushort): cint {.
    importc: "nc_put_vars_ushort", dynlib: libnetcdf.}
proc get_vars_ushort*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; ip: ptr cushort): cint {.
    importc: "nc_get_vars_ushort", dynlib: libnetcdf.}
proc put_vars_uint*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; op: ptr cuint): cint {.
    importc: "nc_put_vars_uint", dynlib: libnetcdf.}
proc get_vars_uint*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; ip: ptr cuint): cint {.
    importc: "nc_get_vars_uint", dynlib: libnetcdf.}
proc put_vars_longlong*(ncid: cint; varid: cint; startp: ptr csize_t;
                       countp: ptr csize_t; stridep: ptr ptrdiff_t; op: ptr clonglong): cint {.
    importc: "nc_put_vars_longlong", dynlib: libnetcdf.}
proc get_vars_longlong*(ncid: cint; varid: cint; startp: ptr csize_t;
                       countp: ptr csize_t; stridep: ptr ptrdiff_t; ip: ptr clonglong): cint {.
    importc: "nc_get_vars_longlong", dynlib: libnetcdf.}
proc put_vars_ulonglong*(ncid: cint; varid: cint; startp: ptr csize_t;
                        countp: ptr csize_t; stridep: ptr ptrdiff_t;
                        op: ptr culonglong): cint {.
    importc: "nc_put_vars_ulonglong", dynlib: libnetcdf.}
proc get_vars_ulonglong*(ncid: cint; varid: cint; startp: ptr csize_t;
                        countp: ptr csize_t; stridep: ptr ptrdiff_t;
                        ip: ptr culonglong): cint {.
    importc: "nc_get_vars_ulonglong", dynlib: libnetcdf.}
proc put_vars_string*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; op: cstringArray): cint {.
    importc: "nc_put_vars_string", dynlib: libnetcdf.}
proc get_vars_string*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; ip: cstringArray): cint {.
    importc: "nc_get_vars_string", dynlib: libnetcdf.}
##  End {put,get}_vars
##  Begin {put,get}_varm

proc put_varm_text*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: cstring): cint {.
    importc: "nc_put_varm_text", dynlib: libnetcdf.}
proc get_varm_text*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: cstring): cint {.
    importc: "nc_get_varm_text", dynlib: libnetcdf.}
proc put_varm_uchar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr char): cint {.
    importc: "nc_put_varm_uchar", dynlib: libnetcdf.}
proc get_varm_uchar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr char): cint {.
    importc: "nc_get_varm_uchar", dynlib: libnetcdf.}
proc put_varm_schar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr cchar): cint {.
    importc: "nc_put_varm_schar", dynlib: libnetcdf.}
proc get_varm_schar*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr cchar): cint {.
    importc: "nc_get_varm_schar", dynlib: libnetcdf.}
proc put_varm_short*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr cshort): cint {.
    importc: "nc_put_varm_short", dynlib: libnetcdf.}
proc get_varm_short*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr cshort): cint {.
    importc: "nc_get_varm_short", dynlib: libnetcdf.}
proc put_varm_int*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                  stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr cint): cint {.
    importc: "nc_put_varm_int", dynlib: libnetcdf.}
proc get_varm_int*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                  stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr cint): cint {.
    importc: "nc_get_varm_int", dynlib: libnetcdf.}
proc put_varm_long*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr clong): cint {.
    importc: "nc_put_varm_long", dynlib: libnetcdf.}
proc get_varm_long*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr clong): cint {.
    importc: "nc_get_varm_long", dynlib: libnetcdf.}
proc put_varm_float*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr cfloat): cint {.
    importc: "nc_put_varm_float", dynlib: libnetcdf.}
proc get_varm_float*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr cfloat): cint {.
    importc: "nc_get_varm_float", dynlib: libnetcdf.}
proc put_varm_double*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr cdouble): cint {.
    importc: "nc_put_varm_double", dynlib: libnetcdf.}
proc get_varm_double*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr cdouble): cint {.
    importc: "nc_get_varm_double", dynlib: libnetcdf.}
proc put_varm_ushort*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr cushort): cint {.
    importc: "nc_put_varm_ushort", dynlib: libnetcdf.}
proc get_varm_ushort*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr cushort): cint {.
    importc: "nc_get_varm_ushort", dynlib: libnetcdf.}
proc put_varm_uint*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr cuint): cint {.
    importc: "nc_put_varm_uint", dynlib: libnetcdf.}
proc get_varm_uint*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                   stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr cuint): cint {.
    importc: "nc_get_varm_uint", dynlib: libnetcdf.}
proc put_varm_longlong*(ncid: cint; varid: cint; startp: ptr csize_t;
                       countp: ptr csize_t; stridep: ptr ptrdiff_t;
                       imapp: ptr ptrdiff_t; op: ptr clonglong): cint {.
    importc: "nc_put_varm_longlong", dynlib: libnetcdf.}
proc get_varm_longlong*(ncid: cint; varid: cint; startp: ptr csize_t;
                       countp: ptr csize_t; stridep: ptr ptrdiff_t;
                       imapp: ptr ptrdiff_t; ip: ptr clonglong): cint {.
    importc: "nc_get_varm_longlong", dynlib: libnetcdf.}
proc put_varm_ulonglong*(ncid: cint; varid: cint; startp: ptr csize_t;
                        countp: ptr csize_t; stridep: ptr ptrdiff_t;
                        imapp: ptr ptrdiff_t; op: ptr culonglong): cint {.
    importc: "nc_put_varm_ulonglong", dynlib: libnetcdf.}
proc get_varm_ulonglong*(ncid: cint; varid: cint; startp: ptr csize_t;
                        countp: ptr csize_t; stridep: ptr ptrdiff_t;
                        imapp: ptr ptrdiff_t; ip: ptr culonglong): cint {.
    importc: "nc_get_varm_ulonglong", dynlib: libnetcdf.}
proc put_varm_string*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: cstringArray): cint {.
    importc: "nc_put_varm_string", dynlib: libnetcdf.}
proc get_varm_string*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                     stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: cstringArray): cint {.
    importc: "nc_get_varm_string", dynlib: libnetcdf.}
##  End {put,get}_varm
##  Begin {put,get}_var

proc put_var_text*(ncid: cint; varid: cint; op: cstring): cint {.
    importc: "nc_put_var_text", dynlib: libnetcdf.}
proc get_var_text*(ncid: cint; varid: cint; ip: cstring): cint {.
    importc: "nc_get_var_text", dynlib: libnetcdf.}
proc put_var_uchar*(ncid: cint; varid: cint; op: ptr char): cint {.
    importc: "nc_put_var_uchar", dynlib: libnetcdf.}
proc get_var_uchar*(ncid: cint; varid: cint; ip: ptr char): cint {.
    importc: "nc_get_var_uchar", dynlib: libnetcdf.}
proc put_var_schar*(ncid: cint; varid: cint; op: ptr cchar): cint {.
    importc: "nc_put_var_schar", dynlib: libnetcdf.}
proc get_var_schar*(ncid: cint; varid: cint; ip: ptr cchar): cint {.
    importc: "nc_get_var_schar", dynlib: libnetcdf.}
proc put_var_short*(ncid: cint; varid: cint; op: ptr cshort): cint {.
    importc: "nc_put_var_short", dynlib: libnetcdf.}
proc get_var_short*(ncid: cint; varid: cint; ip: ptr cshort): cint {.
    importc: "nc_get_var_short", dynlib: libnetcdf.}
proc put_var_int*(ncid: cint; varid: cint; op: ptr cint): cint {.
    importc: "nc_put_var_int", dynlib: libnetcdf.}
proc get_var_int*(ncid: cint; varid: cint; ip: ptr cint): cint {.
    importc: "nc_get_var_int", dynlib: libnetcdf.}
proc put_var_long*(ncid: cint; varid: cint; op: ptr clong): cint {.
    importc: "nc_put_var_long", dynlib: libnetcdf.}
proc get_var_long*(ncid: cint; varid: cint; ip: ptr clong): cint {.
    importc: "nc_get_var_long", dynlib: libnetcdf.}
proc put_var_float*(ncid: cint; varid: cint; op: ptr cfloat): cint {.
    importc: "nc_put_var_float", dynlib: libnetcdf.}
proc get_var_float*(ncid: cint; varid: cint; ip: ptr cfloat): cint {.
    importc: "nc_get_var_float", dynlib: libnetcdf.}
proc put_var_double*(ncid: cint; varid: cint; op: ptr cdouble): cint {.
    importc: "nc_put_var_double", dynlib: libnetcdf.}
proc get_var_double*(ncid: cint; varid: cint; ip: ptr cdouble): cint {.
    importc: "nc_get_var_double", dynlib: libnetcdf.}
proc put_var_ushort*(ncid: cint; varid: cint; op: ptr cushort): cint {.
    importc: "nc_put_var_ushort", dynlib: libnetcdf.}
proc get_var_ushort*(ncid: cint; varid: cint; ip: ptr cushort): cint {.
    importc: "nc_get_var_ushort", dynlib: libnetcdf.}
proc put_var_uint*(ncid: cint; varid: cint; op: ptr cuint): cint {.
    importc: "nc_put_var_uint", dynlib: libnetcdf.}
proc get_var_uint*(ncid: cint; varid: cint; ip: ptr cuint): cint {.
    importc: "nc_get_var_uint", dynlib: libnetcdf.}
proc put_var_longlong*(ncid: cint; varid: cint; op: ptr clonglong): cint {.
    importc: "nc_put_var_longlong", dynlib: libnetcdf.}
proc get_var_longlong*(ncid: cint; varid: cint; ip: ptr clonglong): cint {.
    importc: "nc_get_var_longlong", dynlib: libnetcdf.}
proc put_var_ulonglong*(ncid: cint; varid: cint; op: ptr culonglong): cint {.
    importc: "nc_put_var_ulonglong", dynlib: libnetcdf.}
proc get_var_ulonglong*(ncid: cint; varid: cint; ip: ptr culonglong): cint {.
    importc: "nc_get_var_ulonglong", dynlib: libnetcdf.}
proc put_var_string*(ncid: cint; varid: cint; op: cstringArray): cint {.
    importc: "nc_put_var_string", dynlib: libnetcdf.}
proc get_var_string*(ncid: cint; varid: cint; ip: cstringArray): cint {.
    importc: "nc_get_var_string", dynlib: libnetcdf.}
##  Begin recursive instance walking functions
## *
## Reclaim a vector of instances of arbitrary type.  Intended for
## use with e.g. nc_get_vara or the input to e.g. nc_put_vara.
## This recursively walks the top-level instances to reclaim any
## nested data such as vlen or strings or such.
##
## Assumes it is passed a pointer to count instances of xtype.
## Reclaims any nested data.
##
## WARNING: nc_reclaim_data does not reclaim the top-level
## memory because we do not know how it was allocated.  However
## nc_reclaim_data_all does reclaim top-level memory.
##
## WARNING: all data blocks below the top-level (e.g. string
## instances) will be reclaimed, so do not call if there is any
## static data in the instance.
##
## Should work for any netcdf format.
##

proc reclaim_data*(ncid: cint; xtypeid: `type`; memory: pointer; count: csize_t): cint {.
    importc: "nc_reclaim_data", dynlib: libnetcdf.}
proc reclaim_data_all*(ncid: cint; xtypeid: `type`; memory: pointer; count: csize_t): cint {.
    importc: "nc_reclaim_data_all", dynlib: libnetcdf.}
## *
##
## Copy vector of arbitrary type instances.  This recursively walks
## the top-level instances to copy any nested data such as vlen or
## strings or such.
##
## Assumes it is passed a pointer to count instances of xtype.
## WARNING: nc_copy_data does not copy the top-level memory, but
## assumes a block of proper size was passed in.  However
## nc_copy_data_all does allocate top-level memory copy.
##
## Should work for any netcdf format.
##

proc copy_data*(ncid: cint; xtypeid: `type`; memory: pointer; count: csize_t;
               copy: pointer): cint {.importc: "nc_copy_data", dynlib: libnetcdf.}
proc copy_data_all*(ncid: cint; xtypeid: `type`; memory: pointer; count: csize_t;
                   copyp: ptr pointer): cint {.importc: "nc_copy_data_all",
    dynlib: libnetcdf.}
##  Instance dumper for debugging

proc dump_data*(ncid: cint; xtypeid: `type`; memory: pointer; count: csize_t;
               buf: cstringArray): cint {.importc: "nc_dump_data", dynlib: libnetcdf.}
##  end recursive instance walking functions
##  Begin Deprecated, same as functions with "_ubyte" replaced by "_uchar"

proc put_att_ubyte*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: csize_t;
                   op: ptr uint8): cint {.importc: "nc_put_att_ubyte",
                                       dynlib: libnetcdf.}
proc get_att_ubyte*(ncid: cint; varid: cint; name: cstring; ip: ptr uint8): cint {.
    importc: "nc_get_att_ubyte", dynlib: libnetcdf.}
proc put_var1_ubyte*(ncid: cint; varid: cint; indexp: ptr csize_t; op: ptr uint8): cint {.
    importc: "nc_put_var1_ubyte", dynlib: libnetcdf.}
proc get_var1_ubyte*(ncid: cint; varid: cint; indexp: ptr csize_t; ip: ptr uint8): cint {.
    importc: "nc_get_var1_ubyte", dynlib: libnetcdf.}
proc put_vara_ubyte*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    op: ptr uint8): cint {.importc: "nc_put_vara_ubyte",
                                        dynlib: libnetcdf.}
proc get_vara_ubyte*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    ip: ptr uint8): cint {.importc: "nc_get_vara_ubyte",
                                        dynlib: libnetcdf.}
proc put_vars_ubyte*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; op: ptr uint8): cint {.
    importc: "nc_put_vars_ubyte", dynlib: libnetcdf.}
proc get_vars_ubyte*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; ip: ptr uint8): cint {.
    importc: "nc_get_vars_ubyte", dynlib: libnetcdf.}
proc put_varm_ubyte*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; op: ptr uint8): cint {.
    importc: "nc_put_varm_ubyte", dynlib: libnetcdf.}
proc get_varm_ubyte*(ncid: cint; varid: cint; startp: ptr csize_t; countp: ptr csize_t;
                    stridep: ptr ptrdiff_t; imapp: ptr ptrdiff_t; ip: ptr uint8): cint {.
    importc: "nc_get_varm_ubyte", dynlib: libnetcdf.}
proc put_var_ubyte*(ncid: cint; varid: cint; op: ptr uint8): cint {.
    importc: "nc_put_var_ubyte", dynlib: libnetcdf.}
proc get_var_ubyte*(ncid: cint; varid: cint; ip: ptr uint8): cint {.
    importc: "nc_get_var_ubyte", dynlib: libnetcdf.}
##  End Deprecated
##  Set the log level. 0 shows only errors, 1 only major messages,
##  etc., to 5, which shows way too much information.

proc set_log_level*(new_level: cint): cint {.importc: "nc_set_log_level",
    dynlib: libnetcdf.}
##  Use this to turn off logging by calling
##    nc_log_level(NC_TURN_OFF_LOGGING)

const
  NC_TURN_OFF_LOGGING* = (-1)

##  Show the netCDF library's in-memory metadata for a file.

proc show_metadata*(ncid: cint): cint {.importc: "nc_show_metadata", dynlib: libnetcdf.}
##  End {put,get}_var
##  Delete a file.

proc delete*(path: cstring): cint {.importc: "nc_delete", dynlib: libnetcdf.}
##
##  The following functions were written to accommodate the old Cray
##  systems. Modern HPC systems do not use these functions any more,
##  but use the nc_open_par()/nc_create_par() functions instead. These
##  functions are retained for backward compatibibility. These
##  functions work as advertised, but you can only use "processor
##  element" 0.
##

proc nc_create_mp*(path: cstring; cmode: cint; initialsz: csize_t; basepe: cint;
                chunksizehintp: ptr csize_t; ncidp: ptr cint): cint {.
    importc: "nc__create_mp", dynlib: libnetcdf.}
proc nc_open_mp*(path: cstring; mode: cint; basepe: cint; chunksizehintp: ptr csize_t;
              ncidp: ptr cint): cint {.importc: "nc__open_mp", dynlib: libnetcdf.}
proc delete_mp*(path: cstring; basepe: cint): cint {.importc: "nc_delete_mp",
    dynlib: libnetcdf.}
proc set_base_pe*(ncid: cint; pe: cint): cint {.importc: "nc_set_base_pe",
    dynlib: libnetcdf.}
proc inq_base_pe*(ncid: cint; pe: ptr cint): cint {.importc: "nc_inq_base_pe",
    dynlib: libnetcdf.}
##  This v2 function is used in the nc_test program.

proc nctypelen*(datatype: `type`): cint {.importc: "nctypelen", dynlib: libnetcdf.}
##  Begin v2.4 backward compatibility
## * Backward compatible alias.
## *@{

const
  FILL_BYTE* = NC_FILL_BYTE
  FILL_CHAR* = NC_FILL_CHAR
  FILL_SHORT* = NC_FILL_SHORT
  FILL_LONG* = NC_FILL_INT
  FILL_FLOAT* = NC_FILL_FLOAT
  FILL_DOUBLE* = NC_FILL_DOUBLE
  MAX_NC_DIMS* = NC_MAX_DIMS
  MAX_NC_ATTRS* = NC_MAX_ATTRS
  MAX_NC_VARS* = NC_MAX_VARS
  MAX_NC_NAME* = NC_MAX_NAME
  MAX_VAR_DIMS* = NC_MAX_VAR_DIMS

## *@}
##
##  Global error status
##

var ncerr* {.importc: "ncerr", dynlib: libnetcdf.}: cint

const
  NC_ENTOOL* = NC_EMAXNAME
  NC_EXDR* = (-32)              ## *< V2 API error.
  NC_SYSERR* = (-31)            ## *< V2 API system error.

##
##  Global options variable.
##  Used to determine behavior of error handler.
##

const
  NC_FATAL* = 1
  NC_VERBOSE* = 2

## * V2 API error handling. Default is (NC_FATAL | NC_VERBOSE).

var ncopts* {.importc: "ncopts", dynlib: libnetcdf.}: cint

proc advise*(cdf_routine_name: cstring; err: cint; fmt: cstring) {.varargs,
    importc: "nc_advise", dynlib: libnetcdf.}
## *
##  C data type corresponding to a netCDF NC_LONG argument, a signed 32
##  bit object. This is the only thing in this file which architecture
##  dependent.
##

type
  nclong* = cint

proc nccreate*(path: cstring; cmode: cint): cint {.importc: "nccreate",
    dynlib: libnetcdf.}
proc ncopen*(path: cstring; mode: cint): cint {.importc: "ncopen", dynlib: libnetcdf.}
proc ncsetfill*(ncid: cint; fillmode: cint): cint {.importc: "ncsetfill",
    dynlib: libnetcdf.}
proc ncredef*(ncid: cint): cint {.importc: "ncredef", dynlib: libnetcdf.}
proc ncendef*(ncid: cint): cint {.importc: "ncendef", dynlib: libnetcdf.}
proc ncsync*(ncid: cint): cint {.importc: "ncsync", dynlib: libnetcdf.}
proc ncabort*(ncid: cint): cint {.importc: "ncabort", dynlib: libnetcdf.}
proc ncclose*(ncid: cint): cint {.importc: "ncclose", dynlib: libnetcdf.}
proc ncinquire*(ncid: cint; ndimsp: ptr cint; nvarsp: ptr cint; nattsp: ptr cint;
               unlimdimp: ptr cint): cint {.importc: "ncinquire", dynlib: libnetcdf.}
proc ncdimdef*(ncid: cint; name: cstring; len: clong): cint {.importc: "ncdimdef",
    dynlib: libnetcdf.}
proc ncdimid*(ncid: cint; name: cstring): cint {.importc: "ncdimid", dynlib: libnetcdf.}
proc ncdiminq*(ncid: cint; dimid: cint; name: cstring; lenp: ptr clong): cint {.
    importc: "ncdiminq", dynlib: libnetcdf.}
proc ncdimrename*(ncid: cint; dimid: cint; name: cstring): cint {.
    importc: "ncdimrename", dynlib: libnetcdf.}
proc ncattput*(ncid: cint; varid: cint; name: cstring; xtype: `type`; len: cint;
              op: pointer): cint {.importc: "ncattput", dynlib: libnetcdf.}
proc ncattinq*(ncid: cint; varid: cint; name: cstring; xtypep: ptr `type`; lenp: ptr cint): cint {.
    importc: "ncattinq", dynlib: libnetcdf.}
proc ncattget*(ncid: cint; varid: cint; name: cstring; ip: pointer): cint {.
    importc: "ncattget", dynlib: libnetcdf.}
proc ncattcopy*(ncid_in: cint; varid_in: cint; name: cstring; ncid_out: cint;
               varid_out: cint): cint {.importc: "ncattcopy", dynlib: libnetcdf.}
proc ncattname*(ncid: cint; varid: cint; attnum: cint; name: cstring): cint {.
    importc: "ncattname", dynlib: libnetcdf.}
proc ncattrename*(ncid: cint; varid: cint; name: cstring; newname: cstring): cint {.
    importc: "ncattrename", dynlib: libnetcdf.}
proc ncattdel*(ncid: cint; varid: cint; name: cstring): cint {.importc: "ncattdel",
    dynlib: libnetcdf.}
proc ncvardef*(ncid: cint; name: cstring; xtype: `type`; ndims: cint; dimidsp: ptr cint): cint {.
    importc: "ncvardef", dynlib: libnetcdf.}
proc ncvarid*(ncid: cint; name: cstring): cint {.importc: "ncvarid", dynlib: libnetcdf.}
proc ncvarinq*(ncid: cint; varid: cint; name: cstring; xtypep: ptr `type`;
              ndimsp: ptr cint; dimidsp: ptr cint; nattsp: ptr cint): cint {.
    importc: "ncvarinq", dynlib: libnetcdf.}
proc ncvarput1*(ncid: cint; varid: cint; indexp: ptr clong; op: pointer): cint {.
    importc: "ncvarput1", dynlib: libnetcdf.}
proc ncvarget1*(ncid: cint; varid: cint; indexp: ptr clong; ip: pointer): cint {.
    importc: "ncvarget1", dynlib: libnetcdf.}
proc ncvarput*(ncid: cint; varid: cint; startp: ptr clong; countp: ptr clong; op: pointer): cint {.
    importc: "ncvarput", dynlib: libnetcdf.}
proc ncvarget*(ncid: cint; varid: cint; startp: ptr clong; countp: ptr clong; ip: pointer): cint {.
    importc: "ncvarget", dynlib: libnetcdf.}
proc ncvarputs*(ncid: cint; varid: cint; startp: ptr clong; countp: ptr clong;
               stridep: ptr clong; op: pointer): cint {.importc: "ncvarputs",
    dynlib: libnetcdf.}
proc ncvargets*(ncid: cint; varid: cint; startp: ptr clong; countp: ptr clong;
               stridep: ptr clong; ip: pointer): cint {.importc: "ncvargets",
    dynlib: libnetcdf.}
proc ncvarputg*(ncid: cint; varid: cint; startp: ptr clong; countp: ptr clong;
               stridep: ptr clong; imapp: ptr clong; op: pointer): cint {.
    importc: "ncvarputg", dynlib: libnetcdf.}
proc ncvargetg*(ncid: cint; varid: cint; startp: ptr clong; countp: ptr clong;
               stridep: ptr clong; imapp: ptr clong; ip: pointer): cint {.
    importc: "ncvargetg", dynlib: libnetcdf.}
proc ncvarrename*(ncid: cint; varid: cint; name: cstring): cint {.
    importc: "ncvarrename", dynlib: libnetcdf.}
proc ncrecinq*(ncid: cint; nrecvarsp: ptr cint; recvaridsp: ptr cint;
              recsizesp: ptr clong): cint {.importc: "ncrecinq", dynlib: libnetcdf.}
proc ncrecget*(ncid: cint; recnum: clong; datap: ptr pointer): cint {.
    importc: "ncrecget", dynlib: libnetcdf.}
proc ncrecput*(ncid: cint; recnum: clong; datap: ptr pointer): cint {.
    importc: "ncrecput", dynlib: libnetcdf.}
##  This function may be called to force the library to
##    initialize itself. It is not required, however.
##

proc initialize*(): cint {.importc: "nc_initialize", dynlib: libnetcdf.}
##  This function may be called to force the library to
##    cleanup global memory so that memory checkers will not
##    report errors. It is not required, however.
##

proc finalize*(): cint {.importc: "nc_finalize", dynlib: libnetcdf.}
##  Define two hard-coded functionality-related
##    (as requested by community developers) macros.
##    This is not going to be standard practice.
##    Don't remove without an in-place replacement of some sort,
##    the are now (for better or worse) used by downstream
##    software external to Unidata.

when not defined(NC_HAVE_RENAME_GRP):
  const
    NC_HAVE_RENAME_GRP* = true  ## !< rename_grp() support.
when not defined(NC_HAVE_INQ_FORMAT_EXTENDED):
  const
    NC_HAVE_INQ_FORMAT_EXTENDED* = true ## !< inq_format_extended() support.
