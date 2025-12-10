<div align="center">

# Ring Action

![GitHub release (latest by date)](https://img.shields.io/github/v/release/ysdragon/ring-action)
![GitHub](https://img.shields.io/github/license/ysdragon/ring-action)

A GitHub Action that compiles [Ring](https://ring-lang.net/) Programming Language projects.
</div>

## Features

- Compile Ring source files
- Generate executable files using Ring2EXE
- Install packages from RingPM
- Flexible version management:
  - Linux/macOS: Build custom Ring versions from source
  - Windows: Pre-built Ring releases
- Fast and lightweight
- Cross-platform support (Windows, macOS, Linux)

## Platform & Architecture Support

| Platform | Architecture      | Supported | Notes                        |
|----------|------------------|-----------|------------------------------|
| Linux    | x86_64 / amd64   | ✅        | Full support                 |
| Linux    | arm64            | ✅        | Full support                 |
| Linux    | i386             | ❌        | Not supported                |
| Linux    | riscv64          | ❌        | Not supported                |
| Linux    | loongarch64      | ❌        | Not supported                |
| macOS    | Intel (x86_64)   | ✅        | Full support                 |
| macOS    | Apple Silicon    | ✅        | Full support      |
| Windows  | x86_64 / amd64   | ✅        | Pre-built binaries only      |
| Windows  | i386 / x86       | ✅        | Pre-built binaries only      |
| Windows  | arm64            | ❌        | Not supported                |

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `file` | ❌ | - | Path to the Ring source file to run/build |
| `command` | ❌ | - | Custom command to execute |
| `output_exe` | ❌ | `false` | Set to `true` to generate an executable using Ring2EXE |
| `args` | ❌ | - | Additional arguments to pass to Ring or Ring2EXE |
| `ring_packages` | ❌ | - | Space-separated list of packages to install from RingPM |
| `version` | ❌ | `v1.24` | Ring compiler version to use |
| `arch` | ❌ | `x64` | Target architecture for MSVC compiler on Windows (`x64`, `x86`, `arm64`) |
| `cache` | ❌ | `true` | Set to `false` to disable caching of the Ring installation |

## Usage Examples

### Simple example 
 
 ```yaml
 uses: ysdragon/ring-action@v1.3.2
 with:
   file: "program.ring"
 ```

### Execution command example

```yaml
uses: ysdragon/ring-action@v1.3.2
with:
  command: "ring program.ring"
```
 
 ### Linux

```yaml
name: Linux Build
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Linux executable
        uses: ysdragon/ring-action@v1.3.2
        with:
          file: "program.ring"
          output_exe: "true"
          args: "-static"
```

### macOS (Apple Silicon)

```yaml
name: macOS (Apple Silicon) Build
on: [push]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build macOS Intel app
        uses: ysdragon/ring-action@v1.3.2
        with:
          file: "program.ring"
          output_exe: "true"
```

### macOS (Intel)

```yaml
name: macOS (Intel) Build
on: [push]

jobs:
  build:
    runs-on: macos-13
    steps:
      - uses: actions/checkout@v4
      - name: Build macOS Intel app
        uses: ysdragon/ring-action@v1.3.2
        with:
          file: "program.ring"
          output_exe: "true"
```

### Windows

```yaml
name: Windows x64 Build
on: [push]

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Windows x64 executable
        uses: ysdragon/ring-action@v1.3.2
        with:
          file: "program.ring"
          output_exe: "true"
          args: "-static"
```

### Windows (32-bit)

```yaml
name: Windows x86 Build
on: [push]

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Windows x86 executable
        uses: ysdragon/ring-action@v1.3.2
        with:
          file: "program.ring"
          output_exe: "true"
          arch: "x86"
```

### Cross-Platform Build

```yaml
name: Cross-Platform Build
on: [push]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Build Ring project
        uses: ysdragon/ring-action@v1.3.2
        with:
          file: "program.ring"
          output_exe: "true"
```

## TODO
- [ ] Support FreeBSD
- [ ] Make the project a JavaScript Action

## License
This project is open source and available under the [MIT](https://github.com/ysdragon/ring-action/blob/main/LICENSE) License.