#include "postgres.h"
#include <string.h>
#include "fmgr.h"
#include "utils/geo_decls.h"
#include <utils/array.h> /* for ArrayType */

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

/* by value */

PG_FUNCTION_INFO_V1(add_one);

Datum
add_one(PG_FUNCTION_ARGS)
{
    float8 *myvalue = PG_GETARG_POINTER(0);

    PG_RETURN_FLOAT8(myvalue[0][0][0] + 1);
}
