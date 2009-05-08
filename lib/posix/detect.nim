# Posix detect program
# (c) 2009 Andreas Rumpf

# This program produces a C program that produces a Nimrod include file.
# The Nimrod include file lists the values of each POSIX constant.
# This is needed because POSIX is brain-dead: It only cares for C, any other
# language is ignored. It would have been easier had they specified the
# concrete values of the constants. Sigh.

import os, strutils

const
  cc = "gcc -o $1 $1.c"

  cfile = """
/* Generated by detect.nim */

#include <stdlib.h>
#include <stdio.h>
$1

int main() {
  FILE* f;
  f = fopen("$3_$4_consts.nim", "w+");
  fputs("# Generated by detect.nim\nconst\n", f);
  $2
  fclose(f);
}
"""

type
  TTypeKind = enum 
    cint, cshort, clong, cstring, pointer

var
  hd = ""
  tl = ""

proc myExec(cmd: string): bool = 
  return executeShellCommand(cmd) == 0

proc header(s: string): bool = 
  const testh = "testh"
  var f: TFile
  if openFile(f, appendFileExt(testh, "c"), fmWrite):
    f.write("#include $1\n" % s)
    f.write("int main() { return 0; }\n")
    closeFile(f)
    result = myExec(cc % testh)
    removeFile(appendFileExt(testh, "c"))
  if result:
    addf(hd, "#include $1\n", s)
    echo("Found: ", s)
  else:
    echo("Not found: ", s)

proc main = 
  const gen = "genconsts"
  var f: TFile
  if openFile(f, appendFileExt(gen, "c"), fmWrite): 
    f.write(cfile % [hd, tl, system.hostOS, system.hostCPU])
    closeFile(f)
  if not myExec(cc % gen): quit(1)
  if not myExec("./" & gen): quit(1)
  removeFile(appendFileExt(gen, "c"))
  echo("Success")

proc v(name: string, typ: TTypeKind=cint) = 
  var n = if name[0] == '_': copy(name, 1) else: name
  var t = $typ
  case typ
  of pointer: 
    addf(tl, 
      "#ifdef $3\n  fprintf(f, \"  $1* = cast[$2](%p)\\n\", $3);\n#endif\n", 
      n, t, name)
  
  of cstring:
    addf(tl, 
      "#ifdef $3\n  fprintf(f, \"  $1* = $2(\\\"%s\\\")\\n\", $3);\n#endif\n",
      n, t, name)
  of clong:
    addf(tl, 
      "#ifdef $3\n  fprintf(f, \"  $1* = $2(%ld)\\n\", $3);\n#endif\n", 
      n, t, name)  
  else:  
    addf(tl, 
      "#ifdef $3\n  fprintf(f, \"  $1* = $2(%d)\\n\", $3);\n#endif\n", 
      n, t, name)

if header("<aio.h>"):
  v("AIO_ALLDONE")
  v("AIO_CANCELED")
  v("AIO_NOTCANCELED")
  v("LIO_NOP")
  v("LIO_NOWAIT")
  v("LIO_READ")
  v("LIO_WAIT")
  v("LIO_WRITE")

if header("<dlfcn.h>"):
  v("RTLD_LAZY")
  v("RTLD_NOW")
  v("RTLD_GLOBAL")
  v("RTLD_LOCAL")

if header("<errno.h>"):
  v("E2BIG")
  v("EACCES")
  v("EADDRINUSE")
  v("EADDRNOTAVAIL")
  v("EAFNOSUPPORT")
  v("EAGAIN")
  v("EALREADY")
  v("EBADF")
  v("EBADMSG")
  v("EBUSY")
  v("ECANCELED")
  v("ECHILD")
  v("ECONNABORTED")
  v("ECONNREFUSED")
  v("ECONNRESET")
  v("EDEADLK")
  v("EDESTADDRREQ")
  v("EDOM")
  v("EDQUOT")
  v("EEXIST")
  v("EFAULT")
  v("EFBIG")
  v("EHOSTUNREACH")
  v("EIDRM")
  v("EILSEQ")
  v("EINPROGRESS")
  v("EINTR")
  v("EINVAL")
  v("EIO")
  v("EISCONN")
  v("EISDIR")
  v("ELOOP")
  v("EMFILE")
  v("EMLINK")
  v("EMSGSIZE")
  v("EMULTIHOP")
  v("ENAMETOOLONG")
  v("ENETDOWN")
  v("ENETRESET")
  v("ENETUNREACH")
  v("ENFILE")
  v("ENOBUFS")
  v("ENODATA")
  v("ENODEV")
  v("ENOENT")
  v("ENOEXEC")
  v("ENOLCK")
  v("ENOLINK")
  v("ENOMEM")
  v("ENOMSG")
  v("ENOPROTOOPT")
  v("ENOSPC")
  v("ENOSR")
  v("ENOSTR")
  v("ENOSYS")
  v("ENOTCONN")
  v("ENOTDIR")
  v("ENOTEMPTY")
  v("ENOTSOCK")
  v("ENOTSUP")
  v("ENOTTY")
  v("ENXIO")
  v("EOPNOTSUPP")
  v("EOVERFLOW")
  v("EPERM")
  v("EPIPE")
  v("EPROTO")
  v("EPROTONOSUPPORT")
  v("EPROTOTYPE")
  v("ERANGE")
  v("EROFS")
  v("ESPIPE")
  v("ESRCH")
  v("ESTALE")
  v("ETIME")
  v("ETIMEDOUT")
  v("ETXTBSY")
  v("EWOULDBLOCK")
  v("EXDEV")
  
