// message_sender.h
// Message Sender for IPC communication - Header
#ifndef MESSAGE_SENDER_H
#define MESSAGE_SENDER_H

#include <string>
#include <string_view>
#include <optional>
#include <chrono>

namespace qnx::ipc {

// Forward declaration
struct Message;

/**
 * @brief Configuration for message sending
 */
struct SendConfig {
    int message_count;
    std::chrono::seconds interval;
    uint16_t type;
    uint16_t subtype;
};

/**
 * @brief RAII wrapper for QNX connection ID
 *
 * Automatically closes the connection when destroyed
 */
class ConnectionGuard {
public:
    explicit ConnectionGuard(int coid) noexcept;
    ~ConnectionGuard() noexcept;

    // Prevent copying
    ConnectionGuard(const ConnectionGuard&) = delete;
    ConnectionGuard& operator=(const ConnectionGuard&) = delete;

    // Allow moving
    ConnectionGuard(ConnectionGuard&& other) noexcept;
    ConnectionGuard& operator=(ConnectionGuard&& other) noexcept;

    [[nodiscard]] int get() const noexcept { return coid_; }
    [[nodiscard]] bool isValid() const noexcept { return coid_ != -1; }

private:
    int coid_;
};

/**
 * @brief Message sender with connection management
 *
 * Uses C++17 features:
 * - std::optional for safer return values
 * - std::string_view for efficient string passing
 * - std::chrono for time management
 * - RAII for connection management
 */
class MessageSender {
public:
    /**
     * @brief Construct a new Message Sender
     * @param sender_id Identifier for this sender
     * @param receiver_name Name of the receiver to connect to
     */
    MessageSender(std::string_view sender_id, std::string_view receiver_name);

    // Prevent copying
    MessageSender(const MessageSender&) = delete;
    MessageSender& operator=(const MessageSender&) = delete;

    // Allow moving
    MessageSender(MessageSender&&) noexcept = default;
    MessageSender& operator=(MessageSender&&) noexcept = default;

    ~MessageSender() = default;

    /**
     * @brief Connect to the receiver
     * @param max_attempts Maximum connection attempts
     * @param retry_delay Delay between retries
     * @return true if connected successfully
     */
    bool connect(int max_attempts = 5,
                 std::chrono::seconds retry_delay = std::chrono::seconds(1));

    /**
     * @brief Send messages according to configuration
     * @param config Message sending configuration
     * @return Number of successfully sent messages
     */
    int sendMessages(const SendConfig& config);

    /**
     * @brief Check if sender is connected
     * @return true if connected
     */
    [[nodiscard]] bool isConnected() const noexcept;

private:
    std::string sender_id_;
    std::string receiver_name_;
    std::optional<ConnectionGuard> connection_;

    void displayStartupInfo() const;
    [[nodiscard]] std::optional<int> attemptConnection();
    [[nodiscard]] bool sendSingleMessage(const Message& msg, int& reply_status);
};

} // namespace qnx::ipc

#endif // MESSAGE_SENDER_H
