// main.cpp
// Entry point for QNX Hello World application
#include "qnx_application.h"

#include <cstdlib>

int main() {
    qnx::Application app("Hello from QNX Neutrino!");
    app.run();
    return EXIT_SUCCESS;
}
