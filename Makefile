# Straight forward Makefile to compile all examples in a row
MESA_INCLUDE ?= /home/cubox/mesa/include
MESA_LIB ?= /home/cubox/mesa/lib

CC = $(GCCPREFIX)gcc
CXX = $(GCCPREFIX)g++
LD = $(GCCPREFIX)ld
AR = $(GCCPREFIX)ar

INCDIR=-g -O -I./Common -I${MESA_INCLUDE} -DMESA_EGL_NO_X11_HEADERS
LIBS=-L${MESA_LIB} -lGLESv2 -lEGL -lm

COMMONSRC=./Common/esShader.c    \
          ./Common/esTransform.c \
          ./Common/esShapes.c    \
          ./Common/esUtil.c      \
	  ./Common/eglutil.c
COMMONHRD=esUtil.h eglutil.h write_bmp.h

CH02SRC=./Hello_Triangle/Hello_Triangle.c
CH08SRC=./Simple_VertexShader/Simple_VertexShader.c
CH09SRC1=./Simple_Texture2D/Simple_Texture2D.c
CH09SRC2=./MipMap2D/MipMap2D.c
CH09SRC3=./Simple_TextureCubemap/Simple_TextureCubemap.c
CH09SRC4=./TextureWrap/TextureWrap.c
CH10SRC=./MultiTexture/MultiTexture.c
CH11SRC=./Multisample/Multisample.c
CH11SRC2=./Stencil_Test/Stencil_Test.c
CH13SRC2=./ParticleSystem/ParticleSystem.c
CUBESRC=./Cube/cube.c
CUBEVBOSRC=./CubeVBO/cube_vbo.c
VIEWPORTSSRC=./Viewports/viewports.c

default: all

all: ./Hello_Triangle/CH02_HelloTriangle \
     ./Simple_VertexShader/CH08_SimpleVertexShader \
     ./Simple_Texture2D/CH09_SimpleTexture2D \
     ./MipMap2D/CH09_MipMap2D \
     ./Simple_TextureCubemap/CH09_TextureCubemap \
     ./TextureWrap/CH09_TextureWrap \
     ./MultiTexture/CH10_MultiTexture \
     ./Multisample/CH11_Multisample \
     ./Stencil_Test/CH11_Stencil_Test \
     ./ParticleSystem/CH13_ParticleSystem \
     ./Cube/cube \
     ./CubeVBO/cube_vbo \
     ./Viewports/viewports

clean:
	find . -name "CH??_*" | xargs rm -f

./Hello_Triangle/CH02_HelloTriangle: ${COMMONSRC} ${COMMONHDR} ${CH02SRC}
	${CC} ${COMMONSRC} ${CH02SRC} -o $@ ${INCDIR} ${LIBS}
./Simple_VertexShader/CH08_SimpleVertexShader: ${COMMONSRC} ${COMMONHDR} ${CH08SRC}
	${CC} ${COMMONSRC} ${CH08SRC} -o ./$@ ${INCDIR} ${LIBS}
./Simple_Texture2D/CH09_SimpleTexture2D: ${COMMONSRC} ${COMMONHDR} ${CH09SRC1}
	${CC} ${COMMONSRC} ${CH09SRC1} -o ./$@ ${INCDIR} ${LIBS}
./MipMap2D/CH09_MipMap2D: ${COMMONSRC} ${COMMONHDR} ${CH09SRC2}
	${CC} ${COMMONSRC} ${CH09SRC2} -o ./$@ ${INCDIR} ${LIBS}
./Simple_TextureCubemap/CH09_TextureCubemap: ${COMMONSRC} ${COMMONHDR} ${CH09SRC3}
	${CC} ${COMMONSRC} ${CH09SRC3} -o ./$@ ${INCDIR} ${LIBS}
./TextureWrap/CH09_TextureWrap: ${COMMONSRC} ${COMMONHDR} ${CH09SRC4}
	${CC} ${COMMONSRC} ${CH09SRC4} -o ./$@ ${INCDIR} ${LIBS}
./MultiTexture/CH10_MultiTexture: ${COMMONSRC} ${COMMONHDR} ${CH10SRC}
	${CC} ${COMMONSRC} ${CH10SRC} -o ./$@ ${INCDIR} ${LIBS}
./Multisample/CH11_Multisample: ${COMMONSRC} ${COMMONHDR} ${CH11SRC}
	${CC} ${COMMONSRC} ${CH11SRC} -o ./$@ ${INCDIR} ${LIBS}
./Stencil_Test/CH11_Stencil_Test: ${COMMONSRC} ${COMMONHDR} ${CH11SRC2}
	${CC} ${COMMONSRC} ${CH11SRC2} -o ./$@ ${INCDIR} ${LIBS}
./Noise3D/CH13_Noise3D: ${COMMONSRC} ${COMMONHDR} ${CH13SRC1}
	${CC} ${COMMONSRC} ${CH13SRC1} -o ./$@ ${INCDIR} ${LIBS}
./ParticleSystem/CH13_ParticleSystem: ${COMMONSRC} ${COMMONHDR} ${CH13SRC2}
	${CC} ${COMMONSRC} ${CH13SRC2} -o ./$@ ${INCDIR} ${LIBS}
./Cube/cube: ${COMMONSRC} ${COMMONHDR} ${CUBESRC}
	${CC} ${COMMONSRC} ${CUBESRC} -o ./$@ ${INCDIR} ${LIBS}
./CubeVBO/cube_vbo: ${COMMONSRC} ${COMMONHDR} ${CUBEVBOSRC}
	${CC} ${COMMONSRC} ${CUBEVBOSRC} -o ./$@ ${INCDIR} ${LIBS}
./Viewports/viewports: ${COMMONSRC} ${COMMONHDR} ${VIEWPORTSSRC}
	${CC} ${COMMONSRC} ${VIEWPORTSSRC} -o ./$@ ${INCDIR} ${LIBS}

