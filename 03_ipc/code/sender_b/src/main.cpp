// main.cpp
// Entry point for Sender B (Unauthorized Sender - will be blocked by secpol)
#include "message_sender.h"

#include <iostream>
#include <cstdlib>
#include <chrono>
#include <thread>

namespace {
    constexpr const char* SENDER_ID = "SENDER2";
    constexpr const char* RECEIVER_NAME = "qnx_receiver_secure";

    // Sender B configuration
    constexpr int MESSAGE_COUNT = 7;
    constexpr auto INTERVAL = std::chrono::seconds(3);
    constexpr uint16_t MESSAGE_TYPE = 2;
    constexpr uint16_t MESSAGE_SUBTYPE = 200;

    // Wait before starting to allow sender_a to connect first
    constexpr auto STARTUP_DELAY = std::chrono::seconds(1);
}

int main() {
    using namespace qnx::ipc;

    // Wait a bit before starting
    std::this_thread::sleep_for(STARTUP_DELAY);

    MessageSender sender(SENDER_ID, RECEIVER_NAME);

    if (!sender.connect()) {
        return EXIT_FAILURE;
    }

    const SendConfig config{
        .message_count = MESSAGE_COUNT,
        .interval = INTERVAL,
        .type = MESSAGE_TYPE,
        .subtype = MESSAGE_SUBTYPE
    };

    const int sent_count = sender.sendMessages(config);

    std::cout << "Sender 2 completed (" << sent_count << "/"
              << MESSAGE_COUNT << " messages sent successfully)\n";

    return (sent_count == MESSAGE_COUNT) ? EXIT_SUCCESS : EXIT_FAILURE;
}