if header("<fcntl.h>"):
  v("F_DUPFD")
  v("F_GETFD")
  v("F_SETFD")
  v("F_GETFL")
  v("F_SETFL")
  v("F_GETLK")
  v("F_SETLK")
  v("F_SETLKW")
  v("F_GETOWN")
  v("F_SETOWN")
  v("FD_CLOEXEC")
  v("F_RDLCK")
  v("F_UNLCK")
  v("F_WRLCK")
  v("O_CREAT")
  v("O_EXCL")
  v("O_NOCTTY")
  v("O_TRUNC")
  v("O_APPEND")
  v("O_DSYNC")
  v("O_NONBLOCK")
  v("O_RSYNC")
  v("O_SYNC")
  v("O_ACCMODE")
  v("O_RDONLY")
  v("O_RDWR")
  v("O_WRONLY")
  v("POSIX_FADV_NORMAL")
  v("POSIX_FADV_SEQUENTIAL")
  v("POSIX_FADV_RANDOM")
  v("POSIX_FADV_WILLNEED")
  v("POSIX_FADV_DONTNEED")
  v("POSIX_FADV_NOREUSE")

if header("<fenv.h>"):
  v("FE_DIVBYZERO")
  v("FE_INEXACT")
  v("FE_INVALID")
  v("FE_OVERFLOW")
  v("FE_UNDERFLOW")
  v("FE_ALL_EXCEPT")
  v("FE_DOWNWARD")
  v("FE_TONEAREST")
  v("FE_TOWARDZERO")
  v("FE_UPWARD")
  v("FE_DFL_ENV", pointer)

if header("<fmtmsg.h>"):
  v("MM_HARD")
  v("MM_SOFT")
  v("MM_FIRM")
  v("MM_APPL")
  v("MM_UTIL")
  v("MM_OPSYS")
  v("MM_RECOVER")
  v("MM_NRECOV")
  v("MM_HALT")
  v("MM_ERROR")
  v("MM_WARNING")
  v("MM_INFO")
  v("MM_NOSEV")
  v("MM_PRINT")
  v("MM_CONSOLE")
  v("MM_OK")
  v("MM_NOTOK")
  v("MM_NOMSG")
  v("MM_NOCON")

if header("<fnmatch.h>"):
  v("FNM_NOMATCH")
  v("FNM_PATHNAME")
  v("FNM_PERIOD")
  v("FNM_NOESCAPE")
  v("FNM_NOSYS")

if header("<ftw.h>"):
  v("FTW_F")
  v("FTW_D")
  v("FTW_DNR")
  v("FTW_DP")
  v("FTW_NS")
  v("FTW_SL")
  v("FTW_SLN")
  v("FTW_PHYS")
  v("FTW_MOUNT")
  v("FTW_DEPTH")
  v("FTW_CHDIR")

if header("<glob.h>"):
  v("GLOB_APPEND")
  v("GLOB_DOOFFS")
  v("GLOB_ERR")
  v("GLOB_MARK")
  v("GLOB_NOCHECK")
  v("GLOB_NOESCAPE")
  v("GLOB_NOSORT")
  v("GLOB_ABORTED")
  v("GLOB_NOMATCH")
  v("GLOB_NOSPACE")
  v("GLOB_NOSYS")

if header("<langinfo.h>"):
  v("CODESET")
  v("D_T_FMT")
  v("D_FMT")
  v("T_FMT")
  v("T_FMT_AMPM")
  v("AM_STR")
  v("PM_STR")
  v("DAY_1")
  v("DAY_2")
  v("DAY_3")
  v("DAY_4")
  v("DAY_5")
  v("DAY_6")
  v("DAY_7")
  v("ABDAY_1")
  v("ABDAY_2")
  v("ABDAY_3")
  v("ABDAY_4")
  v("ABDAY_5")
  v("ABDAY_6")
  v("ABDAY_7")
  v("MON_1")
  v("MON_2")
  v("MON_3")
  v("MON_4")
  v("MON_5")
  v("MON_6")
  v("MON_7")
  v("MON_8")
  v("MON_9")
  v("MON_10")
  v("MON_11")
  v("MON_12")
  v("ABMON_1")
  v("ABMON_2")
  v("ABMON_3")
  v("ABMON_4")
  v("ABMON_5")
  v("ABMON_6")
  v("ABMON_7")
  v("ABMON_8")
  v("ABMON_9")
  v("ABMON_10")
  v("ABMON_11")
  v("ABMON_12")
  v("ERA")
  v("ERA_D_FMT")
  v("ERA_D_T_FMT")
  v("ERA_T_FMT")
  v("ALT_DIGITS")
  v("RADIXCHAR")
  v("THOUSEP")
  v("YESEXPR")
  v("NOEXPR")
  v("CRNCYSTR")
    
if header("<locale.h>"):
  v("LC_ALL") #{.importc, header: .}: cint
  v("LC_COLLATE") #{.importc, header: "<locale.h>".}: cint
  v("LC_CTYPE") #{.importc, header: "<locale.h>".}: cint
  v("LC_MESSAGES") #{.importc, header: "<locale.h>".}: cint
  v("LC_MONETARY") #{.importc, header: "<locale.h>".}: cint
  v("LC_NUMERIC") #{.importc, header: "<locale.h>".}: cint
  v("LC_TIME") #{.importc, header: "<locale.h>".}: cint

