// main.cpp
// Entry point for Sender A (Authorized Sender)
#include "message_sender.h"

#include <iostream>
#include <cstdlib>
#include <chrono>

namespace {
    constexpr const char* SENDER_ID = "SENDER1";
    constexpr const char* RECEIVER_NAME = "qnx_receiver_secure";

    // Sender A configuration
    constexpr int MESSAGE_COUNT = 10;
    constexpr auto INTERVAL = std::chrono::seconds(2);
    constexpr uint16_t MESSAGE_TYPE = 1;
    constexpr uint16_t MESSAGE_SUBTYPE = 100;
}

int main() {
    using namespace qnx::ipc;

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

    std::cout << "Sender 1 completed (" << sent_count << "/"
              << MESSAGE_COUNT << " messages sent successfully)\n";

    return (sent_count == MESSAGE_COUNT) ? EXIT_SUCCESS : EXIT_FAILURE;
}
