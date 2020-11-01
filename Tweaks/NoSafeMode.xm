#import "../Headers/NoSafeMode.h"
#include <signal.h>

void sig_handler(int num, siginfo_t *info, void *ctx){
    return;
}

void loadNoSafeMode() {
  struct sigaction sa_sigabrt;
  memset(&sa_sigabrt, 0, sizeof(sa_sigabrt));
  sa_sigabrt.sa_sigaction = sig_handler;
  sa_sigabrt.sa_flags = SA_SIGINFO;

  sigaction(3, &sa_sigabrt, NULL);
  sigaction(4, &sa_sigabrt, NULL);
  sigaction(5, &sa_sigabrt, NULL);
  sigaction(6, &sa_sigabrt, NULL);
  sigaction(7, &sa_sigabrt, NULL);
  sigaction(8, &sa_sigabrt, NULL);
  sigaction(0xa, &sa_sigabrt, NULL);
  sigaction(0xb, &sa_sigabrt, NULL);
  sigaction(0xc, &sa_sigabrt, NULL);
}
