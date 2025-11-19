#define _QNX_SOURCE
#include <sys/dispatch.h>
// module_4/src/sender2_secure.cpp
// Unauthorized sender - will be blocked by security policy
#include <iostream>
#include <string>
#include <cstring>
#include <cerrno>
#include <unistd.h>
#include <sys/neutrino.h>

constexpr const char* RECEIVER_NAME = "/tmp/qnx_receiver_secure";
constexpr size_t MAX_MESSAGE_SIZE = 256;

struct Message {
    uint16_t type;
    uint16_t subtype;
    char data[MAX_MESSAGE_SIZE];
};

class MessageSender {
public:
    MessageSender(const std::string& sender_id, const std::string& receiver_name)
        : sender_id_(sender_id), receiver_name_(receiver_name), coid_(-1) {}

    ~MessageSender() {
        cleanup();
    }

    bool connect() {
        std::cout << "===========================================\n";
        std::cout << "  " << sender_id_ << " Started\n";
        std::cout << "===========================================\n";
        std::cout << "Process ID: " << getpid() << "\n";
        std::cout << "Connecting to: " << receiver_name_ << "\n";

        // Wait a bit before connecting
        sleep(1);

        // Try to connect to receiver
        for (int attempts = 0; attempts < 5; attempts++) {
            coid_ = name_open(receiver_name_.c_str(), 0);
            if (coid_ != -1) break;

            std::cout << "Connection attempt " << (attempts + 1)
                      << " failed, retrying...\n";
            sleep(1);
        }

        if (coid_ == -1) {
            std::cerr << "Error: Cannot connect to receiver: "
                      << strerror(errno) << "\n";
            std::cerr << "Make sure receiver is running first!\n";
            return false;
        }

        std::cout << "Connected successfully (coid: " << coid_ << ")\n";
        std::cout << "Sending messages every 3 seconds...\n";
        std::cout << "===========================================\n\n";

        return true;
    }

    void sendMessages(int count, int interval_seconds,
                      uint16_t type, uint16_t subtype) {
        for (int i = 1; i <= count; i++) {
            Message msg;
            msg.type = type;
            msg.subtype = subtype;
            snprintf(msg.data, MAX_MESSAGE_SIZE,
                     "Greetings from %s - Message #%d",
                     sender_id_.c_str(), i);

            std::cout << "[" << sender_id_ << "] Sending message #"
                      << i << ": " << msg.data << "\n";

            int reply_status;
            if (MsgSend(coid_, &msg, sizeof(msg),
                        &reply_status, sizeof(reply_status)) == -1) {
                std::cerr << "Error: MsgSend failed: "
                          << strerror(errno) << "\n";
                break;
            }

            std::cout << "[" << sender_id_ << "] Reply received: "
                      << reply_status << "\n\n";

            if (i < count) {
                sleep(interval_seconds);
            }
        }
    }

private:
    std::string sender_id_;
    std::string receiver_name_;
    int coid_;

    void cleanup() {
        if (coid_ != -1) {
            name_close(coid_);
            coid_ = -1;
        }
    }
};

int main() {
    MessageSender sender("SENDER2", RECEIVER_NAME);

    if (!sender.connect()) {
        return EXIT_FAILURE;
    }

    sender.sendMessages(7, 3, 2, 200);

    std::cout << "Sender 2 completed\n";
    return EXIT_SUCCESS;
}
