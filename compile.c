#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include <EGL/egl.h>
#include <GLES2/gl2.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <stdarg.h>

#include "esTransform.h"
#include "eglutil.h"
#include "dump_gl_screen.h"

static EGLint const config_attribute_list[] = {
	EGL_RED_SIZE, 8,
	EGL_GREEN_SIZE, 8,
	EGL_BLUE_SIZE, 8,
	EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
	EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
	EGL_DEPTH_SIZE, 8,
	EGL_NONE
};

static EGLint const pbuffer_attribute_list[] = {
	EGL_WIDTH, 400,
	EGL_HEIGHT, 240,
	EGL_LARGEST_PBUFFER, EGL_TRUE,
    EGL_NONE
};

static const EGLint context_attribute_list[] = {
	EGL_CONTEXT_CLIENT_VERSION, 2,
	EGL_NONE
};

static char *
load_text_file(const char *file_name)
{
	char *text = NULL;
	size_t size;
	size_t total_read = 0;
	FILE *fp = fopen(file_name, "rb");

	if (!fp) {
		return NULL;
	}

	fseek(fp, 0L, SEEK_END);
	size = ftell(fp);
	fseek(fp, 0L, SEEK_SET);

	text = (char *) malloc(size + 1);
	if (text != NULL) {
		do {
			size_t bytes = fread(text + total_read,
					     1, size - total_read, fp);
			if (bytes < size - total_read) {
				free(text);
				text = NULL;
				break;
			}

			if (bytes == 0) {
				break;
			}

			total_read += bytes;
		} while (total_read < size);

		text[total_read] = '\0';
	}

	fclose(fp);

	return text;
}

int main(int argc, char *argv[])
{
	EGLDisplay display;
	EGLint egl_major, egl_minor;
	EGLConfig config;
	EGLint num_config;
	EGLContext context;
	EGLSurface surface;
	GLuint vertex_shader;
	GLuint fragment_shader;
	GLuint program;
	GLint ret;
	GLint width, height;

        if(argc < 3)
        {
            fprintf(stderr, "usage: compile <shader.vert> <shader.frag>\n");
            exit(1);
        }
	const char *vertex_shader_source = load_text_file(argv[1]);
        if(!vertex_shader_source)
        {
            fprintf(stderr, "cannot open vertex shader: %s\n", argv[1]);
            exit(1);
        }
	const char *fragment_shader_source = load_text_file(argv[2]);
        if(!vertex_shader_source)
        {
            fprintf(stderr, "cannot open fragment shader: %s\n", argv[2]);
            exit(1);
        }

	display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
	if (display == EGL_NO_DISPLAY) {
		printf("Error: No display found!\n");
		return -1;
	}

	if (!eglInitialize(display, &egl_major, &egl_minor)) {
		printf("Error: eglInitialise failed!\n");
		return -1;
	}

	/* get an appropriate EGL frame buffer configuration */
	eglChooseConfig(display, config_attribute_list, &config, 1, &num_config);

	/* create an EGL rendering context */
	context = eglCreateContext(display, config, EGL_NO_CONTEXT, context_attribute_list);
	if (context == EGL_NO_CONTEXT) {
		printf("Error: eglCreateContext failed: %d\n", eglGetError());
		return -1;
	}

	surface = eglCreatePbufferSurface(display, config, pbuffer_attribute_list);
	if (surface == EGL_NO_SURFACE) {
		printf("Error: eglCreatePbufferSurface failed: %d (%s)\n",
		       eglGetError(), eglStrError(eglGetError()));
		return -1;
	}

	if (!eglQuerySurface(display, surface, EGL_WIDTH, &width) ||
	    !eglQuerySurface(display, surface, EGL_HEIGHT, &height)) {
		printf("Error: eglQuerySurface failed: %d (%s)\n",
		       eglGetError(), eglStrError(eglGetError()));
		return -1;
	}

	/* connect the context to the surface */
	if (!eglMakeCurrent(display, surface, surface, context)) {
		printf("Error: eglMakeCurrent() failed: %d (%s)\n",
		       eglGetError(), eglStrError(eglGetError()));
		return -1;
	}

	vertex_shader = glCreateShader(GL_VERTEX_SHADER);
	if (!vertex_shader) {
		printf("Error: glCreateShader(GL_VERTEX_SHADER) failed: %d (%s)\n",
		       eglGetError(), eglStrError(eglGetError()));
		return -1;
	}


	glShaderSource(vertex_shader, 1, &vertex_shader_source, NULL);
	glCompileShader(vertex_shader);

	glGetShaderiv(vertex_shader, GL_COMPILE_STATUS, &ret);
	if (!ret) {
		char *log;

		printf("Error: vertex shader compilation failed!:\n");
		glGetShaderiv(vertex_shader, GL_INFO_LOG_LENGTH, &ret);

		if (ret > 1) {
			log = malloc(ret);
			glGetShaderInfoLog(vertex_shader, ret, NULL, log);
			printf("%s", log);
		}
		return -1;
	} else
		printf("Vertex shader compilation succeeded!\n");

	fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
	if (!fragment_shader) {
		printf("Error: glCreateShader(GL_FRAGMENT_SHADER) failed: %d (%s)\n",
		       eglGetError(), eglStrError(eglGetError()));
		return -1;
	}


	glShaderSource(fragment_shader, 1, &fragment_shader_source, NULL);
	glCompileShader(fragment_shader);

	glGetShaderiv(fragment_shader, GL_COMPILE_STATUS, &ret);
	if (!ret) {
		char *log;

		printf("Error: fragment shader compilation failed!:\n");
		glGetShaderiv(fragment_shader, GL_INFO_LOG_LENGTH, &ret);

		if (ret > 1) {
			log = malloc(ret);
			glGetShaderInfoLog(fragment_shader, ret, NULL, log);
			printf("%s", log);
		}
		return -1;
	} else
		printf("Fragment shader compilation succeeded!\n");

	program = glCreateProgram();
	if (!program) {
		printf("Error: failed to create program!\n");
		return -1;
	}

	glAttachShader(program, vertex_shader);
	glAttachShader(program, fragment_shader);

	glLinkProgram(program);

	glGetProgramiv(program, GL_LINK_STATUS, &ret);
	if (!ret) {
		char *log;

		printf("Error: program linking failed!:\n");
		glGetProgramiv(program, GL_INFO_LOG_LENGTH, &ret);

		if (ret > 1) {
			log = malloc(ret);
			glGetProgramInfoLog(program, ret, NULL, log);
			printf("%s", log);
		}
		return -1;
	} else
		printf("program linking succeeded!\n");

	glUseProgram(program);
        /* need to do this to trigger actual linking of the shader */
	glViewport(0, 0, width, height);
	glClear(GL_COLOR_BUFFER_BIT);
	glFlush();

	fflush(stdout);

	return 0;
}