if header("<pthread.h>"):
  v("PTHREAD_BARRIER_SERIAL_THREAD")
  v("PTHREAD_CANCEL_ASYNCHRONOUS") 
  v("PTHREAD_CANCEL_ENABLE") 
  v("PTHREAD_CANCEL_DEFERRED")
  v("PTHREAD_CANCEL_DISABLE") 
  #v("PTHREAD_CANCELED")
  #v("PTHREAD_COND_INITIALIZER") 
  v("PTHREAD_CREATE_DETACHED")
  v("PTHREAD_CREATE_JOINABLE")
  v("PTHREAD_EXPLICIT_SCHED")
  v("PTHREAD_INHERIT_SCHED") 
  v("PTHREAD_MUTEX_DEFAULT") 
  v("PTHREAD_MUTEX_ERRORCHECK")
  #v("PTHREAD_MUTEX_INITIALIZER") 
  v("PTHREAD_MUTEX_NORMAL") 
  v("PTHREAD_MUTEX_RECURSIVE") #{.importc, header: "<pthread.h>".}: cint
  v("PTHREAD_ONCE_INIT") #{.importc, header: "<pthread.h>".}: cint
  v("PTHREAD_PRIO_INHERIT") #{.importc, header: "<pthread.h>".}: cint
  v("PTHREAD_PRIO_NONE") #{.importc, header: "<pthread.h>".}: cint
  v("PTHREAD_PRIO_PROTECT") #{.importc, header: "<pthread.h>".}: cint
  v("PTHREAD_PROCESS_SHARED") #{.importc, header: "<pthread.h>".}: cint
  v("PTHREAD_PROCESS_PRIVATE") #{.importc, header: "<pthread.h>".}: cint
  v("PTHREAD_SCOPE_PROCESS") #{.importc, header: "<pthread.h>".}: cint
  v("PTHREAD_SCOPE_SYSTEM") #{.importc, header: "<pthread.h>".}: cint

