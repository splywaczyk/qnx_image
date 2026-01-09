// qnx_application.cpp
// QNX Application class - Implementation file
#include "qnx_application.h"

#include <iostream>
#include <unistd.h>
#include <sys/neutrino.h>

namespace qnx {

Application::Application(std::string_view name)
    : app_name_(name) {}

void Application::run() const {
    displayHeader();
    displaySystemInfo();
    displayMessage();
}

void Application::displayHeader() const {
    std::cout << "========================================\n"
              << "  " << app_name_ << "\n"
              << "========================================\n";
}

void Application::displaySystemInfo() const {
    const auto pid = getpid();
    const auto major_version = _NTO_VERSION / 100;
    const auto minor_version = _NTO_VERSION % 100;

    std::cout << "Process ID: " << pid << "\n"
              << "Running on QNX " << major_version << "."
              << minor_version << "\n";
}

void Application::displayMessage() const {
    std::cout << "\nThis is your first QNX C++ application!\n"
              << "========================================\n";
}

} // namespace qnx
