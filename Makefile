.PHONY: all test
all:
TESTS := got_finder_test \
		 plt_caller_test

test: $(TESTS)
MAIN_OBJS := log.o \
		got_finder.o \
		ptracer.o \

MAIN_TEST_OBJS :=  \
				  got_finder_test.o \
				  test.o \

X64_MAIN_OBJS := \
				 x64/plt_caller.o \

X64_TEST_OBJS := \
				 x64/plt_caller_test.o \

OBJS := $(MAIN_OBJS) \
		\
		$(MAIN_TEST_OBJS) \
		\
		$(X64_MAIN_OBJS) \
		\
		$(X64_TEST_OBJS)

CFLAGS := -O0 -g -Wall -I. -fPIC -fvisibility=hidden

LDFLAGS := -pie
LDLIBS := -lpthread -lrt

-include $(OBJS:.o=.d)

%.o: %.c
	gcc $(CFLAGS) -c $*.c -o $*.o
	gcc -MM $(CFLAGS) $*.c > $*.d

%.o: %.cpp
	g++ $(CFLAGS) -c $*.cpp -o $*.o
	g++ -MM $(CFLAGS) $*.cpp > $*.d

%.o: %.S
	g++ $(CFLAGS) -c $*.S -o $*.o
	g++ -MM $(CFLAGS) $*.S > $*.d

got_finder_test: got_finder.o log.o got_finder_test.o ptracer.o
	g++ $(LDFLAGS) -o $@ $^ $(LDLIBS) -ldl

plt_caller_test: got_finder.o log.o ptracer.o x64/plt_caller_test.o x64/plt_caller.o libtest.so
	g++ $(LDFLAGS) -o $@ $^ $(LDLIBS) -ldl

libtest.so: test.o
	g++ $(LDFLAGS) -shared -o $@ $^ $(LDLIBS)

clean:
	rm *.o *.d **/*.o **/*.d
test_all: $(TESTS)
	$(foreach test, $^, $(info ./$(test)))