if header("<unistd.h>"):
  v("_POSIX_ASYNC_IO")
  v("_POSIX_PRIO_IO")
  v("_POSIX_SYNC_IO")
  v("F_OK")
  v("R_OK")
  v("W_OK")
  v("X_OK")

  v("_CS_PATH")
  v("_CS_POSIX_V6_ILP32_OFF32_CFLAGS") 
  v("_CS_POSIX_V6_ILP32_OFF32_LDFLAGS") 
  v("_CS_POSIX_V6_ILP32_OFF32_LIBS") 
  v("_CS_POSIX_V6_ILP32_OFFBIG_CFLAGS") 
  v("_CS_POSIX_V6_ILP32_OFFBIG_LDFLAGS") 
  v("_CS_POSIX_V6_ILP32_OFFBIG_LIBS") 
  v("_CS_POSIX_V6_LP64_OFF64_CFLAGS") 
  v("_CS_POSIX_V6_LP64_OFF64_LDFLAGS")
  v("_CS_POSIX_V6_LP64_OFF64_LIBS") 
  v("_CS_POSIX_V6_LPBIG_OFFBIG_CFLAGS") 
  v("_CS_POSIX_V6_LPBIG_OFFBIG_LDFLAGS") 
  v("_CS_POSIX_V6_LPBIG_OFFBIG_LIBS") 
  v("_CS_POSIX_V6_WIDTH_RESTRICTED_ENVS")

  v("F_LOCK") 
  v("F_TEST") #{.importc: "F_TEST", header: "<unistd.h>".}: cint
  v("F_TLOCK") #{.importc: "F_TLOCK", header: "<unistd.h>".}: cint
  v("F_ULOCK") #{.importc: "F_ULOCK", header: "<unistd.h>".}: cint
  v("_PC_2_SYMLINKS") #{.importc: "_PC_2_SYMLINKS", header: "<unistd.h>".}: cint
  v("_PC_ALLOC_SIZE_MIN") 
  v("_PC_ASYNC_IO") #{.importc: "_PC_ASYNC_IO", header: "<unistd.h>".}: cint
  v("_PC_CHOWN_RESTRICTED") 
  v("_PC_FILESIZEBITS") #{.importc: "_PC_FILESIZEBITS", header: "<unistd.h>".}: cint
  v("_PC_LINK_MAX") #{.importc: "_PC_LINK_MAX", header: "<unistd.h>".}: cint
  v("_PC_MAX_CANON") #{.importc: "_PC_MAX_CANON", header: "<unistd.h>".}: cint
  v("_PC_MAX_INPUT") #{.importc: "_PC_MAX_INPUT", header: "<unistd.h>".}: cint
  v("_PC_NAME_MAX") #{.importc: "_PC_NAME_MAX", header: "<unistd.h>".}: cint
  v("_PC_NO_TRUNC") #{.importc: "_PC_NO_TRUNC", header: "<unistd.h>".}: cint
  v("_PC_PATH_MAX") #{.importc: "_PC_PATH_MAX", header: "<unistd.h>".}: cint
  v("_PC_PIPE_BUF") #{.importc: "_PC_PIPE_BUF", header: "<unistd.h>".}: cint
  v("_PC_PRIO_IO") #{.importc: "_PC_PRIO_IO", header: "<unistd.h>".}: cint
  v("_PC_REC_INCR_XFER_SIZE") 
  v("_PC_REC_MIN_XFER_SIZE") 
  v("_PC_REC_XFER_ALIGN") 
  v("_PC_SYMLINK_MAX") #{.importc: "_PC_SYMLINK_MAX", header: "<unistd.h>".}: cint
  v("_PC_SYNC_IO") #{.importc: "_PC_SYNC_IO", header: "<unistd.h>".}: cint
  v("_PC_VDISABLE") #{.importc: "_PC_VDISABLE", header: "<unistd.h>".}: cint
  v("_SC_2_C_BIND") #{.importc: "_SC_2_C_BIND", header: "<unistd.h>".}: cint
  v("_SC_2_C_DEV") #{.importc: "_SC_2_C_DEV", header: "<unistd.h>".}: cint
  v("_SC_2_CHAR_TERM") #{.importc: "_SC_2_CHAR_TERM", header: "<unistd.h>".}: cint
  v("_SC_2_FORT_DEV") #{.importc: "_SC_2_FORT_DEV", header: "<unistd.h>".}: cint
  v("_SC_2_FORT_RUN") #{.importc: "_SC_2_FORT_RUN", header: "<unistd.h>".}: cint
  v("_SC_2_LOCALEDEF") #{.importc: "_SC_2_LOCALEDEF", header: "<unistd.h>".}: cint
  v("_SC_2_PBS") #{.importc: "_SC_2_PBS", header: "<unistd.h>".}: cint
  v("_SC_2_PBS_ACCOUNTING") 
  v("_SC_2_PBS_CHECKPOINT") 
  v("_SC_2_PBS_LOCATE") #{.importc: "_SC_2_PBS_LOCATE", header: "<unistd.h>".}: cint
  v("_SC_2_PBS_MESSAGE") #{.importc: "_SC_2_PBS_MESSAGE", header: "<unistd.h>".}: cint
  v("_SC_2_PBS_TRACK") #{.importc: "_SC_2_PBS_TRACK", header: "<unistd.h>".}: cint
  v("_SC_2_SW_DEV") #{.importc: "_SC_2_SW_DEV", header: "<unistd.h>".}: cint
  v("_SC_2_UPE") #{.importc: "_SC_2_UPE", header: "<unistd.h>".}: cint
  v("_SC_2_VERSION") #{.importc: "_SC_2_VERSION", header: "<unistd.h>".}: cint
  v("_SC_ADVISORY_INFO") #{.importc: "_SC_ADVISORY_INFO", header: "<unistd.h>".}: cint
  v("_SC_AIO_LISTIO_MAX") 
  v("_SC_AIO_MAX") #{.importc: "_SC_AIO_MAX", header: "<unistd.h>".}: cint
  v("_SC_AIO_PRIO_DELTA_MAX") 
  v("_SC_ARG_MAX") #{.importc: "_SC_ARG_MAX", header: "<unistd.h>".}: cint
  v("_SC_ASYNCHRONOUS_IO") 
  v("_SC_ATEXIT_MAX") #{.importc: "_SC_ATEXIT_MAX", header: "<unistd.h>".}: cint
  v("_SC_BARRIERS") #{.importc: "_SC_BARRIERS", header: "<unistd.h>".}: cint
  v("_SC_BC_BASE_MAX") #{.importc: "_SC_BC_BASE_MAX", header: "<unistd.h>".}: cint
  v("_SC_BC_DIM_MAX") #{.importc: "_SC_BC_DIM_MAX", header: "<unistd.h>".}: cint
  v("_SC_BC_SCALE_MAX") #{.importc: "_SC_BC_SCALE_MAX", header: "<unistd.h>".}: cint
  v("_SC_BC_STRING_MAX") #{.importc: "_SC_BC_STRING_MAX", header: "<unistd.h>".}: cint
  v("_SC_CHILD_MAX") #{.importc: "_SC_CHILD_MAX", header: "<unistd.h>".}: cint
  v("_SC_CLK_TCK") #{.importc: "_SC_CLK_TCK", header: "<unistd.h>".}: cint
  v("_SC_CLOCK_SELECTION") 
  v("_SC_COLL_WEIGHTS_MAX")
  v("_SC_CPUTIME") #{.importc: "_SC_CPUTIME", header: "<unistd.h>".}: cint
  v("_SC_DELAYTIMER_MAX") 
  v("_SC_EXPR_NEST_MAX") #{.importc: "_SC_EXPR_NEST_MAX", header: "<unistd.h>".}: cint
  v("_SC_FSYNC") #{.importc: "_SC_FSYNC", header: "<unistd.h>".}: cint
  v("_SC_GETGR_R_SIZE_MAX")
  v("_SC_GETPW_R_SIZE_MAX")
  v("_SC_HOST_NAME_MAX") #{.importc: "_SC_HOST_NAME_MAX", header: "<unistd.h>".}: cint
  v("_SC_IOV_MAX") #{.importc: "_SC_IOV_MAX", header: "<unistd.h>".}: cint
  v("_SC_IPV6") #{.importc: "_SC_IPV6", header: "<unistd.h>".}: cint
  v("_SC_JOB_CONTROL") #{.importc: "_SC_JOB_CONTROL", header: "<unistd.h>".}: cint
  v("_SC_LINE_MAX") #{.importc: "_SC_LINE_MAX", header: "<unistd.h>".}: cint
  v("_SC_LOGIN_NAME_MAX") 
  v("_SC_MAPPED_FILES") #{.importc: "_SC_MAPPED_FILES", header: "<unistd.h>".}: cint
  v("_SC_MEMLOCK") #{.importc: "_SC_MEMLOCK", header: "<unistd.h>".}: cint
  v("_SC_MEMLOCK_RANGE") #{.importc: "_SC_MEMLOCK_RANGE", header: "<unistd.h>".}: cint
  v("_SC_MEMORY_PROTECTION")
  v("_SC_MESSAGE_PASSING") 
  v("_SC_MONOTONIC_CLOCK") 
  v("_SC_MQ_OPEN_MAX") #{.importc: "_SC_MQ_OPEN_MAX", header: "<unistd.h>".}: cint
  v("_SC_MQ_PRIO_MAX") #{.importc: "_SC_MQ_PRIO_MAX", header: "<unistd.h>".}: cint
  v("_SC_NGROUPS_MAX") #{.importc: "_SC_NGROUPS_MAX", header: "<unistd.h>".}: cint
  v("_SC_OPEN_MAX") #{.importc: "_SC_OPEN_MAX", header: "<unistd.h>".}: cint
  v("_SC_PAGE_SIZE") #{.importc: "_SC_PAGE_SIZE", header: "<unistd.h>".}: cint
  v("_SC_PRIORITIZED_IO") 
  v("_SC_PRIORITY_SCHEDULING") 
  v("_SC_RAW_SOCKETS") #{.importc: "_SC_RAW_SOCKETS", header: "<unistd.h>".}: cint
  v("_SC_RE_DUP_MAX") #{.importc: "_SC_RE_DUP_MAX", header: "<unistd.h>".}: cint
  v("_SC_READER_WRITER_LOCKS") 
  v("_SC_REALTIME_SIGNALS") 
  v("_SC_REGEXP") #{.importc: "_SC_REGEXP", header: "<unistd.h>".}: cint
  v("_SC_RTSIG_MAX") #{.importc: "_SC_RTSIG_MAX", header: "<unistd.h>".}: cint
  v("_SC_SAVED_IDS") #{.importc: "_SC_SAVED_IDS", header: "<unistd.h>".}: cint
  v("_SC_SEM_NSEMS_MAX") #{.importc: "_SC_SEM_NSEMS_MAX", header: "<unistd.h>".}: cint
  v("_SC_SEM_VALUE_MAX") #{.importc: "_SC_SEM_VALUE_MAX", header: "<unistd.h>".}: cint
  v("_SC_SEMAPHORES") #{.importc: "_SC_SEMAPHORES", header: "<unistd.h>".}: cint
  v("_SC_SHARED_MEMORY_OBJECTS") 
  v("_SC_SHELL") #{.importc: "_SC_SHELL", header: "<unistd.h>".}: cint
  v("_SC_SIGQUEUE_MAX") #{.importc: "_SC_SIGQUEUE_MAX", header: "<unistd.h>".}: cint
  v("_SC_SPAWN") #{.importc: "_SC_SPAWN", header: "<unistd.h>".}: cint
  v("_SC_SPIN_LOCKS") #{.importc: "_SC_SPIN_LOCKS", header: "<unistd.h>".}: cint
  v("_SC_SPORADIC_SERVER") 
  v("_SC_SS_REPL_MAX") #{.importc: "_SC_SS_REPL_MAX", header: "<unistd.h>".}: cint
  v("_SC_STREAM_MAX") #{.importc: "_SC_STREAM_MAX", header: "<unistd.h>".}: cint
  v("_SC_SYMLOOP_MAX") #{.importc: "_SC_SYMLOOP_MAX", header: "<unistd.h>".}: cint
  v("_SC_SYNCHRONIZED_IO") 
  v("_SC_THREAD_ATTR_STACKADDR") 
  v("_SC_THREAD_ATTR_STACKSIZE") 
  v("_SC_THREAD_CPUTIME") 
  v("_SC_THREAD_DESTRUCTOR_ITERATIONS") 
  v("_SC_THREAD_KEYS_MAX") 
  v("_SC_THREAD_PRIO_INHERIT") 
  v("_SC_THREAD_PRIO_PROTECT") 
  v("_SC_THREAD_PRIORITY_SCHEDULING") 
  v("_SC_THREAD_PROCESS_SHARED") 
  v("_SC_THREAD_SAFE_FUNCTIONS") 
  v("_SC_THREAD_SPORADIC_SERVER")
  v("_SC_THREAD_STACK_MIN") 
  v("_SC_THREAD_THREADS_MAX") 
  v("_SC_THREADS") #{.importc: "_SC_THREADS", header: "<unistd.h>".}: cint
  v("_SC_TIMEOUTS") #{.importc: "_SC_TIMEOUTS", header: "<unistd.h>".}: cint
  v("_SC_TIMER_MAX") #{.importc: "_SC_TIMER_MAX", header: "<unistd.h>".}: cint
  v("_SC_TIMERS") #{.importc: "_SC_TIMERS", header: "<unistd.h>".}: cint
  v("_SC_TRACE") #{.importc: "_SC_TRACE", header: "<unistd.h>".}: cint
  v("_SC_TRACE_EVENT_FILTER") 
  v("_SC_TRACE_EVENT_NAME_MAX")
  v("_SC_TRACE_INHERIT") #{.importc: "_SC_TRACE_INHERIT", header: "<unistd.h>".}: cint
  v("_SC_TRACE_LOG") #{.importc: "_SC_TRACE_LOG", header: "<unistd.h>".}: cint
  v("_SC_TRACE_NAME_MAX") 
  v("_SC_TRACE_SYS_MAX") #{.importc: "_SC_TRACE_SYS_MAX", header: "<unistd.h>".}: cint
  v("_SC_TRACE_USER_EVENT_MAX") 
  v("_SC_TTY_NAME_MAX") #{.importc: "_SC_TTY_NAME_MAX", header: "<unistd.h>".}: cint
  v("_SC_TYPED_MEMORY_OBJECTS") 
  v("_SC_TZNAME_MAX") #{.importc: "_SC_TZNAME_MAX", header: "<unistd.h>".}: cint
  v("_SC_V6_ILP32_OFF32") 
  v("_SC_V6_ILP32_OFFBIG") 
  v("_SC_V6_LP64_OFF64") #{.importc: "_SC_V6_LP64_OFF64", header: "<unistd.h>".}: cint
  v("_SC_V6_LPBIG_OFFBIG") 
  v("_SC_VERSION") #{.importc: "_SC_VERSION", header: "<unistd.h>".}: cint
  v("_SC_XBS5_ILP32_OFF32") 
  v("_SC_XBS5_ILP32_OFFBIG") 
  v("_SC_XBS5_LP64_OFF64") 
  v("_SC_XBS5_LPBIG_OFFBIG") 
  v("_SC_XOPEN_CRYPT") #{.importc: "_SC_XOPEN_CRYPT", header: "<unistd.h>".}: cint
  v("_SC_XOPEN_ENH_I18N") 
  v("_SC_XOPEN_LEGACY") #{.importc: "_SC_XOPEN_LEGACY", header: "<unistd.h>".}: cint
  v("_SC_XOPEN_REALTIME") 
  v("_SC_XOPEN_REALTIME_THREADS") 
  v("_SC_XOPEN_SHM") #{.importc: "_SC_XOPEN_SHM", header: "<unistd.h>".}: cint
  v("_SC_XOPEN_STREAMS") #{.importc: "_SC_XOPEN_STREAMS", header: "<unistd.h>".}: cint
  v("_SC_XOPEN_UNIX") #{.importc: "_SC_XOPEN_UNIX", header: "<unistd.h>".}: cint
  v("_SC_XOPEN_VERSION") #{.importc: "_SC_XOPEN_VERSION", header: "<unistd.h>".}: cint

  v("SEEK_SET") #{.importc, header: "<unistd.h>".}: cint
  v("SEEK_CUR") #{.importc, header: "<unistd.h>".}: cint
  v("SEEK_END") #{.importc, header: "<unistd.h>".}: cint


