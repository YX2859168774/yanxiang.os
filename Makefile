BUILD:=./build                  #输出目录

CFLAGS:= -m32                   # 使用 32 位的程序
CFLAGS+= -masm=intel            # 指定使用intel风格的汇编语法
CFLAGS+= -fno-builtin	        # （禁止使用gcc内置函数，如果gcc内置函数与标准库函数同名，也不会使用内置函数，而是使用标准库函数）不需要 gcc 内置函数
CFLAGS+= -nostdinc	        	# 不需要标准头文件，只使用自己提供的头文件目录
CFLAGS+= -fno-pic		        # 不需要位置无关的代码  position independent code
CFLAGS+= -fno-pie		        # 不需要位置无关的可执行程序 position independent executable
CFLAGS+= -nostdlib	        	# 不需要标准库
CFLAGS+= -fno-stack-protector	# 不需要栈保护
CFLAGS:=$(strip ${CFLAGS})      #取出CFLAGS的值，去除CFLAGS多余的空格的结果，赋值回“GLAGS”

DEBUG:= -g                      #这是一个调试标志，“-g”用于在编译过程中生成调试信息，这些信息可以在使用调试器（如GDB）时帮助调试程序

HD_IMG_NAME:= "hd.img"          #生成的硬盘镜像文件的名称为“hd.img”

all: ${BUILD}/boot/boot.o ${BUILD}/boot/setup.o ${BUILD}/system.bin                             #构建 all 目标  (在没有指定其他目标时，执行“make”会执行这个目标)
																		                        #且all目标依赖于${BUILD}/boot/boot.o、${BUILD}/boot/setup.o 和 ${BUILD}/system.bin）
                                                                                                #把BUILD:=./build 带入{BUILD}
                                                                                                #可得目标依赖于./build/boot/boot.o、./build/boot/setup.o 和 ./build/system.bin）

	$(shell rm -rf $(BUILD)/$(HD_IMG_NAME))                                                     #使用 $(shell ...) 函数执行一个 Shell 命令，如果存在硬盘镜像文件hd.img在当前目录下的build，则rm -rf 用于递归删除./build/hd.ing文件

	bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $(BUILD)/$(HD_IMG_NAME)          #  bxmage:这是用于创建虚拟硬盘镜像的命令行工具;  -q:这个选项表示 "quiet" 模式，即静默模式;
	                                                                                            #  -hd=16:要创建的硬盘大小为 16 MB,-hd 后的数字是硬盘大小，以 MB 为单位;
																								#  -func=create:指定 bximage 要执行的操作类型为 "create"，即创建一个新的硬盘镜像文件;
																								#  -sectsize=512:指定硬盘的每个扇区大小为 512 字节;
																								#  -imgmode=flat:指定创建的硬盘镜像文件的模式为 "flat" 模式;
																								#  [Flat模式：硬盘镜像文件会直接占用指定大小的空间。sparse模式：硬盘镜像文件在磁盘上只占用实际使用到的空间]
																								#  $(BUILD)/$(HD_IMG_NAME):这是镜像文件的输出路径,./build/hd.img;
																								#  使用 bximage 工具创建一个 16MB 的平面（flat）模式硬盘镜像文件，扇区大小为 512 字节，文件名为 hd.img。

	dd if=${BUILD}/boot/boot.o of=$(BUILD)/$(HD_IMG_NAME) bs=512 seek=0 count=1 conv=notrunc    #  if=${BUILD}/boot/boot.o: if 代表 "input file"（输入文件);${BUILD}/boot/boot.o 是输入文件的路径--./build/boot/boot.o
																								#  of=$(BUILD)/$(HD_IMG_NAME):of:output file（输出文件）;$(BUILD)/$(HD_IMG_NAME)(./build/hd.img)是输出文件的路径，即将数据写入到这个文件
																								#  bs:"block size"（块大小）;指定块大小为 512 字节; dd 将以每块 512 字节的单位来读取和写入数据
																								#  seek:指定跳过输出文件中的多少个块后开始写入数据; seek=0: 从输出文件的开始位置（即第一个块）写入数据。这里没有跳过任何块，直接从第一个扇区开始写入
																								#  count:指定要复制多少个块;count=1 表示只复制一个块（即 512 字节）的数据,这里会从 boot.o 文件中读取 512 字节并写入到 hd.img的第一个扇区。
																								#  conv:选项指定如何转换数据;notrunc 选项表示不要截断输出文件。notrunc 选项可以确保 dd 只覆盖指定的部分，而不改变文件的其他部分或缩短文件的长度。
																								#  目的是将 boot.o 文件的前 512 字节（一个块）的数据写入到硬盘镜像文件 hd.img 的第一个扇区（即从文件开始的地方）。
																								#  这通常用于将引导程序写入到硬盘镜像的第一个扇区，即所谓的主引导记录（MBR）。
																								#  使用 conv=notrunc 确保不会截断镜像文件，使得在后续写入 setup.o 和 system.bin 时，文件结构保持完整。

	dd if=${BUILD}/boot/setup.o of=$(BUILD)/$(HD_IMG_NAME) bs=512 seek=1 count=2 conv=notrunc   #  使用 dd 命令将 setup.o 写入硬盘镜像的第二和第三个扇区。seek=1 表示从第二个扇区开始写入，count=2 表示写入两个块。

	dd if=${BUILD}/system.bin of=$(BUILD)/$(HD_IMG_NAME) bs=512 seek=3 count=60 conv=notrunc    #  使用 dd 命令将 system.bin 写入硬盘镜像，从第四个扇区开始写入，共写入 60 个块。

