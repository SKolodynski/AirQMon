#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>    // POSIX terminal control definitions
#include <unistd.h>     // UNIX standard function definitions
#include <string.h>     // memset

#include "sds.h"


#define MESSAGE_SIZE 9 // actually 1 less than the message size

/**
 * opens and configures port to read from
 * \param port
 * null-terminated string with the port name, typiially "/dev/ttyUSB0"
 * \return
 * the file descriptor of the port. < 0 means error 
 */
int sds_init(char* port)
{
    if(port==NULL) return -1;
    int fd = open(port, O_RDONLY);
    if(fd<0) {
      // printf("can't open %s\n",port);
      return -2;
    }

    struct termios tty;
    memset ((void*)&tty, 0, sizeof(tty));

    if ( tcgetattr ( fd, &tty ) != 0 )
    {
        // printf("tcgerattr retuned error\n");
        return -3;
    }

    cfsetispeed (&tty, B9600);
    
    tty.c_cflag     &=  ~PARENB;        // No parity
    tty.c_cflag     &=  ~CSTOPB;        // One stop bit
    tty.c_cflag     &=  ~CSIZE;         // char size
    tty.c_cflag     |=  CS8;
    tty.c_cflag     &=  ~CRTSCTS;       // no flow control
    
    tty.c_lflag     =   0;          // no signaling chars, no echo, no canonical processing
    tty.c_oflag     =   0;                  // no remapping, no delays
    tty.c_cflag     |=  CREAD | CLOCAL;     // turn on READ & ignore ctrl lines
    tty.c_iflag     &=  ~(IXON | IXOFF | IXANY);// turn off s/w flow ctrl
    tty.c_lflag     &=  ~(ICANON | ECHO | ECHOE | ISIG); // make raw
    tty.c_oflag     &=  ~OPOST;              // make raw
    
    
    // Flush the port, then apply attributes
    tcflush( fd, TCIFLUSH );

    if ( tcsetattr ( fd, TCSANOW, &tty ) != 0)
    {
        // printf("error setting attributes\n");
        return -4;
    }

    return fd;
}

/**
 * reads the pm data from the port
 * \param fd
 * file descriptor of the port
 * \param pm25
 * place to put the PM 2.5 value
 * \param pm10
 * place to put PM 10 value
 * \return 
 * 0 if success, <0 if error 
 */
int get_pm(int fd,uint16_t* pm25,uint16_t* pm10)
{
  
    uint8_t buf[MESSAGE_SIZE];
    // wait for the 0xAA - message header
    uint8_t byte = 0;
    while(byte!=0xAA) 
    {
      ssize_t size = read(fd,&byte,1);
      if(size==!1) return -1; // probably can't happen with this port configuration		
    }
    
    // ssize_t size = read(fd,buf,MESSAGE_SIZE); this may return partial message, see http://www.linux-mag.com/id/308/

    int remaining = MESSAGE_SIZE;
    uint8_t* curr_buf = buf;
    while(remaining)
    {
      ssize_t size = read(fd,curr_buf,remaining);
      if(size<0) return -2; // error
      remaining-=size;
      curr_buf+=size;
    } 

    if(buf[MESSAGE_SIZE-1]!=0xAB) return -3; // last byte should be the message tail
    
    uint16_t checksum = buf[1]+buf[2]+buf[3]+buf[4]+buf[5]+buf[6];
    if((checksum & 0xFF) != buf[7]) return -4;
    
    // everyting seems to be ok, put values in place
    *pm25 = ((((uint16_t) buf[2]) << 8) | buf[1])/10;
    *pm10 = ((((uint16_t) buf[4]) << 8) | buf[3])/10;

    return 0;
    
}