if header("<semaphore.h>"):
  v("SEM_FAILED", pointer)

if header("<sys/ipc.h>"):
  v("IPC_CREAT") #{.importc, header: .}: cint
  v("IPC_EXCL") #{.importc, header: "<sys/ipc.h>".}: cint
  v("IPC_NOWAIT") #{.importc, header: "<sys/ipc.h>".}: cint
  v("IPC_PRIVATE") #{.importc, header: "<sys/ipc.h>".}: cint
  v("IPC_RMID") #{.importc, header: "<sys/ipc.h>".}: cint
  v("IPC_SET") #{.importc, header: "<sys/ipc.h>".}: cint
  v("IPC_STAT") #{.importc, header: "<sys/ipc.h>".}: cint

if header("<sys/stat.h>"):
  v("S_IFMT") #{.importc, header: .}: cint
  v("S_IFBLK") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IFCHR") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IFIFO") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IFREG") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IFDIR") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IFLNK") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IFSOCK") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IRWXU") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IRUSR") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IWUSR") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IXUSR") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IRWXG") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IRGRP") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IWGRP") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IXGRP") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IRWXO") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IROTH") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IWOTH") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_IXOTH") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_ISUID") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_ISGID") #{.importc, header: "<sys/stat.h>".}: cint
  v("S_ISVTX") #{.importc, header: "<sys/stat.h>".}: cint

