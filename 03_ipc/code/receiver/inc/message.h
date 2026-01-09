// message.h
// Message structure for IPC communication
#ifndef MESSAGE_H
#define MESSAGE_H

#include <cstdint>
#include <array>

namespace qnx::ipc {

constexpr size_t MAX_MESSAGE_SIZE = 256;

/**
 * @brief Message structure for inter-process communication
 */
struct Message {
    uint16_t type;
    uint16_t subtype;
    std::array<char, MAX_MESSAGE_SIZE> data;

    Message() : type(0), subtype(0), data{} {}
};

} // namespace qnx::ipc

#endif // MESSAGE_H
