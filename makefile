TARGET := main

CC := clang++

# 注意每行后面不要有空格，否则会算到目录名里面，导致问题
SRC_DIR = oc_src cpp_src
BUILD_DIR = tmp
OBJ_DIR = $(BUILD_DIR)/obj
DEPS_DIR  = $(BUILD_DIR)/deps
# 这里添加其他头文件路径
INC_DIR := -I. -I./oc_head -I./cpp_head -I/home/yhs/GNUstep/Library/Headers -I/usr/local/include/GNUstep -I/usr/include/GNUstep -I/lib/gcc/x86_64-linux-gnu/9/include -I/usr/include/c++/9 -I/usr/include/c++/9/backward -I/usr/include/x86_64-linux-gnu/c++/9

# 这里添加编译参数
CC_FLAGS := -stdlib=libstdc++ -pthread -g -O2 -rdynamic -shared-libgcc -Wall -Wno-import -Wobjc-property-implementation
FLAGS = -fblocks -fno-strict-aliasing -fexceptions -fobjc-exceptions -fPIC -fgnu-runtime -fconstant-string-class=NSConstantString
MACRO_FLAGS = -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -D_NATIVE_OBJC_EXCEPTIONS -DGSWARN -DGSDIAGNOSE
OTHER_FLAGS = 

# 这里添加库目录和库
LIB_PATH := -Llibs -L/usr/local/lib -L/usr/lib -L/home/yhs/GNUstep/Library/Libraries -L/home/yhs/GNUstep/Library/Libraries -L/usr/local/lib -L/usr/lib
LIBS := -lBlocksRuntime -ldispatch -lgnustep-base -lobjc -lm 

# 这里递归遍历3级子目录
#  DIRS := $(shell find $(SRC_DIR) -maxdepth 3 -type d)
DIRS := ./ $(SRC_DIR)

# 将每个子目录添加到搜索路径
VPATH = $(DIRS)

# 查找src_dir下面包含子目录的所有cpp文件
# SOURCES = $(foreach dir, $(DIRS), $(wildcard $(dir)/*.cpp $(dir)/*.m $(dir)/*.mm))
OCM_SRCS = $(foreach dir, $(DIRS), $(wildcard $(dir)/*.m))
OCMM_SRCS = $(foreach dir, $(DIRS), $(wildcard $(dir)/*.mm))
CPP_SRCS = $(foreach dir, $(DIRS), $(wildcard $(dir)/*.cpp))

OBJS := $(addprefix $(OBJ_DIR)/,$(patsubst %.m,%.o,$(notdir $(OCM_SRCS))))
OBJS := $(OBJS) $(addprefix $(OBJ_DIR)/,$(patsubst %.mm,%.o,$(notdir $(OCMM_SRCS))))
OBJS := $(OBJS) $(addprefix $(OBJ_DIR)/,$(patsubst %.cpp,%.o,$(notdir $(CPP_SRCS))))

DEPS := $(addprefix $(DEPS_DIR)/, $(patsubst %.m,%.d,$(notdir $(OCM_SRCS))))
DEPS := $(DEPS) $(addprefix $(DEPS_DIR)/, $(patsubst %.mm,%.d,$(notdir $(OCMM_SRCS))))
DEPS := $(DEPS) $(addprefix $(DEPS_DIR)/, $(patsubst %.cpp,%.d,$(notdir $(CPP_SRCS))))

.PHONY : all
all:$(TARGET)

$(TARGET):$(OBJS)
	$(CC) -std=gnu11 $(CC_FLAGS) $(FLAGS) $(INC_DIR) $(LIB_PATH) $(LIBS) $(MACRO_FLAGS) $^ -o $@

# 源文件编译成中间文件，编译之前要创建OBJ目录，确保目录存在
$(OBJ_DIR)/%.o:%.m
	@if [ ! -d $(OBJ_DIR) ]; then mkdir -p $(OBJ_DIR); fi
	$(CC) -std=gnu11 $(OTHER_FLAGS) $(CC_FLAGS) $(FLAGS) $(INC_DIR) $(LIB_PATH) $(LIBS) $(MACRO_FLAGS) $< -c -o $@

$(OBJ_DIR)/%.o:%.mm
	@if [ ! -d $(OBJ_DIR) ]; then mkdir -p $(OBJ_DIR); fi
	$(CC) -std=c++11 $(OTHER_FLAGS) $(CC_FLAGS) $(FLAGS) $(INC_DIR) $(LIB_PATH) $(LIBS) $(MACRO_FLAGS) $< -c -o $@

$(OBJ_DIR)/%.o:%.cpp
	@if [ ! -d $(OBJ_DIR) ]; then mkdir -p $(OBJ_DIR); fi
	$(CC) -std=c++11 $(OTHER_FLAGS) $(CC_FLAGS) $(FLAGS) $(INC_DIR) $(LIB_PATH) $(LIBS) $(MACRO_FLAGS) $< -c -o $@

# 生成源文件依赖头文件，编译之前要创建DEPS目录，确保目录存在
# 前面加@表示隐藏命令的执行打印
$(DEPS_DIR)/%.d:%.m
	@if [ ! -d $(DEPS_DIR) ]; then mkdir -p $(DEPS_DIR); fi;\
	set -e; rm -f $@;\
	$(CC) -MM -std=gnu11 $(CC_FLAGS) $(FLAGS) $(INC_DIR) $(LIB_PATH) $(LIBS) $(MACRO_FLAGS) $< > $@.$$$$;\
	sed 's,\($*\)\.o[ :]*,$(OBJ_DIR)/\1.o $@ : ,g' < $@.$$$$ > $@;\
	rm -f $@.$$$$

$(DEPS_DIR)/%.d:%.mm
	@if [ ! -d $(DEPS_DIR) ]; then mkdir -p $(DEPS_DIR); fi;\
	set -e; rm -f $@;\
	$(CC) -MM -std=c++11 $(CC_FLAGS) $(FLAGS) $(INC_DIR) $(LIB_PATH) $(LIBS) $(MACRO_FLAGS) $< > $@.$$$$;\
	sed 's,\($*\)\.o[ :]*,$(OBJ_DIR)/\1.o $@ : ,g' < $@.$$$$ > $@;\
	rm -f $@.$$$$

$(DEPS_DIR)/%.d:%.cpp
	@if [ ! -d $(DEPS_DIR) ]; then mkdir -p $(DEPS_DIR); fi;\
	set -e; rm -f $@;\
	$(CC) -MM -std=c++11 $(CC_FLAGS) $(FLAGS) $(INC_DIR) $(LIB_PATH) $(LIBS) $(MACRO_FLAGS) $< > $@.$$$$;\
	sed 's,\($*\)\.o[ :]*,$(OBJ_DIR)/\1.o $@ : ,g' < $@.$$$$ > $@;\
	rm -f $@.$$$$

# 前面加-表示忽略错误
-include $(DEPS)

.PHONY : clean

clean:
	-rm -rf $(OBJ_DIR)/*.o $(DEPS_DIR)/*  $(TARGET)