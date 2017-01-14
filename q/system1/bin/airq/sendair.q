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

.airs.init:{
  .hnd.hopen[`out.airq;1000i;`eager];
  .tmr.start[`.airs.tmr;600000;`sendTmr]; // every 10 mins
  };

.airs.tmr:{[ts]
  if[10>count pm;:(::)]; // at least 10 measurements = 10 mins 
  if[60000>`long$.z.t-first pm`time;:(::)]; // at least 1 minute
  // take average from the last hour, we only report pm 25,0.8 is an arbitrary correction factor
  val:`short$0.8*avg exec pm25 from pm where time>(last pm`time)-3600000;
  tm:(string .z.D)," ",(neg 4)_string (last pm`time)+.z.T-.z.t; // last timestamp plus local time shift
  .log.info[`airs]"time: ",(string tm)," pm2.5: ",string val;
  .hnd.ah[`out.airq](`.sndr.data;.j.j (`version`ts`pm25)!(1;tm;val));
  };

.airs.init[];
