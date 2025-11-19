#define _QNX_SOURCE
// module_4/src/receiver_secure.cpp
// Secure MessageReceiver with security policy enforcement
#include <iostream>
#include <string>
#include <cstring>
#include <cerrno>
#include <unistd.h>
#include <sys/neutrino.h>
#include <sys/dispatch.h>

constexpr const char* RECEIVER_NAME = "/tmp/qnx_receiver_secure";
constexpr size_t MAX_MESSAGE_SIZE = 256;

struct Message {
    uint16_t type;
    uint16_t subtype;
    char data[MAX_MESSAGE_SIZE];
};

class SecureMessageReceiver {
public:
    SecureMessageReceiver(const std::string& name)
        : name_(name), attach_(nullptr) {}

    ~SecureMessageReceiver() {
        cleanup();
    }

    bool initialize() {
        std::cout << "===========================================\n";
        std::cout << "  QNX Secure Message Receiver\n";
        std::cout << "===========================================\n";
        std::cout << "Process ID: " << getpid() << "\n";
        std::cout << "Attaching name: " << name_ << "\n";
        std::cout << "Security: ENABLED (secpol enforced)\n";
        std::cout << "Authorized: sender1 only\n";

        attach_ = name_attach(nullptr, name_.c_str(), 0);
        if (attach_ == nullptr) {
            std::cerr << "Error: Failed to attach name: "
                      << strerror(errno) << "\n";
            return false;
        }

        std::cout << "Secure channel created (chid: "
                  << attach_->chid << ")\n";
        std::cout << "Security policy active\n";
        std::cout << "Waiting for authorized messages...\n";
        std::cout << "===========================================\n\n";

        return true;
    }

    void run() {
        Message msg;
        int rcvid;

        while (true) {
            rcvid = MsgReceive(attach_->chid, &msg, sizeof(msg), nullptr);

            if (rcvid == -1) {
                // Security policy may have blocked the message
                if (errno == EACCES || errno == EPERM) {
                    std::cout << "\n[SECURITY POLICY VIOLATION]\n";
                    std::cout << "===========================\n";
                    std::cout << "Unauthorized access blocked by secpol!\n";
                    std::cout << "errno: " << errno << " ("
                              << strerror(errno) << ")\n";
                    std::cout << "===========================\n\n";
                    continue;
                }

                std::cerr << "Error: MsgReceive failed: "
                          << strerror(errno) << "\n";
                break;
            }

            if (rcvid == 0) {
                // Pulse received
                continue;
            }

            // Message successfully received (from authorized sender)
            handleAuthorizedMessage(rcvid, msg);
        }
    }

private:
    std::string name_;
    name_attach_t* attach_;

    void handleAuthorizedMessage(int rcvid, const Message& msg) {
        std::cout << "\n--- Authorized Message Received ---\n";
        std::cout << "From: rcvid " << rcvid << " (AUTHORIZED by secpol)\n";
        std::cout << "Type: " << msg.type << "\n";
        std::cout << "Subtype: " << msg.subtype << "\n";
        std::cout << "Data: " << msg.data << "\n";
        std::cout << "-----------------------------------\n\n";

        // Reply
        int reply_status = 0;
        MsgReply(rcvid, reply_status, &reply_status, sizeof(reply_status));
    }

    void cleanup() {
        if (attach_ != nullptr) {
            name_detach(attach_, 0);
            attach_ = nullptr;
        }
    }
};

int main() {
    SecureMessageReceiver receiver(RECEIVER_NAME);

    if (!receiver.initialize()) {
        return EXIT_FAILURE;
    }

    receiver.run();

    std::cout << "Secure receiver shutting down\n";
    return EXIT_SUCCESS;
}
