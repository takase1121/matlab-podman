# matlab-podman

MATLAB + podman because life is tough without Ubuntu.

Getting MATLAB to run on Linux is non-trivial.
[Arch wiki][1] has quite a long article on it.
Luckily, Mathworks provide a [container][2] based on Ubuntu 20.04.
The container provides a few modes:

Mode | Pros | Cons
-----|------|-----
`-browser` | Performant UI, HiDPI out of the box (if browser is configured properly) | Unable to use Add-On Manager
`-vnc` | Out of the box MATLAB experience, stable | no GPU acceleration, medium/high overhead, running entire XFCE environment just for MATLAB
`-batch` | Low overhead, stable | no GUI
X11 | Excellent integration with X11 Desktops, low overhead | Unstable, insecure

I propose a compromise: running MATLAB with VNC with minimal overhead and best possible desktop integration.

> Although `matlab-podman` runs in a container, home directory binding will disable some SELinux features.
> This is a bug (and I have no idea how to fix it).
> This only applies to the `matlab-podman` script without `-D`.

### Why?

These are rough comparisons (`podman stats`):

Stock MATLAB image (idle, VNC connected, MATLAB not running):
```
ID            NAME              CPU %       MEM USAGE / LIMIT  MEM %       NET IO       BLOCK IO    PIDS        CPU TIME    AVG CPU %
e9d11065c357  gallant_mahavira  0.01%       255.1MB / 7.096GB  3.60%       430B / 134B  0B / 0B     113         5.705051s   8.47%
```

matlab-minimal (idle, VNC connected, MATLAB not running):
```
ID            NAME              CPU %       MEM USAGE / LIMIT  MEM %       NET IO       BLOCK IO    PIDS        CPU TIME    AVG CPU %
8e9588e658ca  gallant_mahavira  0.01%       46.88MB / 7.096GB  0.66%       430B / 134B  0B / 0B     8           1.03477s    7.68%
```

Stock MATLAB image (MATLAB running):
```
ID            NAME              CPU %       MEM USAGE / LIMIT  MEM %       NET IO             BLOCK IO    PIDS        CPU TIME     AVG CPU %
b02bd287e6fb  gallant_mahavira  1.58%       1.482GB / 7.096GB  20.89%      26.15kB / 662.4kB  0B / 0B     282         1m1.025288s  32.89%
```

matlab-minimal (MATLAB running):
```
ID            NAME              CPU %       MEM USAGE / LIMIT  MEM %       NET IO             BLOCK IO    PIDS        CPU TIME    AVG CPU %
8e9588e658ca  gallant_mahavira  1.16%       1.27GB / 7.096GB   17.89%      29.09kB / 661.7kB  0B / 0B     180         56.66183s   18.97%
```

`matlab-minimal` just saves more memory.

### TigerVNC/NoVNC

TigerVNC viewer and NoVNC supports remote resizing while openbox can resize maximized windows when screen size changes.
If MATLAB is maximized it provides a seamless desktop experience.

![video](https://user-images.githubusercontent.com/20792268/188265893-a3087498-06c7-4ddd-b518-d7e8f653f3dc.mp4)

### matlab-minimal image

This repo includes a Dockerfile that creates a minimal MATLAB image based on the [official MathWorks image][2].

Features:
- XFCE4 replaced with openbox.
- Low idle memory usage.
- `ctrl+shift+c` and `ctrl+shift+v` added to xterm to copy/paste from `CLIPBOARD`.

To build, clone this repo and run `podman build --tag matlab-minimal .`

### matlab-podman

This is a script to launch podman and TigerVNC (or NoVNC with a browser).

Features:

- mounting `~/.matlab` to persist license information.
- mounting home directory as `~/host.{username}` for easy access.
- passwordless VNC authentication.
- terminating the container after VNC viewer is closed (only supports TigerVNC).

Currently the script only supports the `-vnc` option.

Dependencies:

- `bash`
- `podman` (has to be podman)
- TigerVNC (`vncviewer` and `vncpasswd`) (optional)

### Alternatives
- use the [original Docker image][2]
- [systemd-nspawn][3] as suggested by Arch Wiki (didn't work for me)
- [x11docker][4] (very doable; try that instead)
- Windows/Ubuntu VM (maybe?)


[1]: https://wiki.archlinux.org/title/MATLAB
[2]: https://hub.docker.com/r/mathworks/matlab
[3]: https://wiki.archlinux.org/title/MATLAB#MATLAB_in_a_systemd-nspawn
[4]: https://github.com/mviereck/x11docker