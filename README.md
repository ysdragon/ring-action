# Ring Action

![GitHub release (latest by date)](https://img.shields.io/github/v/release/ysdragon/ring-action)
![GitHub](https://img.shields.io/github/license/ysdragon/ring-action)

A GitHub Action that compiles [Ring](https://ring-lang.net/) Programming Language projects.
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

| Platform | Architecture | Supported | Notes |
|----------|--------------|-----------|--------|
| Linux | x64 | ✅ | Full support |
| Linux | x86 | ❌ | Not supported |
| Linux | ARM64 | ❌ | Not supported |
| macOS | Intel | ✅ | Full support |
| macOS | Apple Silicon | ❌ | Not supported |
| Windows | x64 | ✅ | Pre-built binaries only |
| Windows | x86 | ❌ | Not supported |
| Windows | ARM64 | ❌ | Not supported |

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `file` | ✅ | - | Path to the Ring source file to build |
| `output_exe` | ❌ | `false` | Set to `true` to generate an executable using Ring2EXE |
| `args` | ❌ | - | Additional arguments to pass to Ring or Ring2EXE |
| `ring_packages` | ❌ | - | Space-separated list of packages to install from RingPM |
| `version` | ❌ | `v1.21.2` | Ring compiler version to use |

## Usage Examples

### Simple example 

```yaml
uses: ysdragon/ring-action@v1.0.3
with:
  file: "program.ring"
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
        uses: ysdragon/ring-action@v1.0.3
        with:
          file: "program.ring"
          output_exe: "true"
          args: "-static"
```

### macOS

```yaml
name: macOS Intel Build
on: [push]

jobs:
  build:
    runs-on: macos-12
    steps:
      - uses: actions/checkout@v4
      - name: Build macOS Intel app
        uses: ysdragon/ring-action@v1.0.3
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
        uses: ysdragon/ring-action@v1.0.3
        with:
          file: "program.ring"
          output_exe: "true"
          args: "-static"
```

### Cross-Platform Build

```yaml
name: Cross-Platform Build
on: [push]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-12]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Build Ring project
        uses: ysdragon/ring-action@v1.0.3
        with:
          file: "program.ring"
          output_exe: "true"
```

## License
This project is open source and available under the [MIT](https://github.com/ysdragon/ring-action/blob/main/LICENSE) License.