// message_sender.cpp
// Message Sender - Implementation
#include "message_sender.h"
#include "message.h"

#include <iostream>
#include <cstring>
#include <cerrno>
#include <unistd.h>
#include <thread>
#include <sys/neutrino.h>
#include <sys/dispatch.h>

namespace qnx::ipc {

// ConnectionGuard implementation
ConnectionGuard::ConnectionGuard(int coid) noexcept
    : coid_(coid) {}

ConnectionGuard::~ConnectionGuard() noexcept {
    if (coid_ != -1) {
        name_close(coid_);
    }
}

ConnectionGuard::ConnectionGuard(ConnectionGuard&& other) noexcept
    : coid_(other.coid_) {
    other.coid_ = -1;
}

ConnectionGuard& ConnectionGuard::operator=(ConnectionGuard&& other) noexcept {
    if (this != &other) {
        if (coid_ != -1) {
            name_close(coid_);
        }
        coid_ = other.coid_;
        other.coid_ = -1;
    }
    return *this;
}

// MessageSender implementation
MessageSender::MessageSender(std::string_view sender_id,
                             std::string_view receiver_name)
    : sender_id_(sender_id),
      receiver_name_(receiver_name),
      connection_(std::nullopt) {}

bool MessageSender::connect(int max_attempts,
                            std::chrono::seconds retry_delay) {
    displayStartupInfo();

    for (int attempt = 0; attempt < max_attempts; ++attempt) {
        if (auto coid = attemptConnection(); coid.has_value()) {
            connection_ = ConnectionGuard(*coid);
            std::cout << "Connected successfully (coid: "
                      << connection_->get() << ")\n";
            std::cout << "===========================================\n\n";
            return true;
        }

        if (attempt < max_attempts - 1) {
            std::cout << "Connection attempt " << (attempt + 1)
                      << " failed, retrying...\n";
            std::this_thread::sleep_for(retry_delay);
        }
    }

    std::cerr << "Error: Cannot connect to receiver after "
              << max_attempts << " attempts\n";
    std::cerr << "Make sure receiver is running first!\n";
    return false;
}

int MessageSender::sendMessages(const SendConfig& config) {
    if (!isConnected()) {
        std::cerr << "Error: Not connected to receiver\n";
        return 0;
    }

    int successful_sends = 0;

    for (int i = 1; i <= config.message_count; ++i) {
        Message msg{};
        msg.type = config.type;
        msg.subtype = config.subtype;

        std::snprintf(msg.data.data(), msg.data.size(),
                     "Hello from %s - Message #%d",
                     sender_id_.c_str(), i);

        std::cout << "[" << sender_id_ << "] Sending message #"
                  << i << ": " << msg.data.data() << "\n";

        int reply_status;
        if (sendSingleMessage(msg, reply_status)) {
            std::cout << "[" << sender_id_ << "] Reply received: "
                      << reply_status << "\n\n";
            ++successful_sends;
        } else {
            break;
        }

        if (i < config.message_count) {
            std::this_thread::sleep_for(config.interval);
        }
    }

    return successful_sends;
}

bool MessageSender::isConnected() const noexcept {
    return connection_.has_value() && connection_->isValid();
}

void MessageSender::displayStartupInfo() const {
    std::cout << "===========================================\n"
              << "  " << sender_id_ << " Started\n"
              << "===========================================\n"
              << "Process ID: " << getpid() << "\n"
              << "Connecting to: " << receiver_name_ << "\n";
}

std::optional<int> MessageSender::attemptConnection() {
    const int coid = name_open(receiver_name_.c_str(), 0);
    if (coid != -1) {
        return coid;
    }
    return std::nullopt;
}

bool MessageSender::sendSingleMessage(const Message& msg, int& reply_status) {
    if (!isConnected()) {
        return false;
    }

    if (MsgSend(connection_->get(), &msg, sizeof(msg),
                &reply_status, sizeof(reply_status)) == -1) {
        std::cerr << "Error: MsgSend failed: "
                  << std::strerror(errno) << "\n";
        return false;
    }

    return true;
}

} // namespace qnx::ipc
