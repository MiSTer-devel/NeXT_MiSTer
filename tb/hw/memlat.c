#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
static double now(){struct timeval t;gettimeofday(&t,0);return t.tv_sec+t.tv_usec/1e6;}
int main(){int n=4<<20,i,r,s;register int k=0;char*b=malloc(n);int*w=(int*)b;double t0,t1;
for(i=0;i<n;i++)b[i]=i;
for(s=4;s<=64;s*=4){t0=now();for(r=0;r<4;r++)for(i=0;i<n;i+=s)k+=b[i];t1=now();
printf("S%d: %.1f ns/acc\n",s,(t1-t0)*1e9/(4.0*n/s));}
t0=now();for(r=0;r<4;r++)for(i=0;i<n/4;i+=4)k+=w[i];t1=now();
printf("L16: %.1f ns/acc\n",(t1-t0)*1e9/(4.0*n/16));
t0=now();for(r=0;r<4;r++)for(i=0;i<n/4;i++)w[i]=i;t1=now();
printf("W4: %.1f ns/store\n",(t1-t0)*1e9/(4.0*n/4));
t0=now();for(r=0;r<2000;r++)for(i=0;i<1024;i++)k+=w[i];t1=now();
printf("cached: %.1f ns/acc k=%d\n",(t1-t0)*1e9/(2000.0*1024),k);
return 0;}
