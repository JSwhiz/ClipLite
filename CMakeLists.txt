cmake_minimum_required(VERSION 3.12)
project(ClipLite LANGUAGES C CXX OBJCXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(${CMAKE_SOURCE_DIR}/include)

file(GLOB SRC src/*.cpp src/*.mm)
add_executable(${PROJECT_NAME} ${SRC})

find_library(COCOA Cocoa)
find_library(USERNOTIFICATIONS UserNotifications)

target_link_libraries(${PROJECT_NAME}
    PRIVATE ${COCOA} ${USERNOTIFICATIONS}
)
