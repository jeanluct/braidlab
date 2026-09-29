#ifndef TRAINS_TEST_UTIL_H
#define TRAINS_TEST_UTIL_H

#include <cmath>
#include <sstream>
#include <stdexcept>
#include <string>

#define CHECK_TRUE(expr)                                                         \
    do {                                                                         \
        if (!(expr)) {                                                           \
            std::ostringstream _oss;                                             \
            _oss << "Check failed: " #expr << " at " << __FILE__ << ":"      \
                 << __LINE__;                                                    \
            throw std::runtime_error(_oss.str());                               \
        }                                                                        \
    } while (0)

#define CHECK_EQ(lhs, rhs)                                                       \
    do {                                                                         \
        const auto _lhs = (lhs);                                                 \
        const auto _rhs = (rhs);                                                 \
        if (!(_lhs == _rhs)) {                                                   \
            std::ostringstream _oss;                                             \
            _oss << "Check failed: " #lhs " == " #rhs << " (" << _lhs         \
                 << " vs " << _rhs << ") at " << __FILE__ << ":"              \
                 << __LINE__;                                                    \
            throw std::runtime_error(_oss.str());                               \
        }                                                                        \
    } while (0)

inline void check_close(long double a, long double b, long double eps,
                        const char* what, const char* file, int line) {
    if (std::fabs(a - b) > eps) {
        std::ostringstream oss;
        oss << "Check failed: " << what << " (" << a << " vs " << b
            << ", eps=" << eps << ") at " << file << ":" << line;
        throw std::runtime_error(oss.str());
    }
}

#define CHECK_CLOSE(a, b, eps) check_close((a), (b), (eps), #a " ~= " #b, __FILE__, __LINE__)

#endif
