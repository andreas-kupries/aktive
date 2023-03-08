/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Query processor count
 *
 * https://wiki.tcl-lang.org/page/critcl%3A%3Acproc+nproc+%3A+Number+of+processors
 */

#include <nproc.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_uint
aktive_processors (void)
{
#ifdef WIN32
    SYSTEM_INFO sysinfo;
    GetSystemInfo(&sysinfo);
    return sysinfo.dwNumberOfProcessors;
#elif __MACH__
    int     count ;
    size_t  size=sizeof(count) ;

    if (sysctlbyname("hw.ncpu",&count,&size,NULL,0)) return 1;

    return count;

#elif __linux
    return sysconf(_SC_NPROCESSORS_ONLN);
#else
    return 1;
#endif
}

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
