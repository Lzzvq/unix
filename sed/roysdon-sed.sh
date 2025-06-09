#!/bin/bash
search_pattern="<rollingPolicy class"
rolling_policy_class="<rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">"
rollover_comment="<!-- rollover daily -->"
filename_pattern="<fileNamePattern>mylog-%d{yyyy-MM-dd}.%i.txt</fileNamePattern>"
comment='<\!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->'
max_file_size="<maxFileSize>100MB</maxFileSize>"
max_history="<maxHistory>60</maxHistory>"
total_size_cap="<totalSizeCap>20GB</totalSizeCap>"

sed -i -e "1,\#${search_pattern}#s#${search_pattern}#${rolling_policy_class}\n${rollover_comment}\n${filename_pattern}\n${comment}\n${max_history}\n${max_file_size}\n${total_size_cap}#" logback.xml

#/opt/sonatype/nexus-3.43.0-01/etc/logback/logback.xml
