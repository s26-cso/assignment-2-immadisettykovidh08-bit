#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main() {
    char op[6];   // max 5 chars + null
    int num1, num2;

    // infinite loop until EOF
    while (scanf("%s %d %d", op, &num1, &num2) == 3) {

        // construct library name: lib<op>.so
        char libname[20];
        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        // load shared library
        void *handle = dlopen(libname, RTLD_LAZY);
        if (!handle) {
            fprintf(stderr, "Error loading %s\n", libname);
            continue;
        }

        // clear any existing errors
        dlerror();

        // get function symbol
        int (*func)(int, int);
        *(void **)(&func) = dlsym(handle, op);

        char *error = dlerror();
        if (error != NULL) {
            fprintf(stderr, "Error finding function %s\n", op);
            dlclose(handle);
            continue;
        }

        // call the function
        int result = func(num1, num2);

        // print result
        printf("%d\n", result);

        // unload library (VERY IMPORTANT)
        dlclose(handle);
    }

    return 0;
}