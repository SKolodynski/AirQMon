# AirQMon

This repository contains code for a cheap air quality monitoring station based on [Nova 
Fitness SDS011](http://inovafitness.com/upload/file/20150311/14261262164716.pdf) PM2.5 sensor.

The `c` directory contains code for the KDB+ extension library (written in C) that reads the SDS011 data from a device path (typically `/dev/ttyUSB0`) and sends that to the KDB+ side. KDB+ is a database specialized for time series made by Kx Systems. I use that database in the project as KX made a Raspberry Pi version of KDB+ available for non-commercial use. The `sds.c` file in that directory does not contain any KDB+ - specific code. This file can be useful for an SDS011 project that does not use KDB+.

The `q` directory contains the configuration and [q](https://en.wikipedia.org/wiki/Q_(programming_language_from_Kx_Systems)) code for the Enterprise Components system that manages KDB+ database processes and tables and uploads the data to the hosting service. [Enterprise Components](https://github.com/exxeleron/enterprise-components) is an open source middleware for KDB+.
