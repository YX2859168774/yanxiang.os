#ifndef YANXIANG_x86_OS_KERNEL_FILEINFO_H
#define YANXIANG_x86_OS_KERNEL_FILEINFO_H

typedef struct {
    char*   name;
    int     size;
    char*   content;
}Fileinfo;

Fileinfo* read_file(const char* filename);

#endif //YANXIANG_x86_OSKERNEL_FILEINFO_H
