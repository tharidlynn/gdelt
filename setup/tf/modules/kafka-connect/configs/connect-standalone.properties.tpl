# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



# Kafka broker IP addresses to connect to
bootstrap.servers=${kafka_host}

# Path to directory containing the connector jar and dependencies
plugin.path=/usr/local/share/kafka/plugins

# Converters to use to convert keys and values
key.converter=org.apache.kafka.connect.storage.StringConverter
# json converter if want other data types such as int, float else use string
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=false
value.converter.schemas.enable=false

# The internal converters Kafka Connect uses for storing offset and configuration data
internal.key.converter=org.apache.kafka.connect.json.JsonConverter
internal.value.converter=org.apache.kafka.connect.json.JsonConverter
internal.key.converter.schemas.enable=false
internal.value.converter.schemas.enable=false

offset.storage.file.filename=/tmp/connect.offsets




# # These are defaults. This file just demonstrates how to override some settings.
# bootstrap.servers=localhost:9092

# # The converters specify the format of data in Kafka and how to translate it into Connect data. Every Connect user will
# # need to configure these based on the format they want their data in when loaded from or stored into Kafka
# key.converter=org.apache.kafka.connect.json.JsonConverter
# value.converter=org.apache.kafka.connect.json.JsonConverter
# # Converter-specific settings can be passed in by prefixing the Converter's setting with the converter we want to apply
# # it to
# key.converter.schemas.enable=true
# value.converter.schemas.enable=true

# offset.storage.file.filename=/tmp/connect.offsets
# # Flush much faster than normal, which is useful for testing/debugging
# offset.flush.interval.ms=10000


# Set to a list of filesystem paths separated by commas (,) to enable class loading isolation for plugins
# (connectors, converters, transformations). The list should consist of top level directories that include 
# any combination of: 
# a) directories immediately containing jars with plugins and their dependencies
# b) uber-jars with plugins and their dependencies
# c) directories immediately containing the package directory structure of classes of plugins and their dependencies
# Note: symlinks will be followed to discover dependencies or plugins.
# Examples: 
# plugin.path=/usr/local/share/java,/usr/local/share/kafka/plugins,/opt/connectors,
#plugin.path=
