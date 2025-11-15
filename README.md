# My precious dotfiles

## Installation

`curl -fsSL thekauer.vercel.app/setup | bash`

## Testing

1. Install Tart

```
brew install cirruslabs/cli/tart
tart clone ghcr.io/cirruslabs/macos-tahoe-base:latest tahoe-base
tart run tahoe-base
```

2. Tart will create a new window (might be minimized by default). Create a password and go through initial setup steps. STOP before installing anything

3. `tart stop tahoe-base`

4. `tart clone tahoe-base test1` you might need to add `--net-bridged=en0` to get internet connection

5. `tart run test1`

6. In the terminal app run `sudo curl -fsSL thekauer.vercel.app/setup | bash`
