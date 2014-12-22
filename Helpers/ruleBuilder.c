#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "IfThisTinyDo.h"

int main(int argc, char** argv) {
    uint32_t command = 0;
    
    command |= SENSOR_LIGHT;
    command <<= 2;

    command |= EXPRESSION_LOWER;
    command <<= 16;

    command |= 0xFFFF;
    command <<= 3;

    command |= 0;
    command <<= 3;

    command |= 7;
    command <<= 6;

    int fd = open("command", O_CREAT | O_WRONLY, 0666);
    if (fd == -1) {
        perror("Error while opening output file");
        return 1;
    }

    if ((write(fd, &command, sizeof(command))) == -1) {
        perror("Error while writing output file");
        return 1;
    }

    close(fd);

    return 0;
}

