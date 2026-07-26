#pragma once
#include <fcntl.h>
static int set_cloexec(int fd) { return fcntl(fd, F_SETFD, FD_CLOEXEC); }
