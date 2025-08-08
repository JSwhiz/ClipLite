//
//  ClipboardHistory.cpp
//  ClipLite
//
//  Created by Дмитрий Крючков on 05.08.2025.
//

#include "ClipboardHistory.hpp"
#include <algorithm>
#include <fstream>
#include "nlohmann/json.hpp"
using json = nlohmann::json;

void ClipboardHistory::add(const std::string& txt) {
    if (txt.empty()) return;
    for (auto &it : items_) if (it.text == txt) return;
    items_.insert(items_.begin(), {txt,false});
    if (items_.size() > MAX_SIZE) items_.resize(MAX_SIZE);
}

const std::vector<ClipItem>& ClipboardHistory::get() const {
    return items_;
}

void ClipboardHistory::pin(size_t idx) {
    if (idx>=items_.size()) return;
    items_[idx].pinned = true;
}

void ClipboardHistory::unpin(size_t idx) {
    if (idx>=items_.size()) return;
    items_[idx].pinned = false;
}

void ClipboardHistory::clear() {
    items_.erase(
      std::remove_if(items_.begin(), items_.end(),
        [](auto &it){ return !it.pinned; }),
      items_.end()
    );
}

void ClipboardHistory::loadFromFile(const std::string& path) {
    std::ifstream in(path);
    if (!in) return;
    json j; in >> j;
    items_.clear();
    for (auto &e : j) {
        items_.push_back({
            e.at("text").get<std::string>(),
            e.at("pinned").get<bool>()
        });
    }
}

void ClipboardHistory::saveToFile(const std::string& path) {
    json j = json::array();
    for (auto &it : items_) {
        j.push_back({{"text", it.text}, {"pinned", it.pinned}});
    }
    std::ofstream out(path);
    out << j.dump(2);
}
