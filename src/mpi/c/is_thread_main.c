/*
 * $HEADER$
 */

#include "ompi_config.h"

#include "mpi.h"
#include "mpi/c/bindings.h"
#include "mpi/runtime/mpiruntime.h"
#include "communicator/communicator.h"
#include "errhandler/errhandler.h"
#include "threads/thread.h"

#if OMPI_HAVE_WEAK_SYMBOLS && OMPI_PROFILING_DEFINES
#pragma weak MPI_Is_thread_main = PMPI_Is_thread_main
#endif

#if OMPI_PROFILING_DEFINES
#include "mpi/c/profile/defines.h"
#endif

static const char FUNC_NAME[] = "MPI_Is_thread_main";


int MPI_Is_thread_main(int *flag) 
{
    if (MPI_PARAM_CHECK) {
        OMPI_ERR_INIT_FINALIZE(FUNC_NAME);
        if (NULL == flag) {
            return OMPI_ERRHANDLER_INVOKE(MPI_COMM_WORLD, MPI_ERR_COMM, FUNC_NAME);
        }
    }

    /* Compare this thread ID to the main thread ID */

#if OMPI_HAVE_THREADS
    *flag = (int) ompi_thread_self_compare(ompi_mpi_main_thread);
#else
    *flag = 1;
#endif

    return MPI_SUCCESS;
}
