// qnx_application.h
// QNX Application class - Header file
#ifndef QNX_APPLICATION_H
#define QNX_APPLICATION_H

#include <string>
#include <string_view>

namespace qnx {

/**
 * @brief Simple QNX application that displays system information
 */
class Application {
public:
    /**
     * @brief Construct a new Application object
     * @param name Application name to display
     */
    explicit Application(std::string_view name);

    // Prevent copying
    Application(const Application&) = delete;
    Application& operator=(const Application&) = delete;

    // Allow moving
    Application(Application&&) noexcept = default;
    Application& operator=(Application&&) noexcept = default;

    ~Application() = default;

    /**
     * @brief Run the application and display information
     */
    void run() const;

private:
    std::string app_name_;

    void displayHeader() const;
    void displaySystemInfo() const;
    void displayMessage() const;
};

} // namespace qnx

#endif // QNX_APPLICATION_H