if header("<sys/statvfs.h>"):
  v("ST_RDONLY") #{.importc, header: .}: cint
  v("ST_NOSUID") #{.importc, header: "<sys/statvfs.h>".}: cint
       
if header("<sys/mman.h>"):
  v("PROT_READ") #{.importc, header: .}: cint
  v("PROT_WRITE") #{.importc, header: "<sys/mman.h>".}: cint
  v("PROT_EXEC") #{.importc, header: "<sys/mman.h>".}: cint
  v("PROT_NONE") #{.importc, header: "<sys/mman.h>".}: cint
  v("MAP_SHARED") #{.importc, header: "<sys/mman.h>".}: cint
  v("MAP_PRIVATE") #{.importc, header: "<sys/mman.h>".}: cint
  v("MAP_FIXED") #{.importc, header: "<sys/mman.h>".}: cint
  v("MS_ASYNC") #{.importc, header: "<sys/mman.h>".}: cint
  v("MS_SYNC") #{.importc, header: "<sys/mman.h>".}: cint
  v("MS_INVALIDATE") #{.importc, header: "<sys/mman.h>".}: cint
  v("MCL_CURRENT") #{.importc, header: "<sys/mman.h>".}: cint
  v("MCL_FUTURE") #{.importc, header: "<sys/mman.h>".}: cint

  v("MAP_FAILED", pointer)
  v("POSIX_MADV_NORMAL") #{.importc, header: "<sys/mman.h>".}: cint
  v("POSIX_MADV_SEQUENTIAL") #{.importc, header: "<sys/mman.h>".}: cint
  v("POSIX_MADV_RANDOM") #{.importc, header: "<sys/mman.h>".}: cint
  v("POSIX_MADV_WILLNEED") #{.importc, header: "<sys/mman.h>".}: cint
  v("POSIX_MADV_DONTNEED") #{.importc, header: "<sys/mman.h>".}: cint
  v("POSIX_TYPED_MEM_ALLOCATE") #{.importc, header: "<sys/mman.h>".}: cint
  v("POSIX_TYPED_MEM_ALLOCATE_CONTIG") #{.importc, header: "<sys/mman.h>".}: cint
  v("POSIX_TYPED_MEM_MAP_ALLOCATABLE") #{.importc, header: "<sys/mman.h>".}: cint

