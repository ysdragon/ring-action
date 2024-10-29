# Ring Action

An experimental GitHub Action that compiles a Ring project.

## Inputs

### `file` (required)
- **Description**: The path to the Ring file to build.

### `output_exe` (optional)
- **Description**: This can be set to 'true' to use Ring2EXE *(to output an executable file)*.
- **Default**: `false`

### `args` (optional)
- **Description**: Additional arguments to pass to Ring or Ring2EXE if `output_exe` is set to 'true'.

### `ring_packages` (optional)
- **Description**: Specifies the packages to install from RingPM.

### `version` (optional)
- **Description**: Specifies the version of the Ring compiler to use. This can be any valid reference for `git checkout`, such as a commit hash, tag, or branch.
- **Default**: `v1.21.2` *(Latest release)*

## Example Usage

Here’s an example of how to use this action in your workflow:

```yaml
uses: ysdragon/ring-action@v1.0.1
with:
  file: "program.ring"
```