${BUILD}/system.bin: ${BUILD}/kernel.bin                                                        #  中间目标 定义system.bin，它依赖于kernel.bin文件
	objcopy -O binary ${BUILD}/system.bin ${BUILD}/kernel.bin                                   #  所用objcopy命令将kernel.bin 转换为纯二进制文件，生成ystem.bin
																								#  objcopy 是一个GNU工具，用于将对象文件的格式转换为另外一种文件格式
																								#  -o binary指定输出文件格式。
																								#  ${BUILD}/kernel.bin 这是输出文件，即需要转换的对象文件
																								#  ${BUILD}/kernel.bin 这是输入文件，objcopy 命令将转换后的纯二进制数据保存到 system.bin 文件中。

	nm ${BUILD}/kernel.bin | sort > ${BUILD}system.map                                          #  使用nm命令列出kernel.bin中的符号表，并对其进行排序后输出到system.map
																								#  nm是一个用于显示二进制文件中符号表的命令行工具;符号表包含了程序中的函数、全局变量等符号及其对应的地址; 在此处他用于提取kernel.bin文件中所有符号信息
																								#  “|”（管道符号） 用于将一个命令的输出传递给另一个命令作为输入。
																								#  “sort” 是一个用于对文本文件中的内容进行排序的命令（默认的情况下，他按字母顺序排序）； “>”是输出重定向符号，用于将命令的输出保存到指定的文件中。
																								#  在此处通过 “sort”命令对符号表按字母顺序排序，而“> ${BUILD}/system.map”则将排序后的结果保存到 system.map 文件中

${BUILD}/kernel.bin: ${BUILD}/boot/head.o ${BUILD}/init/main.o                                  #  ......
	ld -m elf_i386 $^ -o $@ -Ttest 0x1200                                                       #  使用ld链接器将head.o 和 main.o 文件链接成 kernel.bin，链接地址为0x1200
																								#  "ld"这是GNU链接器，用于将多个目标文件链接成一个可执行文件或其他格式的文件
																								#  "-m elf_i386"在个选项指定生成的文件格式为32位的ELF格式，适用于X86架构的处理器
																								#  "$^"这是Makefile中的自动化变量，代表所有的依赖文件这里指（${BUILD}/boot/head.o 和 ${BUILD}/init/main.o）
																								#  "-o $@"这个选项指定输出文件名，其中“$@”是Makefile的一个自动化变量，代表当前规格的目标文件（kernel.bin）
																								#  -Ttext 0x1200 这个选项指定了链接过程中代码段的加载地址

