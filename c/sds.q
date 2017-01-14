sdsInit:`sds 2:(`init,1); // load the init function
onData:{show "onData:",(string x)," ",(string y)}; // define callback
sdsInit `$"/dev/ttyUSB0"; // start reading data



