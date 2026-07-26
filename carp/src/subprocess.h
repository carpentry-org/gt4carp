#ifndef CARP_SUBPROCESS_H
#define CARP_SUBPROCESS_H

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

typedef struct {
  int pid;
  int stdin_MINUS_fd;
  int stdout_MINUS_fd;
} Subprocess;

__attribute__((unused))
static String Subprocess_err_string_(void) {
  const char *msg = strerror(errno);
  size_t len = strlen(msg);
  String s = CARP_MALLOC(len + 1);
  memcpy(s, msg, len + 1);
  return s;
}

__attribute__((unused))
static Subprocess Subprocess_spawn_(String *cmd, Array *args) {
  Subprocess sub;
  sub.pid = -1;
  sub.stdin_MINUS_fd = -1;
  sub.stdout_MINUS_fd = -1;

  int in_pipe[2];
  int out_pipe[2];
  if (pipe(in_pipe) < 0) return sub;
  if (pipe(out_pipe) < 0) {
    close(in_pipe[0]);
    close(in_pipe[1]);
    return sub;
  }

  int n = args->len;
  char **av = (char **)calloc((size_t)(n + 2), sizeof(char *));
  av[0] = *cmd;
  String *src = (String *)args->data;
  for (int i = 0; i < n; i++) av[i + 1] = src[i];
  av[n + 1] = NULL;

  pid_t pid = fork();
  if (pid < 0) {
    close(in_pipe[0]); close(in_pipe[1]);
    close(out_pipe[0]); close(out_pipe[1]);
    free(av);
    return sub;
  }

  if (pid == 0) {
    dup2(in_pipe[0], STDIN_FILENO);
    dup2(out_pipe[1], STDOUT_FILENO);
    dup2(out_pipe[1], STDERR_FILENO);
    close(in_pipe[0]); close(in_pipe[1]);
    close(out_pipe[0]); close(out_pipe[1]);
    execvp(*cmd, av);
    _exit(127);
  }

  close(in_pipe[0]);
  close(out_pipe[1]);
  free(av);

  sub.pid = pid;
  sub.stdin_MINUS_fd = in_pipe[1];
  sub.stdout_MINUS_fd = out_pipe[0];
  return sub;
}

__attribute__((unused))
static int Subprocess_pid_(Subprocess *s) { return s->pid; }
__attribute__((unused))
static int Subprocess_stdin_MINUS_fd_(Subprocess *s) { return s->stdin_MINUS_fd; }
__attribute__((unused))
static int Subprocess_stdout_MINUS_fd_(Subprocess *s) { return s->stdout_MINUS_fd; }

__attribute__((unused))
static int Subprocess_write_MINUS_string_(Subprocess *s, String *msg) {
  if (s->stdin_MINUS_fd < 0) return -1;
  size_t len = strlen(*msg);
  size_t off = 0;
  while (off < len) {
    ssize_t w = write(s->stdin_MINUS_fd, *msg + off, len - off);
    if (w < 0) {
      if (errno == EINTR) continue;
      return -1;
    }
    off += (size_t)w;
  }
  return (int)len;
}

__attribute__((unused))
static int Subprocess_write_MINUS_bytes_(Subprocess *s, Array *data) {
  if (s->stdin_MINUS_fd < 0) return -1;
  size_t len = (size_t)data->len;
  size_t off = 0;
  const char *buf = (const char *)data->data;
  while (off < len) {
    ssize_t w = write(s->stdin_MINUS_fd, buf + off, len - off);
    if (w < 0) {
      if (errno == EINTR) continue;
      return -1;
    }
    off += (size_t)w;
  }
  return (int)len;
}

__attribute__((unused))
static String Subprocess_read_MINUS_chunk_(Subprocess *s, int max) {
  if (s->stdout_MINUS_fd < 0 || max <= 0) {
    String e = CARP_MALLOC(1);
    e[0] = '\0';
    return e;
  }
  String buf = CARP_MALLOC((size_t)max + 1);
  ssize_t r = read(s->stdout_MINUS_fd, buf, (size_t)max);
  if (r < 0) {
    buf[0] = '\0';
    return buf;
  }
  buf[r] = '\0';
  return buf;
}

__attribute__((unused))
static int Subprocess_alive_check_(Subprocess *s) {
  if (s->pid <= 0) return 0;
  int status;
  pid_t r = waitpid(s->pid, &status, WNOHANG);
  return r == 0 ? 1 : 0;
}

__attribute__((unused))
static int Subprocess_wait_(Subprocess *s) {
  if (s->pid <= 0) return -1;
  int status;
  if (waitpid(s->pid, &status, 0) < 0) return -1;
  if (WIFEXITED(status)) return WEXITSTATUS(status);
  return -1;
}

__attribute__((unused))
static void Subprocess_close(Subprocess sub) {
  if (sub.stdin_MINUS_fd >= 0) close(sub.stdin_MINUS_fd);
  if (sub.stdout_MINUS_fd >= 0) close(sub.stdout_MINUS_fd);
  if (sub.pid > 0) {
    int status;
    kill(sub.pid, SIGTERM);
    waitpid(sub.pid, &status, 0);
  }
}

__attribute__((unused))
static void Subprocess_close_MINUS_in_(Subprocess *s) {
  if (s->stdin_MINUS_fd >= 0) {
    close(s->stdin_MINUS_fd);
    s->stdin_MINUS_fd = -1;
  }
}

__attribute__((unused))
static Subprocess Subprocess_copy(Subprocess *s) {
  return *s;
}

#endif
