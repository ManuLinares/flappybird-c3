# Flappy Bird in C3

A simple clone of Flappy Bird written in the C3 programming language, using Raylib

## Prerequisites

- [C3 Compiler](https://c3-lang.org/) (`c3c`)
- Python 3 (for Windows cross-compilation)

## Building

The project can be built for Linux and Windows.

### Linux

To build the executable for Linux, run the following command in the project root:

```sh
c3c build
```

This will create an executable at `build/flappybird`.

### Windows (Cross-compilation)

Building for Windows from a non-Windows OS (or on Windows without Visual Studio) requires parts of the MSVC toolchain and Windows SDK. A helper script is provided to download and set up the necessary files.

1.  **Download the SDK:**

    Run the Python script to download the required libraries into an `msvc_sdk` directory.

    ```sh
    python3 msvc_build_libraries.py --accept-license
    ```

2.  **Build the executable:**

    Once the `msvc_sdk` directory is present, you can build the Windows executable:

    ```sh
    c3c build flappybird-win
    ```

    This will create an executable at `build/flappybird-win.exe`.
