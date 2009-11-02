require "mkmf"
$CPPFLAGS<<" -I \"/Applications/National\ Instruments/NI-DAQmx\ Base/includes\" "
$CFLAGS<<" -g -Wall -Wno-redundant-decls "
$LDFLAGS<<"  "
$LIBS<<" -framework nidaqmxbase -framework nidaqmxbaselv "
create_makefile("Daqmxbase")
