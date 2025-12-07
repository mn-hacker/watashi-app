cmake_minimum_required(VERSION 3.10)

# This CMakeLists.txt is for the proxy_core Flutter plugin.
# Native libraries (.so files) should be pre-built and placed in jniLibs.
# The build is done via GitHub Actions or manually using build_android.sh script.

# Set the destination directory for JNI libraries
set(LibRoot "${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs")

# Check if pre-built libraries exist
if(EXISTS "${LibRoot}/arm64-v8a/libproxy_core.so")
    message(STATUS "Found pre-built ARM64 library at ${LibRoot}/arm64-v8a/libproxy_core.so")
else()
    message(WARNING "Pre-built ARM64 library not found. Run build_android.sh manually or via CI.")
endif()

if(EXISTS "${LibRoot}/x86_64/libproxy_core.so")
    message(STATUS "Found pre-built AMD64 library at ${LibRoot}/x86_64/libproxy_core.so")  
else()
    message(WARNING "Pre-built AMD64 library not found. Run build_android.sh manually or via CI.")
endif()

message(STATUS "JNI libraries should be at: ${LibRoot}")