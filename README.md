
# ClipLite — быстрый и ненавязчивый менеджер буфера для macOS

[![Stars](https://img.shields.io/github/stars/JSwhiz/ClipLite?style=social)](https://github.com/JSwhiz/ClipLite)
[![Release](https://img.shields.io/github/v/release/JSwhiz/ClipLite)](https://github.com/JSwhiz/ClipLite/releases)
[![Build](https://img.shields.io/badge/build-Xcode-blue)](#сборка-из-исходников)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Лёгкий, нативный, приватный клипборд для macOS.  
**Pinned & History**, **Option-клик = Pin/Unpin**, хоткеи **⌘⌥1…9**.  
Без Electron, без телеметрии. C++17 + Cocoa (Obj-C++). Оптимизирован под Apple Silicon.

> English version below.

---

## Возможности

- **Pinned & History.** Две секции в одном компактном меню в строке меню.
- **Одна строка — одно действие.** Клик по записи → копирует в буфер + показывает системное уведомление.
- **Лаконичный Pin/Unpin.** Удерживайте **Option** и кликните по записи — закрепить/открепить. Закрепленные помечены **📌**.
- **Горячие клавиши истории.** При открытом меню работают **⌘⌥1…⌘⌥9** для первых девяти записей History (подсказка отображается справа у пункта).
- **Умная история.** Без дублей и самоповторов: «Clear All» не возвращает последний скопированный элемент.
- **Нативные уведомления macOS** (UserNotifications).
- **Приватность по умолчанию.** Все данные локально:  
  `~/Library/Application Support/ClipLite/history.json`.

---

## Установка

### DMG (рекомендуется)
1. Скачайте последний релиз: **[Releases](https://github.com/JSwhiz/ClipLite/releases)**.  
2. Откройте DMG и перетащите `ClipLite.app` в «Программы».

### Homebrew (когда cask будет опубликован)
```bash
brew install --cask cliplite
````

---

## Использование

* Нажмите на иконку **📋** в строке меню — увидите **Pinned** и **History**.
* **Клик** по строке — скопирует запись в буфер обмена.
* **Option + клик** — мгновенно **Pin/Unpin** этой записи (без стрелочек и подменю).
* **⌘⌥1…⌘⌥9** (когда меню открыто) — копируют соответствующие пункты из **History**.
* **Clear All** — очищает только History; закреплённые пункты не трогаются.

Длинные строки аккуратно **обрезаются до 30 символов**; полный текст виден в **toolTip** при наведении.

---

## Сборка из исходников

### Xcode

1. Откройте проект в Xcode.
2. В таргете **Main Interface** — пусто; в Info.plist **нет** ключей `NSMainStoryboardFile`/`NSMainNibFile`.
3. Запустите: **⌘R** (Scheme: `ClipLite`, конфигурация **Release** для продакшена).

### CMake

```bash
mkdir build && cd build
cmake ..
make
open ClipLite.app
```

**Требования:** macOS 11+, Xcode 14+, Apple Silicon/Intel.

---

## Приватность

* Данные хранятся **только локально**: `~/Library/Application Support/ClipLite/history.json`.
* Никаких сетевых запросов, аккаунтов, аналитики и телеметрии.

---

## Roadmap & Changelog

* 📍 **[Roadmap](ROADMAP.md)** — ближайшие планы (поиск в меню, автозапуск, настройки и пр.).
* 📝 **[Changelog](CHANGELOG.md)** — история изменений (SemVer, Keep a Changelog).

---

## Сравнение с альтернативами

* **Paste** — мощный и облачный, но тяжелее и платный.
* **Maccy** — быстрый open-source, спартанский UI.
* **Pastebot** — функционален, но перегружен для базовых задач.
* **Raycast Clipboard** — удобно, если вы уже живёте в Raycast (тянет лаунчер).

**ClipLite** — нативный, лёгкий, минималистичный. Всё локально и под вашим контролем.

---

## FAQ

**Почему хоткеи работают только при открытом меню?**
Так устроен AppKit: `keyEquivalent` активен в контексте открытого меню — мы не перехватываем глобальные системные сочетания.

**Почему «последний скопированный» иногда появляется снова после очистки?**
Если значение остаётся в системном буфере macOS, ОС может вернуть его при следующем опросе. ClipLite игнорирует только собственные копирования и точные повторы через `_ignoreNextClipboard` и `_lastClipboard`.

**Поддерживаются изображения/RTF?**
Сейчас — текст (`NSPasteboardTypeString`). Поддержка RTF/изображений в дорожной карте.

---

## Контрибьюция / Безопасность / Лицензия

* 🤝 **[CONTRIBUTING.md](CONTRIBUTING.md)** — как собрать и отправить PR.
* 🔐 **[SECURITY.md](SECURITY.md)** — как сообщить о проблеме безопасности.
* 📜 **[MIT License](LICENSE)** — свободно используйте и форкайте.

---

## Credits

* JSON: **[nlohmann/json](https://github.com/nlohmann/json)**
* Иконки SF Symbols (macOS 11+)

---

---

# ClipLite — fast & minimal macOS clipboard manager (EN)

Native AppKit. Pins & History, **Option-click** for Pin/Unpin, **⌘⌥1…9** for quick copy.
No telemetry. Apple Silicon optimized.

## Features

* **Pinned & History** sections in a compact menu bar app.
* **One row = one action.** Click → copy + macOS notification.
* **Option-click** → instant Pin/Unpin (no submenus or extra rows).
* **⌘⌥1…⌘⌥9** for the first nine History items (shown on the right).
* Smart deduplication and safe “Clear All”. Local JSON storage.

## Install

* **DMG:** see **[Releases](https://github.com/JSwhiz/ClipLite/releases)**
* **Homebrew:** `brew install --cask cliplite` *(coming soon)*

## Build

* **Xcode:** no storyboard; run ⌘R (Release for production).
* **CMake:** `mkdir build && cd build && cmake .. && make && open ClipLite.app`
  Requires macOS 11+, Xcode 14+, Apple Silicon/Intel.

## Privacy

Stored locally at `~/Library/Application Support/ClipLite/history.json`. No network calls.

## Roadmap & Changelog

* [Roadmap](ROADMAP.md) • [Changelog](CHANGELOG.md)

## Contributing / Security / License

* [CONTRIBUTING.md](CONTRIBUTING.md) • [SECURITY.md](SECURITY.md) • [MIT](LICENSE)
