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
.sl.init[`airq];

/F/ sends data to server
/P/ data:STRING - a JSON string to be sent 
.sndr.data:{[data]
  .log.info[`sndr] "sending ",.Q.s1 data;
  `:pm.json 0: enlist data;
  };
