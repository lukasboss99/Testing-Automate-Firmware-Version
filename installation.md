# Automatic Git Versioning — Installation Guide

> Automatically increments the **patch version** on every commit and makes the version available as a C header for use in firmware, displays, logs, etc.

---

## Step 1 — Copy versioning files

Copy the following files/folders from this repository into the **root directory** of your destination repository:

| File / Folder | Purpose |
|---|---|
| `VERSION` | Stores the current version (`MAJOR.MINOR.PATCH`) |
| `.githooks/` | Contains the pre-commit hook for auto-increment |
| `scripts/` | Helper scripts to manually bump major/minor version |

## Step 2 — Set the initial version

Open the `VERSION` file and set your desired starting version:

```
0.0.1
```

## Step 3 — Activate the Git Hook

Run this command **once** inside the destination repository:

```bash
cd /path/to/your/project
git config core.hooksPath .githooks
```

> **Important:** Every developer who clones the repository must run this command once. Consider adding it to your README.

## Step 4 — Add the version header template

Copy the file `version.h.in` into your project's source directory (e.g. `main/`). This template is used by CMake to generate the actual `version.h` at build time.

The template provides:

```c
#define GIT_VERSION     "1.2.3-a1b2c3d"   // Full version string with git hash
#define VERSION_MAJOR   1                   // Individual components
#define VERSION_MINOR   2
#define VERSION_PATCH   3
```

## Step 5 — Add CMake integration

Add the following block to your `CMakeLists.txt` (in your `main/` or source folder):

```cmake
find_package(Git REQUIRED)

execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --show-toplevel
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_ROOT
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(EXISTS "${GIT_ROOT}/VERSION")
    file(READ "${GIT_ROOT}/VERSION" VERSION_RAW)
    string(STRIP "${VERSION_RAW}" PROJECT_VERSION_STR)
else()
    message(WARNING "VERSION file not found — using 0.0.0")
    set(PROJECT_VERSION_STR "0.0.0")
endif()

string(REPLACE "." ";" VERSION_LIST ${PROJECT_VERSION_STR})
list(GET VERSION_LIST 0 VERSION_MAJOR)
list(GET VERSION_LIST 1 VERSION_MINOR)
list(GET VERSION_LIST 2 VERSION_PATCH)

execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

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

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/version.h.in
    ${CMAKE_BINARY_DIR}/version.h
    @ONLY
)
```

> **ESP-IDF Note:** The generated `version.h` is placed in the `build/` directory. Make sure to include it in your component's `INCLUDE_DIRS`:
> ```cmake
> idf_component_register(SRCS "main.c"
>                     INCLUDE_DIRS "." "../build")
> ```

---

## Usage

### Daily workflow

| Action | Command |
|---|---|
| Normal commit (patch auto-increments) | `git add .` → `git commit -m "..."` |
| Bump **minor** version (middle number) | `./scripts/bump_version.sh minor` or `.\scripts\bump_version.ps1 minor` |
| Bump **major** version (left number) | `./scripts/bump_version.sh major` or `.\scripts\bump_version.ps1 major` |
| Skip auto-increment for one commit | `git commit --no-verify -m "..."` |

After a manual bump, commit with `--no-verify` to prevent double-incrementing:

```bash
./scripts/bump_version.sh minor
git add VERSION
git commit --no-verify -m "Bump version to X.Y.0"
```

### Using the version in code

```c
#include "version.h"

printf("Firmware v%d.%d.%d\n", VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH);
printf("Build: %s\n", GIT_VERSION);  // e.g. "1.2.3-a1b2c3d"
```