if header("<time.h>"):
  v("CLOCKS_PER_SEC", clong) 
  v("CLOCK_PROCESS_CPUTIME_ID")
  v("CLOCK_THREAD_CPUTIME_ID")
  v("CLOCK_REALTIME")
  v("TIMER_ABSTIME") 
  v("CLOCK_MONOTONIC") 

if header("<sys/wait.h>"):
  v("WNOHANG") #{.importc, header: .}: cint
  v("WUNTRACED") #{.importc, header: "<sys/wait.h>".}: cint
  #v("WEXITSTATUS") 
  #v("WIFCONTINUED") 
  #v("WIFEXITED") 
  #v("WIFSIGNALED")
  #v("WIFSTOPPED") 
  #v("WSTOPSIG") 
  #v("WTERMSIG") 
  v("WEXITED") #{.importc, header: "<sys/wait.h>".}: cint
  v("WSTOPPED") #{.importc, header: "<sys/wait.h>".}: cint
  v("WCONTINUED") #{.importc, header: "<sys/wait.h>".}: cint
  v("WNOWAIT") #{.importc, header: "<sys/wait.h>".}: cint
  v("P_ALL") #{.importc, header: "<sys/wait.h>".}: cint 
  v("P_PID") #{.importc, header: "<sys/wait.h>".}: cint 
  v("P_PGID") #{.importc, header: "<sys/wait.h>".}: cint
         
if header("<signal.h>"):
  v("SIGEV_NONE") #{.importc, header: "<signal.h>".}: cint
  v("SIGEV_SIGNAL") #{.importc, header: "<signal.h>".}: cint
  v("SIGEV_THREAD") #{.importc, header: "<signal.h>".}: cint
  v("SIGABRT") #{.importc, header: "<signal.h>".}: cint
  v("SIGALRM") #{.importc, header: "<signal.h>".}: cint
  v("SIGBUS") #{.importc, header: "<signal.h>".}: cint
  v("SIGCHLD") #{.importc, header: "<signal.h>".}: cint
  v("SIGCONT") #{.importc, header: "<signal.h>".}: cint
  v("SIGFPE") #{.importc, header: "<signal.h>".}: cint
  v("SIGHUP") #{.importc, header: "<signal.h>".}: cint
  v("SIGILL") #{.importc, header: "<signal.h>".}: cint
  v("SIGINT") #{.importc, header: "<signal.h>".}: cint
  v("SIGKILL") #{.importc, header: "<signal.h>".}: cint
  v("SIGPIPE") #{.importc, header: "<signal.h>".}: cint
  v("SIGQUIT") #{.importc, header: "<signal.h>".}: cint
  v("SIGSEGV") #{.importc, header: "<signal.h>".}: cint
  v("SIGSTOP") #{.importc, header: "<signal.h>".}: cint
  v("SIGTERM") #{.importc, header: "<signal.h>".}: cint
  v("SIGTSTP") #{.importc, header: "<signal.h>".}: cint
  v("SIGTTIN") #{.importc, header: "<signal.h>".}: cint
  v("SIGTTOU") #{.importc, header: "<signal.h>".}: cint
  v("SIGUSR1") #{.importc, header: "<signal.h>".}: cint
  v("SIGUSR2") #{.importc, header: "<signal.h>".}: cint
  v("SIGPOLL") #{.importc, header: "<signal.h>".}: cint
  v("SIGPROF") #{.importc, header: "<signal.h>".}: cint
  v("SIGSYS") #{.importc, header: "<signal.h>".}: cint
  v("SIGTRAP") #{.importc, header: "<signal.h>".}: cint
  v("SIGURG") #{.importc, header: "<signal.h>".}: cint
  v("SIGVTALRM") #{.importc, header: "<signal.h>".}: cint
  v("SIGXCPU") #{.importc, header: "<signal.h>".}: cint
  v("SIGXFSZ") #{.importc, header: "<signal.h>".}: cint
  v("SA_NOCLDSTOP") #{.importc, header: "<signal.h>".}: cint
  v("SIG_BLOCK") #{.importc, header: "<signal.h>".}: cint
  v("SIG_UNBLOCK") #{.importc, header: "<signal.h>".}: cint
  v("SIG_SETMASK") #{.importc, header: "<signal.h>".}: cint
  v("SA_ONSTACK") #{.importc, header: "<signal.h>".}: cint
  v("SA_RESETHAND") #{.importc, header: "<signal.h>".}: cint
  v("SA_RESTART") #{.importc, header: "<signal.h>".}: cint
  v("SA_SIGINFO") #{.importc, header: "<signal.h>".}: cint
  v("SA_NOCLDWAIT") #{.importc, header: "<signal.h>".}: cint
  v("SA_NODEFER") #{.importc, header: "<signal.h>".}: cint
  v("SS_ONSTACK") #{.importc, header: "<signal.h>".}: cint
  v("SS_DISABLE") #{.importc, header: "<signal.h>".}: cint
  v("MINSIGSTKSZ") #{.importc, header: "<signal.h>".}: cint
  v("SIGSTKSZ") #{.importc, header: "<signal.h>".}: cint

if header("<nl_types.h>"):
  v("NL_SETD") #{.importc, header: .}: cint
  v("NL_CAT_LOCALE") #{.importc, header: "<nl_types.h>".}: cint

if header("<sched.h>"):
  v("SCHED_FIFO")
  v("SCHED_RR")
  v("SCHED_SPORADIC")
  v("SCHED_OTHER")

if header("<sys/select.h>"):
  v("FD_SETSIZE")

