# Router

Message routing library for MessagingService on Roblox. Uses the [Cross-server Routing Protocol](https://www.github.com/tenx29/roblox-csrp) specification to route messages between servers.

## Installation

### Studio

1. Download the latest version of Router from the [releases page](https://www.github.com/tenx29/router/releases).
2. Insert the downloaded model into `ServerScriptService`.

### Rojo & Wally (Recommended)

1. Make sure both [Rojo](https://rojo.space/) and [Wally](https://wally.run/) are installed.
2. Add Router to the `wally.toml` file in your project's root directory:

    ```toml
    [dependencies]
    name = "tenx29/router@^0.1.0"
    ```

3. Run `wally install`.

## Building from source

For building the library as an RBXM file, you will need to use [Rojo](https://rojo.space/) with the `default.project.json` file. This will build only the Router library as a model.

The `test.project.json` file is provided for testing purposes, and will build a place file with the Router library and a unit testing module.

## Documentation

Documentation for the library can be found on the [GitHub Pages site](https://tenx29.github.io/router/).
