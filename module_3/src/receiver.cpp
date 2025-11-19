// src/receiver.cpp
#define _QNX_SOURCE
#include <sys/neutrino.h>
#include <sys/dispatch.h>
#include <unistd.h>
#include <iostream>
#include <string>
#include <cstring>
#include <cerrno>
#include <memory>

constexpr const char* RECEIVER_NAME = "/tmp/qnx_receiver";
constexpr size_t MAX_MESSAGE_SIZE = 256;

struct Message {
    uint16_t type;
    uint16_t subtype;
    char data[MAX_MESSAGE_SIZE];
};

class MessageReceiver {
public:
    MessageReceiver(const std::string& name) : name_(name), attach_(nullptr) {}

    ~MessageReceiver() {
        cleanup();
    }

    bool initialize() {
        std::cout << "===========================================\n";
        std::cout << "  QNX Message Receiver Started\n";
        std::cout << "===========================================\n";
        std::cout << "Process ID: " << getpid() << "\n";
        std::cout << "Attaching name: " << name_ << "\n";

        attach_ = name_attach(nullptr, name_.c_str(), 0);
        if (attach_ == nullptr) {
            std::cerr << "Error: Failed to attach name: "
                      << strerror(errno) << "\n";
            return false;
        }

        std::cout << "Channel created successfully (chid: "
                  << attach_->chid << ")\n";
        std::cout << "Waiting for messages...\n";
        std::cout << "===========================================\n\n";

        return true;
    }

    void run() {
        Message msg;
        int rcvid;

        while (true) {
            rcvid = MsgReceive(attach_->chid, &msg, sizeof(msg), nullptr);

            if (rcvid == -1) {
                std::cerr << "Error: MsgReceive failed: "
                          << strerror(errno) << "\n";
                break;
            }

            if (rcvid == 0) {
                // Pulse received
                handlePulse();
                continue;
            }

            // Regular message received
            handleMessage(rcvid, msg);
        }
    }

private:
    std::string name_;
    name_attach_t* attach_;

    void handlePulse() {
        std::cout << "[PULSE] Received\n";
    }

    void handleMessage(int rcvid, const Message& msg) {
        std::cout << "\n--- Message Received ---\n";
        std::cout << "From: rcvid " << rcvid << "\n";
        std::cout << "Type: " << msg.type << "\n";
        std::cout << "Subtype: " << msg.subtype << "\n";
        std::cout << "Data: " << msg.data << "\n";
        std::cout << "------------------------\n\n";

        // Reply to sender (acknowledge)
        int reply_status = 0;
        if (MsgReply(rcvid, reply_status, &reply_status, sizeof(reply_status)) == -1) {
            std::cerr << "Error: MsgReply failed: "
                      << strerror(errno) << "\n";
        }
    }

    void cleanup() {
        if (attach_ != nullptr) {
            name_detach(attach_, 0);
            attach_ = nullptr;
        }
    }
};

int main() {
    MessageReceiver receiver(RECEIVER_NAME);

    if (!receiver.initialize()) {
        return EXIT_FAILURE;
    }

    receiver.run();

    std::cout << "Receiver shutting down\n";
    return EXIT_SUCCESS;
}
