     1	#
     2	# Copyright(c) 2020-2023 Liu Hongyu
     3	#
     4	# Licensed under the Apache License, Version 2.0 (the "License");
     5	# you may not use this file except in compliance with the License.
     6	# You may obtain a copy of the License at
     7	#
     8	#     http://www.apache.org/licenses/LICENSE-2.0
     9	#
    10	# Unless required by applicable law or agreed to in writing, software
    11	# distributed under the License is distributed on an "AS IS" BASIS,
    12	# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    13	# See the License for the specific language governing permissions and
    14	# limitations under the License.
    15	#
    16	export VAGRANT_HOME="/home/vagrant"
    17	export APP_HOME="/devbox"
    18	export APP_DOMAIN="example.com"
    19	export MODULE_ROOT="/vagrant/lib/modules"
    20	source $MODULE_ROOT/config.sh
    21	source $MODULE_ROOT/logging.sh
    22	source $MODULE_ROOT/test.sh