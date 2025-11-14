// module_1/src/hello_world.cpp
#include <iostream>
#include <string>
#include <unistd.h>
#include <sys/neutrino.h>

class QNXApplication {
public:
    QNXApplication(const std::string& name) : app_name_(name) {}

    void run() {
        displayHeader();
        displaySystemInfo();
        displayMessage();
    }

private:
    std::string app_name_;

    void displayHeader() const {
        std::cout << "========================================\n";
        std::cout << "  " << app_name_ << "\n";
        std::cout << "========================================\n";
    }

    void displaySystemInfo() const {
        std::cout << "Process ID: " << getpid() << "\n";
        std::cout << "Running on QNX "
                  << _NTO_VERSION / 100 << "."
                  << _NTO_VERSION % 100 << "\n";
    }

    void displayMessage() const {
        std::cout << "\nThis is your first QNX C++ application!\n";
        std::cout << "Built with Bazel and running successfully.\n";
        std::cout << "========================================\n";
    }
};

int main(int argc, char* argv[]) {
    QNXApplication app("Hello from QNX Neutrino!");
    app.run();
    return EXIT_SUCCESS;
}
