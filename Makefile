MESAPATH = /home/cubox/mesa
COMMON_FLAGS = -g -std=c99 -fPIC  -I$(MESAPATH)/include
CFLAGS += $(COMMON_FLAGS) -DMESA_EGL_NO_X11_HEADERS
CXXFLAGS += $(COMMON_FLAGS) 
LDFLAGS += -lm -L$(MESAPATH)/lib -lEGL -lGLESv2 
#../mesa/lib/egl/egl_gallium.so

GL_LIBS = $(PLATFORM_GL_LIBS)
TARGETS = cube compile cube_vbo rect
LIB_OBJS = esTransform.o write_bmp.o dump_gl_screen.o eglutil.o

all: $(TARGETS)

clean:
	rm -f *.o ../lib/*.o
	rm -f $(TARGETS)

cube: cube.o $(LIB_OBJS)
	$(CXX) $(CFLAGS) -o $@ $^  $(GL_LIBS) $(LDFLAGS)

cube_vbo: cube_vbo.o $(LIB_OBJS)
	$(CXX) $(CFLAGS) -o $@ $^  $(GL_LIBS) $(LDFLAGS)

rect: rect.o $(LIB_OBJS)
	$(CXX) $(CFLAGS) -o $@ $^  $(GL_LIBS) $(LDFLAGS)


compile: compile.o $(LIB_OBJS)
	$(CXX) $(CFLAGS) -o $@ $^  $(GL_LIBS) $(LDFLAGS)

eglinfo: eglinfo.o $(LIB_OBJS)
	$(CXX) $(CFLAGS) -o $@ $^  $(GL_LIBS) $(LDFLAGS)