${BUILD}/init/main.o: oskernel/init/main.c                                                      #  main.o 依赖于 main.c
	$(shell mkdir -p ${BUILD}/init)                                                             #  使用shell函数调用mkdir命令创建目标目录build/init（如果目标目录不存在）
	gcc ${CFLAGS} ${DEBUG} -c $< -o $@                                                          #  使用GCC编译main.c 为 main.o，使用前面定义的CFLAGS和DEBUG选项

${BUILD}/boot/head.o: oskernel/boot/head.asm                                                    #  head.o 依赖于head.asm
	nasm -f elf32 -g $< -o $@																	#  使用NASM汇编器将head.asm编译为ELF32位格式的head.o
																								#  nasm 是一个开源的汇编编译器
																								#  ”-f elf32“ 这个选项指定了 nasm 的输出格式为 32 位的 ELF 格式
																								#  “-g” nasm 在编译时生成调试信息 ，生成的ELF文件将包含调试信息
																								#  “$<”  这是Makefile中的自动化变量，代表第一个依赖文件。
																								#  “$@”  代表规则的目标文件

${BUILD}/boot/%.o: oskernel/boot/%.asm                                                          #  这是一个通配符规则：表示如何从某个模式匹配的文件生成另一个文件。
																								#  ${BUILD}/BOOT/%.O: 目标文件 “%”这是一个通配符，匹配任何字符串；
																								#  oskernel/boot/%.asm: 依赖文件模式。% 通配符与目标文件中的 % 匹配，表示从 oskernel/boot 目录中的 .asm 文件生成 .o 文件。

	$(shell mkdir -p ${BUILD}/boot)                                                             #  ”-p“选项表示如果目标目录如果不存在，则递归创建该目录（包括创建任何必要的目录），如果目录已经存在，不会报错
	nasm $< -o $@                                                                               #  将编译源文件 oskernel/boot/%.asm 为目标文件 ${BUILD}/boot/%.o

clean:                                                                                          #  ......
	$(shell rm -rf ${BUILD})                                                                    #  ......

bochs: all                                                                                      #  ......
	bochs -q -f bochsrc                                                                         #  "-q" 是 bochs 的一个选项，表示“quiet mode”（安静模式），它将抑制启动时的提示信息，让 bochs 直接进入仿真运行模式。
																								#  "-f bochsrc" 这个选项指定 bochs 使用 bochsrc 文件作为配置文件。

qemug: all                                                                                      #  这个qemug目标依赖于all这个目标
	qemu-system-x86_64 -m 32M -hda ./build/hd.img -S -s                                         #  qemu-system-x86_64： 用于启动一个64位的虚拟机
																								#  -m 32M 为虚拟机分配32MB的内存；-hda ./build/hd.img是虚拟机启动时使用的硬盘镜像
																								#  -S 使虚拟机在启动时立即暂停（用于调试，以便在虚拟机启动前进行断点设置或连接调试器）
																								#  -s 启用qemu的内置GDB服务器，默认在端口1234上监听。

qemu: all																						#  ......
	qemu-system-i386																			#  用于启动一个32位的虚拟机
	-m 32M																						#  为虚拟机分配32MB的内存
	-boot c                                                                                     #  从硬盘（通常是C盘）引导虚拟机
	-hda ./build/hd.img                                                                         #  指定硬盘映像文件，./build/hd.img 是虚拟机启动时使用的硬盘镜像

vmdk: $(BUILD)/master.vmdk                                                                      #  生成的内核镜像给VBox、VMware用

$(BUILD)/master.vmdk: ./build/hd.img                                                            #  ......
	qemu-img convert -O vmdk $< $@	                                                            #  qemu-img convert： 这是QEMU的一个工具命令，用于在不同的虚拟机磁盘格式之间进行转换
																								#  输出格式为VMDK，这是VirtualBox和VMware使用的虚拟磁盘格式。
																								#  $<： 表示第一个依赖项
																								#  $@： 表示目标文件




















