mruby on the Teensy 3.6
=======================

A complete project for running [mruby](//github.com/mruby/mruby) on the [Teensy 3.6](https://www.pjrc.com/store/teensy36.html).

Before you get started please make sure you have [Teensyduino](https://www.pjrc.com/teensy/td_download.html) installed and that
the version you have installed supports the Teensy 3.6 board.

Once you have Teensyduino you will need to recursively clone this project:

```
git clone --recursive https://github.com/carsonmcdonald/mruby-teensy.git
```

Once cloned you will need to make a copy of the Makefile.example to Makefile
and then change the "TD_PATH" variable in the Makefile so that it is 
pointing to your Teensyduino installation.

At this point you are ready to build. If you wish to install directly to the
Teensy 3.6 board run the following:

```
make install
```

You will find the source for the program split between two the csrc directory
where the C source is and the rbsrc directory where the ruby source is.

The included mruby program currently doesn't do any more than set a variable
to a value. I hope to make more complicated examples as I find the time.
