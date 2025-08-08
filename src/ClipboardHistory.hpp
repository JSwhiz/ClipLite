//
//  ClipboardHistory.hpp
//  ClipLite
//
//  Created by Дмитрий Крючков on 05.08.2025.
//

#pragma once
#include <vector>
#include <string>

struct ClipItem {
    std::string text;
    bool pinned = false;
};

class ClipboardHistory {
public:
    void add(const std::string& txt);
    const std::vector<ClipItem>& get() const;
    void pin(size_t idx);
    void unpin(size_t idx);
    void clear();
    void loadFromFile(const std::string& path);
    void saveToFile(const std::string& path);

private:
    std::vector<ClipItem> items_;
    static constexpr size_t MAX_SIZE = 20;
};
