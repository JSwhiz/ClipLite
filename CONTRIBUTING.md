# Вклад в ClipLite (RU)

Спасибо за интерес к проекту! Ниже — как собрать, предлагать изменения и оформлять PR.

## Сборка
- **Xcode:** откройте проект, у таргета Main Interface — пусто; запустите ⌘R.
- **CMake:** `mkdir build && cd build && cmake .. && make && open ClipLite.app`
- Требования: macOS 11+, Xcode 14+, Apple Silicon/Intel.

## Код-стайл
- C++17 и Obj-C/Obj-C++ (AppKit).
- Имена: `StatusController.mm`, `ClipboardHistory.{hpp,cpp}`.
- Минимум глобального состояния, без синглтонов.

## Коммиты / PR
- Коммиты: `feat:`, `fix:`, `chore:`, `docs:`.
- Один PR — одна задача; UI-изменения сопровождаем скрином/GIF.
- Обновляйте `CHANGELOG.md` (секция Unreleased) и ссылки в README при необходимости.

## Баги
- Заполните шаблон **Bug report** (шаги, ожидание/факт, версия macOS, логи/видео).

## Лицензия
Ваш вклад публикуется под MIT.

---

# Contributing to ClipLite (EN)

Thanks for your interest! Here is how to build and contribute.

## Build
- **Xcode:** open the project; `Main Interface` must be empty; run ⌘R.
- **CMake:** `mkdir build && cd build && cmake .. && make && open ClipLite.app`
- Requirements: macOS 11+, Xcode 14+, Apple Silicon/Intel.

## Code style
- C++17 + Obj-C/Obj-C++ (AppKit). Keep it simple, no heavy frameworks.

## Commits / PR
- Conventional-ish commits: `feat:`, `fix:`, `chore:`, `docs:`.
- One PR = one change; attach screenshots/GIF for UI changes.
- Update `CHANGELOG.md` (Unreleased) when applicable.

## Issues
- Please use **Bug report** / **Feature request** templates with repro steps and macOS version.

## License
MIT. By contributing you agree to license your contributions under MIT.
