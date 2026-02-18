idf_component_register(SRCS "main.c"
                    INCLUDE_DIRS "."
                    "../build")

# =============================================================================
# Automatic Version from VERSION file + Git metadata
# =============================================================================
# The VERSION file (in the git repo root) is the single source of truth.
# It is auto-incremented (patch) by the pre-commit hook on every commit.
# =============================================================================

find_package(Git REQUIRED)

# Find the git repo root (where VERSION file lives)
execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --show-toplevel
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_ROOT
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Read version from VERSION file
if(EXISTS "${GIT_ROOT}/VERSION")
    file(READ "${GIT_ROOT}/VERSION" VERSION_RAW)
    string(STRIP "${VERSION_RAW}" PROJECT_VERSION_STR)
else()
    message(WARNING "VERSION file not found at ${GIT_ROOT}/VERSION — using 0.0.0")
    set(PROJECT_VERSION_STR "0.0.0")
endif()

# Parse version components
string(REPLACE "." ";" VERSION_LIST ${PROJECT_VERSION_STR})
list(GET VERSION_LIST 0 VERSION_MAJOR)
list(GET VERSION_LIST 1 VERSION_MINOR)
list(GET VERSION_LIST 2 VERSION_PATCH)

# Get short git hash
execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Check for uncommitted changes (dirty flag)
execute_process(
    COMMAND ${GIT_EXECUTABLE} diff --quiet
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE GIT_DIRTY
)

if(GIT_DIRTY)
    set(GIT_VERSION "${PROJECT_VERSION_STR}-${GIT_HASH}+dirty")
else()
    set(GIT_VERSION "${PROJECT_VERSION_STR}-${GIT_HASH}")
endif()

message(STATUS "Build version: ${GIT_VERSION}")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/version.h.in ${CMAKE_BINARY_DIR}/version.h @ONLY)