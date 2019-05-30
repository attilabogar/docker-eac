# docker-eac

Exact Audio Copy (EAC) w/ Docker

[![Build Status][1]][2]

[1]: https://travis-ci.org/attilabogar/docker-eac.svg?branch=master
[2]: https://travis-ci.org/attilabogar/docker-eac


## Description

This project may be used to simultaneously transfer Audio CD's using [Exact
Audio Copy](http://exactaudiocopy.de/) in a docker environment on a Linux.

## Requirements

  - docker
  - docker-compose
  - system w/ one or more CD-ROM drives

## Setup

  - `Dockerfile` (used to build the base image w/ wine support)
  - `drives.txt.example` (an example CD-ROM drive setup)
  - `eac.sh` (shell script to bring up / destroy the eac stack)
  - make sure you are member of the `cdrom` system group

### Dockerfile

  - `USERID` (1001 by default)
  - `SCREEN_WIDTH` (1920 by default)
  - `SCREEN_HEIGHT` (1080 by default)

### drives.txt

Create `drives.txt`.  The format of this file is one line per CD-ROM in a
format `<drivename> <drivemapping>`.  An example configuration file is provided
as `drives.txt.example`. To find the drives available on your system run `ls -l
/dev/disk/by-id/`

### eac.sh

To customise `eac.sh`, edit and set
  - `WDIR` - the root directory for each CD-ROM drive' `WINEPREFIX`
  - `SHARE` - the directory to map under `/data` in the containers

### WINE/EAC Setup

This part is only needed for the first time per each CD-ROM drive

  - open terminal and execute: `winecfg`
    - on the Drives tab, add `D:` drive:
      - Path: `/cdrom`
      - Type: `CD-ROM` (Advanced)
      - click apply and OK
  - copy `eac-1.3.exe` to `$SHARE`
  - open terminal and execute: `wine /data/eac-1.3.exe` 
  - install EAC:
    - don't install mono
    - don't install gecko
    - install these two plugins only:
      - FLAC
      - AccurateRip
    - run EAC
      - select FLAC as the compression format
      - select `03 Dancing Queen` as the file naming format

## Usage

After succesfull configuration, the docker-eac stack can be simply brought up
by runnning `./eac.sh` - You will need a VNC remote desktop viewer to access
the per CD-ROM drive environments.

The X environment within the docker container is using `openbox` as the lightweight window manager.
Use your mouse' right-click to acces the menu.


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
