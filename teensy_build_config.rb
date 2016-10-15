MRuby::Build.new do |conf|

  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug

  # include the default GEMs
  conf.gembox 'default'

end

# Configuration for Teensy 3.6:
#    https://www.pjrc.com/store/teensy36.html
#
# Teensyduino installation is required:
#    https://www.pjrc.com/teensy/td_download.html
#
MRuby::CrossBuild.new("Teensy36") do |conf|
  toolchain :gcc

  TD_PATH = ENV['TD_PATH']
  BIN_PATH = "#{TD_PATH}/hardware/tools/arm/bin"

  conf.cc do |cc|
    cc.command = "#{BIN_PATH}/arm-none-eabi-gcc"
    cc.include_paths << [".."]
    cc.flags = %w(-Wall -g -Os -mcpu=cortex-m4 -mthumb -MMD -DF_CPU=48000000 -DUSB_SERIAL
                  -DLAYOUT_US_ENGLISH -DUSING_MAKEFILE -D__MK66FX1M0__ -DARDUINO=10600 
                  -DTEENSYDUINO=121)
    cc.compile_options = "%{flags} -o %{outfile} -c %{infile}"

    cc.defines << %w(MRB_HEAP_PAGE_SIZE=64)
    cc.defines << %w(MRB_USE_IV_SEGLIST)
    cc.defines << %w(KHASH_DEFAULT_SIZE=8)
    cc.defines << %w(MRB_STR_BUF_MIN_SIZE=20)
    cc.defines << %w(MRB_GC_STRESS)
  end

  conf.cxx do |cxx|
    cxx.command = conf.cc.command.dup
    cxx.include_paths = conf.cc.include_paths.dup
    cxx.flags = conf.cc.flags.dup
    cxx.flags << %w(-fno-rtti -fno-exceptions)
    cxx.defines = conf.cc.defines.dup
    cxx.compile_options = conf.cc.compile_options.dup
  end

  conf.archiver do |archiver|
    archiver.command = "#{BIN_PATH}/arm-none-eabi-ar"
    archiver.archive_options = 'rcs %{outfile} %{objs}'
  end

  conf.bins = []
  conf.build_mrbtest_lib_only
  conf.disable_cxx_exception
end
