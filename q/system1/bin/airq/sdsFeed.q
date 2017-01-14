/L/ Copyright (c) 2016 Slawomir Kolodynski
/-/
/-/ Licensed under the Apache License, Version 2.0 (the "License");
/-/ you may not use this file except in compliance with the License.
/-/ You may obtain a copy of the License at
/-/
/-/   http://www.apache.org/licenses/LICENSE-2.0
/-/
/-/ Unless required by applicable law or agreed to in writing, software
/-/ distributed under the License is distributed on an "AS IS" BASIS,
/-/ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/-/ See the License for the specific language governing permissions and
/-/ limitations under the License.

/------------------------------------------------------------------------------/
system"l ",getenv[`EC_QSL_PATH],"/sl.q";

/------------------------------------------------------------------------------/
.sl.init[`sdsFeed];
.sl.lib[`$"qsl/handle"];
.sl.lib["cfgRdr/cfgRdr"];

.airq.pm:([] pm25s:`short$();pm10s:`short$());


/------------------------------------------------------------------------------/
/                             publishing                                       /
/------------------------------------------------------------------------------/
/F/ Initializes the air quality data reader.
/E/ .airq.init[]
.airq.init:{[]
   // set up the data callback
   onData::.airq.onData;
   //initialize connection to the data destination
  .hnd.poAdd[.airq.cfg.dst;`.airq.po];
  .hnd.pcAdd[.airq.cfg.dst;`.airq.pc];
  .hnd.hopen[.airq.cfg.dst;1000i;`eager];
  };

/------------------------------------------------------------------------------/
/F/ Callback for destination server "port open".
/-/  - initialization of eod timer
/-/  - detection of destination server protocol
/-/  - initialization of publishing timers - one per each table
/P/ x:INT - handle
/R/ no return value
/E/ .airq.po[12i]
.airq.po:{[x]
  /G/ Destination server protocol.
  .airq.dstProtocol:first .hnd.h[.airq.cfg.dst]".sl.getSubProtocols[]";
  if[not .airq.dstProtocol~`PROTOCOL_TICKHF;
    .log.fatal[`airq]"Only standard tick supported in destination";
    exit 1;
    ];
  // start reding from the serial port
  .log.info[`sds]"initializing sensor...";
  (`sds 2:(`init,1)) .airq.cfg.port;
  .log.info[`sds]"sensor initialized";
  };

/------------------------------------------------------------------------------/
/F/ Callback for destination server "port close".
/P/ x:INT - handle
.airq.pc:{[x]
  (`sds 2:(`stop,1)) 0;
  };

/F/ data callback
.airq.onData:{[pm25;pm10]
    // show"data: ",(string pm25)," ",string pm10;
    if[not null pm25;`.airq.pm insert (pm25;pm10)];
    if[59<count .airq.pm; // we rely on sensors 1Hz frequency, send update every 1 min
        data:select time:enlist .z.t,sym:`OBOS,pm25:`short$avg (-1)_1_ asc pm25s,pm10:`short$avg (-1)_1_ asc pm10s from .airq.pm;
	.hnd.h[.airq.cfg.dst](`.u.upd;`pm;value flip data);
        .airq.pm:([] pm25s:`short$();pm10s:`short$());
        ]; 
    };

/------------------------------------------------------------------------------/
/                              PROTOCOL_TICKHF                                 /
/------------------------------------------------------------------------------/

/------------------------------------------------------------------------------/

/G/ Measurements
.airq.mcyc:();

/G/ Oborniki Slaskie om 2.5
.airq.sym:`$"PM2.5";

/G/ whether to store trace
.airq.store:0b;

/G/ global to store trace
.airq.p.trace:();


/F/ Triggers eod for tickHF server.
/P/ date:DATE - eod date
/R/ no return value
/E/ .airq.tickHF.pubEod[.z.d]
.airq.tickHF.pubEod:{[date]
  .log.info[sds] "No eod action for tickHF";
  };

/------------------------------------------------------------------------------/
/                                    main                                      /
/------------------------------------------------------------------------------/
/F/ Component initialization entry point.
/P/ flags:LIST - nyi
/R/ no return value
/E/ .sl.main`
.sl.main:{[flags]
  .airq.cfg.dst:      .cr.getCfgField[`THIS;`group;`cfg.dst];
  .airq.cfg.eodTime:  .cr.getCfgField[`THIS;`group;`cfg.eodTime];
  .airq.cfg.port: .cr.getCfgField[`THIS;`group;`cfg.port];
  .airq.init[];
  };

/------------------------------------------------------------------------------/
.sl.run[`airq;`.sl.main;`];

/------------------------------------------------------------------------------/

/

data:select time:enlist .z.t,sym:`OBOS,avgpm25:`short$avg pm25s,minpm25:min pm25s,maxpm25:max pm25s,avgpm10:`short$avg pm10s,minpm10:min pm10s,maxpm10:max pm10s from .airq.pm;
