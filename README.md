# File Uploader

[![Build Status](https://img.shields.io/travis/dterei/file-uploader.svg?style=flat)](https://travis-ci.org/dterei/file-uploader)

A very simple website for accepting file uploads. Useful for lab submission
from students.

For safety we don't use any user input for the file name, instead using a SHA1
digest to name the file and writing metadata about the file and submission to a
log.

## Running

```
npm install
cp prod.env .env
foreman start
```

## Licensing

This library is BSD-licensed.

## Get involved!

We are happy to receive bug reports, fixes, documentation enhancements, and
other improvements.

Please report bugs via the
[github issue tracker](http://github.com/dterei/file-uploader/issues).

Master [git repository](http://github.com/dterei/file-uploader):

* `git clone git://github.com/dterei/file-uploader.git`

## Authors

This program is written and maintained by David Terei, <code@davidterei.com>.

