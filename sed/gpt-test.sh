#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90</maxHistory>"

# define the replacement strings
rs1="<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="<maxFileSize>100MB</maxFileSize>" 
rs3="<maxHistory>60</maxHistory>"
rs4="<totalSizeCap>20GB</totalSizeCap>"

# use sed to perform replacement (only the first match)
sed -i "" -e '|<appender name="logfile"|,|</appender>| s|${search_pattern}|${rs1}\\n${rs2}\\n${rs3}\\n${rs4}|' logback.xml

# cat logback.xml

