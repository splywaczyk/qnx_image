// secure_message_receiver.cpp
// Secure Message Receiver - Implementation
#include "secure_message_receiver.h"

#include <iostream>
#include <cstring>
#include <cerrno>
#include <unistd.h>
#include <sys/neutrino.h>
#include <sys/dispatch.h>

namespace qnx::ipc {

// NameAttachDeleter implementation
void NameAttachDeleter::operator()(name_attach_t* attach) const noexcept {
    if (attach != nullptr) {
        name_detach(attach, 0);
    }
}

// SecureMessageReceiver implementation
SecureMessageReceiver::SecureMessageReceiver(std::string_view name)
    : name_(name), attach_(nullptr) {}

bool SecureMessageReceiver::initialize() {
    displayStartupInfo();

    // Use raw pointer temporarily, then wrap in unique_ptr
    name_attach_t* raw_attach = name_attach(nullptr, name_.c_str(), 0);
    if (raw_attach == nullptr) {
        std::cerr << "Error: Failed to attach name: "
                  << std::strerror(errno) << "\n";
        return false;
    }

    // Transfer ownership to unique_ptr
    attach_ = NameAttachPtr(raw_attach);

    std::cout << "Secure channel created (chid: "
              << attach_->chid << ")\n";
    std::cout << "Security policy active\n";
    std::cout << "Waiting for authorized messages...\n";
    std::cout << "===========================================\n\n";

    return true;
}

void SecureMessageReceiver::run() {
    if (!attach_) {
        std::cerr << "Error: Receiver not initialized\n";
        return;
    }

    Message msg{};
    int rcvid;

    while (true) {
        rcvid = MsgReceive(attach_->chid, &msg, sizeof(msg), nullptr);

        if (rcvid == -1) {
            if (isSecurityError(errno)) {
                handleSecurityViolation(errno);
                continue;
            }

            std::cerr << "Error: MsgReceive failed: "
                      << std::strerror(errno) << "\n";
            break;
        }

        if (rcvid == 0) {
            // Pulse received - ignore for now
            continue;
        }

        // Message successfully received from authorized sender
        handleAuthorizedMessage(rcvid, msg);
    }
}

std::optional<int> SecureMessageReceiver::getChannelId() const noexcept {
    if (attach_) {
        return attach_->chid;
    }
    return std::nullopt;
}

void SecureMessageReceiver::displayStartupInfo() const {
    std::cout << "===========================================\n"
              << "  QNX Secure Message Receiver\n"
              << "===========================================\n"
              << "Process ID: " << getpid() << "\n"
              << "Attaching name: " << name_ << "\n"
              << "Security: ENABLED (secpol enforced)\n"
              << "Authorized: sender1 only\n";
}

void SecureMessageReceiver::handleAuthorizedMessage(int rcvid, const Message& msg) {
    std::cout << "\n--- Authorized Message Received ---\n"
              << "From: rcvid " << rcvid << " (AUTHORIZED by secpol)\n"
              << "Type: " << msg.type << "\n"
              << "Subtype: " << msg.subtype << "\n"
              << "Data: " << msg.data.data() << "\n"
              << "-----------------------------------\n\n";

    // Send reply
    constexpr int reply_status = 0;
    MsgReply(rcvid, reply_status, &reply_status, sizeof(reply_status));
}

void SecureMessageReceiver::handleSecurityViolation(int error_code) {
    std::cout << "\n[SECURITY POLICY VIOLATION]\n"
              << "===========================\n"
              << "Unauthorized access blocked by secpol!\n"
              << "errno: " << error_code << " ("
              << std::strerror(error_code) << ")\n"
              << "===========================\n\n";
}

bool SecureMessageReceiver::isSecurityError(int error_code) const noexcept {
    return (error_code == EACCES || error_code == EPERM);
}

} // namespace qnx::ipc
