# docker-eac

Exact Audio Copy (EAC) in Docker

[![Build Status][1]][2]

[1]: https://travis-ci.org/attilabogar/docker-eac.svg?branch=master
[2]: https://travis-ci.org/attilabogar/docker-eac


## Description

This project can be used to simultaneously transfer Audio CD's using [Exact
Audio Copy](http://exactaudiocopy.de/) in a docker environment on a Linux
system w/ multiple CD-ROM drives.

## Requirements

  - docker
  - docker-compose
  - system w/ one or more CD-ROM drives
  - access to `/dev/sr*` block devices

## Setup

  - `eac.rc` settings for docker-eac (see example file `eac.rc.example`)
  - `drives.txt` CD-ROM static drive mapping (see example file `drives.txt.example`)

### drives.txt

Create `drives.txt`.  The format of this file is one line per CD-ROM in a
format `<drivename> <drivemapping>`.  An example configuration file is provided
as `drives.txt.example`. To find the available CD-ROM drives run `ls -l
/dev/disk/by-id/`

Keeping CD-ROM mapping in `drives.txt` keeps the drive mapping consistent, even
if `/dev/sr*` block device numbering order changes.

### eac.rc

To customise `eac.rc`, edit and set
  - `WINEROOT` - the root directory for each CD-ROM drive's `WINEPREFIX` environment
  - `SHARE` - the directory to map as `/data` in the containers
  - `SCREEN_WIDTH` - VNC screen width (1920 by default)
  - `SCREEN_HEIGHT` - VNC screen height (1080 by default)

### WINE/EAC Setup

This part is only needed for the first time per each CD-ROM drive

  - open terminal and execute: `winecfg`
    - on the Drives tab, add `D:` drive:
      - Path: `/cdrom`
      - Type: `CD-ROM` (Advanced)
      - click apply and OK
  - copy `eac-1.3.exe` to `SHARE`
  - open terminal and execute: `wine /data/eac-1.3.exe` 
  - install EAC
    - don't install mono
    - don't install gecko
    - install these two plugins only:
      - FLAC
      - AccurateRip
  - run EAC
    - select FLAC as the compression format
    - select `03 Dancing Queen` as the file naming format

## Usage

After a succesful configuration, the docker-eac stack can be simply brought up
by runnning `./eac.sh`

A VNC remote desktop viewer application is required to access the per CD-ROM
drive environments.

The X environment within the docker container is using `openbox` as a
lightweight window manager.  Right mouse click to access the menu.


## LICENSE

    MIT License

    Copyright (c) 2019 Attila Bogár

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

**NOTE**: This software depends on other packages that may be licensed under
different open source licenses.
