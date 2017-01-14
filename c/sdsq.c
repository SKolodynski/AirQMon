// KDB+ related part of sds011 library, compile with 
// gcc -shared -fPIC -DKXVER=3 sdsq.c sds.c -o sds.so
// gcc -shared -fPIC -m32 -DKXVER=3 sdsq.c sds.c -o sds.so

#include <stdio.h>

#include "k.h"
#include "sds.h"

static int fd = 0;

K on_data(int fd)
{
  uint16_t pm25;
  uint16_t pm10;

  int res = get_pm(fd,&pm25,&pm10);
  K r;
  if(res<0)
  {
    printf("error: get_pm returned %d\n",res);
    r = k(0,"onData",kh(nh),kh(nh),(K)0); // return nulls on error
  } 
  else r = k(0,"onData",kh(pm25),kh(pm10),(K)0);
  if(-128==r->t) printf("onData returned error:%s\n",r->s);
  r0(r);
  return (K)0;
}

K init(K port)
{
  if(port->t!=-KS) return krr("argument should be a symbol");
  fd = sds_init(port->s);
  if(fd<0) return krr("error initializing the port");
  sd1(fd,on_data);
  return (K)0;
}

K stop(K dummy)
{
  sd0(fd);
  close(fd);
}

