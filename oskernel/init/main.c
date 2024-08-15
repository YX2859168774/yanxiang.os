#include "../../tools/fileinfo.h"       //创建软盘要用的头文件 （没研究过，直接cv）
#include "../../tools/floppy.h"          //创建软盘要用的头文件 （没研究过，直接cv）

int kernel_main()
{
    char* boot_filepath = "/home/yanxiang/CLionProjects/yanxiang_X86_OS/build/boot/boot.o";                          //boot_filepath 指向MBR--boot.o的路径
    char* setup_filepath = "/home/yanxiang/CLionProjects/yanxiang_X86_OS/build/boot/setup.o";                        //setup_filepath指向setup.o的路径

    Floppy* floppy = create_floppy();                                                                                //创建软盘对象

    Fileinfo* boot_fileinfo = read_file(boot_filepath);                                                              //读取MBR文件并且写入软盘
    write_bootloader(floppy, boot_fileinfo);

    Fileinfo* setup_fileinfo = read_file(setup_filepath);                                                            //读取setup文件并且写入软盘
    write_floppy_fileinfo(floppy, setup_fileinfo, 0, 0, 2);

    create_image("/home/yanxiang/CLionProjects/yanxiang_X86_OS/yanxiang_diskette.img", floppy);                 //这个函数将内存中的软盘对象写入到
}