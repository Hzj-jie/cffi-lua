#include "util.hh"
#include <cstdio>

struct counted {
    static std::size_t moves;
    int value;
    counted(int v): value{v} {}
    counted(counted &&o): value{o.value} { ++moves; }
};
std::size_t counted::moves = 0;

int main() {
    util::vector<counted> v;
    for (int i = 0; i < 1000; ++i) {
        v.emplace_back(i);
    }
    for (int i = 0; i < 1000; ++i) {
        if (v[i].value != i) {
            std::fprintf(stderr, "v[%d] = %d\n", i, v[i].value);
            return 1;
        }
    }
    std::printf("moves for 1000 emplace_back: %zu\n", counted::moves);
    return (counted::moves < 2000) ? 0 : 1;
}
