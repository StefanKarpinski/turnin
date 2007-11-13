#include <stdio.h>
int main() {
#ifdef VERBOSE
  printf("calling setuid(%d)...\n",UID);
#endif
  setuid(UID) && printf("setuid(%d) failed!\n",UID);
#ifdef VERBOSE
  printf("spawning shell...\n");
#endif
  execl("/bin/sh","/bin/sh",0);
  printf("execl(/bin/sh,/bin/sh,0) failed!\n");
}
