#include <iostream>
#include <string>

int main(int argc, char *argv[]) {
    std::cout << "Hello World from QNX 8!" << std::endl;
    std::cout << "Running on QEMU" << std::endl;

    if (argc > 1) {
        std::cout << "Arguments received: ";
        for (int i = 1; i < argc; ++i) {
            std::cout << argv[i];
            if (i < argc - 1) {
                std::cout << " ";
            }
        }
        std::cout << std::endl;
    }

    return EXIT_SUCCESS;
}