if header("<net/if.h>"):
  v("IF_NAMESIZE")

if header("<sys/socket.h>"):
  v("SCM_RIGHTS") #{.importc, header: .}: cint
  v("SOCK_DGRAM") #{.importc, header: "<sys/socket.h>".}: cint
  v("SOCK_RAW") #{.importc, header: "<sys/socket.h>".}: cint
  v("SOCK_SEQPACKET") #{.importc, header: "<sys/socket.h>".}: cint
  v("SOCK_STREAM") #{.importc, header: "<sys/socket.h>".}: cint
  v("SOL_SOCKET") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_ACCEPTCONN") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_BROADCAST") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_DEBUG") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_DONTROUTE") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_ERROR") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_KEEPALIVE") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_LINGER") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_OOBINLINE") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_RCVBUF") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_RCVLOWAT") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_RCVTIMEO") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_REUSEADDR") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_SNDBUF") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_SNDLOWAT") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_SNDTIMEO") #{.importc, header: "<sys/socket.h>".}: cint
  v("SO_TYPE") #{.importc, header: "<sys/socket.h>".}: cint
  v("SOMAXCONN") #{.importc, header: "<sys/socket.h>".}: cint
  v("MSG_CTRUNC") #{.importc, header: "<sys/socket.h>".}: cint
  v("MSG_DONTROUTE") #{.importc, header: "<sys/socket.h>".}: cint
  v("MSG_EOR") #{.importc, header: "<sys/socket.h>".}: cint
  v("MSG_OOB") #{.importc, header: "<sys/socket.h>".}: cint
  v("MSG_PEEK") #{.importc, header: "<sys/socket.h>".}: cint
  v("MSG_TRUNC") #{.importc, header: "<sys/socket.h>".}: cint
  v("MSG_WAITALL") #{.importc, header: "<sys/socket.h>".}: cint
  v("AF_INET") #{.importc, header: "<sys/socket.h>".}: cint
  v("AF_INET6") #{.importc, header: "<sys/socket.h>".}: cint
  v("AF_UNIX") #{.importc, header: "<sys/socket.h>".}: cint
  v("AF_UNSPEC") #{.importc, header: "<sys/socket.h>".}: cint
  v("SHUT_RD") #{.importc, header: "<sys/socket.h>".}: cint
  v("SHUT_RDWR") #{.importc, header: "<sys/socket.h>".}: cint
  v("SHUT_WR") #{.importc, header: "<sys/socket.h>".}: cint

if header("<netinet/in.h>"):
  v("IPPROTO_IP") #{.importc, header: .}: cint
  v("IPPROTO_IPV6") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPPROTO_ICMP") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPPROTO_RAW") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPPROTO_TCP") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPPROTO_UDP") #{.importc, header: "<netinet/in.h>".}: cint
  v("INADDR_ANY") #{.importc, header: "<netinet/in.h>".}: TinAddrScalar
  v("INADDR_BROADCAST") #{.importc, header: "<netinet/in.h>".}: TinAddrScalar
  v("INET_ADDRSTRLEN") #{.importc, header: "<netinet/in.h>".}: cint

  v("IPV6_JOIN_GROUP") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPV6_LEAVE_GROUP") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPV6_MULTICAST_HOPS") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPV6_MULTICAST_IF") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPV6_MULTICAST_LOOP") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPV6_UNICAST_HOPS") #{.importc, header: "<netinet/in.h>".}: cint
  v("IPV6_V6ONLY") #{.importc, header: "<netinet/in.h>".}: cint

  v("TCP_NODELAY") #{.importc, header: "<netinet/tcp.h>".}: cint

if header("<netdb.h>"):
  v("IPPORT_RESERVED")

  v("HOST_NOT_FOUND")
  v("NO_DATA")
  v("NO_RECOVERY") 
  v("TRY_AGAIN") 

  v("AI_PASSIVE") 
  v("AI_CANONNAME") 
  v("AI_NUMERICHOST") 
  v("AI_NUMERICSERV") 
  v("AI_V4MAPPED") 
  v("AI_ALL") 
  v("AI_ADDRCONFIG") 

  v("NI_NOFQDN") 
  v("NI_NUMERICHOST") 
  v("NI_NAMEREQD") 
  v("NI_NUMERICSERV") 
  v("NI_NUMERICSCOPE") 
  v("NI_DGRAM") 
  v("EAI_AGAIN")
  v("EAI_BADFLAGS")
  v("EAI_FAIL")
  v("EAI_FAMILY")
  v("EAI_MEMORY")
  v("EAI_NONAME")
  v("EAI_SERVICE")
  v("EAI_SOCKTYPE")
  v("EAI_SYSTEM")
  v("EAI_OVERFLOW")

if header("<poll.h>"):
  v("POLLIN", cshort)
  v("POLLRDNORM", cshort)
  v("POLLRDBAND", cshort)
  v("POLLPRI", cshort)
  v("POLLOUT", cshort)
  v("POLLWRNORM", cshort)
  v("POLLWRBAND", cshort)
  v("POLLERR", cshort)
  v("POLLHUP", cshort)
  v("POLLNVAL", cshort)

if header("<spawn.h>"):
  v("POSIX_SPAWN_RESETIDS")
  v("POSIX_SPAWN_SETPGROUP")
  v("POSIX_SPAWN_SETSCHEDPARAM")
  v("POSIX_SPAWN_SETSCHEDULER")
  v("POSIX_SPAWN_SETSIGDEF")
  v("POSIX_SPAWN_SETSIGMASK")

main()
