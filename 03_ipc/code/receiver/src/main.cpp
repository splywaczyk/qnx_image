// main.cpp
// Entry point for Secure Message Receiver
#include "secure_message_receiver.h"

#include <iostream>
#include <cstdlib>

namespace {
    constexpr const char* RECEIVER_NAME = "qnx_receiver_secure";
}

int main() {
    qnx::ipc::SecureMessageReceiver receiver(RECEIVER_NAME);

    if (!receiver.initialize()) {
        return EXIT_FAILURE;
    }

    receiver.run();

    std::cout << "Secure receiver shutting down\n";
    return EXIT_SUCCESS;
}
