// secure_message_receiver.h
// Secure Message Receiver with security policy enforcement - Header
#ifndef SECURE_MESSAGE_RECEIVER_H
#define SECURE_MESSAGE_RECEIVER_H

#include "message.h"

#include <string>
#include <string_view>
#include <memory>
#include <optional>

// Forward declaration for QNX types
struct _name_attach;
typedef struct _name_attach name_attach_t;

namespace qnx::ipc {

/**
 * @brief Custom deleter for name_attach_t resource
 *
 * Implements RAII for QNX name attachment using unique_ptr
 */
struct NameAttachDeleter {
    void operator()(name_attach_t* attach) const noexcept;
};

using NameAttachPtr = std::unique_ptr<name_attach_t, NameAttachDeleter>;

/**
 * @brief Secure message receiver with security policy enforcement
 *
 * Uses C++17 features:
 * - std::unique_ptr for resource management
 * - std::optional for safer return values
 * - std::string_view for efficient string passing
 */
class SecureMessageReceiver {
public:
    /**
     * @brief Construct a new Secure Message Receiver
     * @param name Channel name to attach to
     */
    explicit SecureMessageReceiver(std::string_view name);

    // Prevent copying
    SecureMessageReceiver(const SecureMessageReceiver&) = delete;
    SecureMessageReceiver& operator=(const SecureMessageReceiver&) = delete;

    // Allow moving
    SecureMessageReceiver(SecureMessageReceiver&&) noexcept = default;
    SecureMessageReceiver& operator=(SecureMessageReceiver&&) noexcept = default;

    ~SecureMessageReceiver() = default;

    /**
     * @brief Initialize the receiver and create the channel
     * @return true if successful, false otherwise
     */
    bool initialize();

    /**
     * @brief Run the receiver main loop
     */
    void run();

    /**
     * @brief Get the channel ID
     * @return Channel ID if initialized, std::nullopt otherwise
     */
    [[nodiscard]] std::optional<int> getChannelId() const noexcept;

private:
    std::string name_;
    NameAttachPtr attach_;

    void displayStartupInfo() const;
    void handleAuthorizedMessage(int rcvid, const Message& msg);
    void handleSecurityViolation(int error_code);
    [[nodiscard]] bool isSecurityError(int error_code) const noexcept;
};

} // namespace qnx::ipc

#endif // SECURE_MESSAGE_RECEIVER_H
