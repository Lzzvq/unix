# learning about sed 
- `sed -i "" 's/dog/cat/g' dogs.txt` will replace `dog` in `dogs.txt` with `cat`
- `sed -i "" 's/dog/"cat"/g' dogs.txt` will replace `dog` in `dogs.txt` with `"cat"`
- on macOS, `-i ""` has to be used. on Linux, `-i` is sufficient
- `sed -i "" 's/cat/$rs1/g' dogs.txt | cat dogs.txt` didn't replace `cat` that was in the file
- `sed -i "" 's/cat/${rs1}/g' dogs.txt | cat dogs.txt` replaced `cat` with `$rs1`
- sorta skimmed this article and tried a -r https://linuxhint.com/environment-variables-sed-command/
    - `sed -i "" -r 's/dog/$rs1/g' dogs.txt | cat dogs.txt` no change. `dogs` stayed 
- asked chatgpt, it said to use double quotes instead
    - `sed -i "" -r "s/dog/$rs1/g" dogs.txt | cat dogs.txt` returned `$rs1s`
    - `sed -i "" "s/dog/${rs1}/g" dogs.txt | cat dogs.txt` returned `dogs` (after I deleted $rs1s and added dogs manually)
    - `-r` was apparently important 
        - `sed -i "" -r "s/dog/${rs1}/g" dogs.txt| cat dogs.txt` returned `ho hipposs`, which is expected
- `sed -i "" -r "s/dogs/${rs1}\n${rs1}/g" dogs.txt | cat dogs.txt` returned `dogs`, meaning no replacement took place 
    - `sed -i "" -r "s/dogs/${rs1}\\n${rs1}/g" dogs.txt|cat dogs.txt` returned the following, which is expected. ChatGPT said to escape the \n, probably because of the extended regex which is being used with -r  
        ```
        kuon
        kuon
        ```
    - `sed -i "" -r "s|dogs|${rs1}\\n${rs1}|g" dogs.txt|cat dogs.txt`
    - `sed -i "" -r "s|dogs|${rs1}\\n${rs1}|g" dogs.txt && cat dogs.txt` returned 4x kuon each on new lines, which is expected
        - per a previous response from chat + the answer it gave when I asked about the command on line 20 not working 
- Now that I have sorta a baseline set, now for actual work...
- `echo "<maxHistory>90<\/maxHistory>" > logback.xml`
- `search_pattern="<maxHistory>90<\/maxHistory>"`
- `replacement_string="<maxHistory>60<\/maxHistory>"`
- `sed -i "" -r "s|${search_pattern}|${replacement_string}|g" logback.xml && cat logback.xml`
    - no changes to the file; turns out I didn't need all the escape characters that I had just copied from Chat's script from yesterday
- chat recommended 
    - `echo "<maxHistory>90</maxHistory>" > logback.xml`
    - `search_pattern="<maxHistory>90</maxHistory>"`
    - `replacement_string="<maxHistory>60</maxHistory>"`
    - `sed -i "" -e "s|${search_pattern}|${replacement_string}|g" logback.xml && cat logback.xml` replaced as expected 
        - also works without the -e 
- `echo "<maxHistory>90</maxHistory>" > logback.xml` can be used to reset the file; in this setup, echo overwrites the file 
    - `>>` appends 
- `sed -i "" -e "s|${search_pattern}|${replacement_string}\\n${replacement_string}|g" logback.xml && cat logback.xml`
    - `-e`, `-r`, and no flag after `""` all returned the same result 
## Nexus log replacement 
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90</maxHistory>"

# define the replacement strings
rs1="<maxHistory>60</maxHistory>"
rs2="ho buus"
rs3="he ornis"
rs4="to probaton"

# use sed to perform replacement
sed -i "" -e "s|${search_pattern}|${rs1}\\n${rs1}|g" logback.xml

cat logback.xml
```
- `echo "<maxHistory>90</maxHistory>" > logback.xml` then ./test.sh returned the following, which is expected
```
<maxHistory>60</maxHistory>
<maxHistory>60</maxHistory>
```
- `echo "  <maxHistory>90</maxHistory>" > logback.xml` then ./test.sh returned the following, which wasn't expected
```
  <maxHistory>60</maxHistory>
<maxHistory>60</maxHistory>
``` 
### Try this out in testing
- completely corrected the script - did it in vi to start getting better at my understanding there 
- Matt Ramey let me know that xml doesn't care about indentation 
- remember to replace `-i ""` with `-i` in user-data.sh
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90</maxHistory>"

# define the replacement strings
rs1="<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="<maxFileSize>100MB</maxFileSize>"
rs3="<maxHistory>60</maxHistory>"
rs4="<totalSizeCap>20GB</totalSizeCap>"

# use sed to perform replacement
sed -i "" -e "s|${search_pattern}|${rs1}\\n${rs2}\\n${rs3}\\n${rs4}|g" logback.xml

cat logback.xml
```
- `echo "  <maxHistory>90</maxHistory>" > logback.xml` `./test.sh` returned the expected, but not necessarily desired results of the following
```
  <!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
<maxFileSize>100MB</maxFileSize>
<maxHistory>60</maxHistory>
<totalSizeCap>20GB</totalSizeCap>
``` 
the first line matches where the replacement was, but the other lines just go to the furthest left 

### Indentation doesn't matter in xml? 
- Chat recommended 
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90</maxHistory>"

# get the indentation from the search pattern
indentation=$(sed -n "s/^\( *\).*/\1/p" <<< "$search_pattern")

# define the replacement strings with indentation
rs1="${indentation}<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="${indentation}<maxFileSize>100MB</maxFileSize>"
rs3="${indentation}<maxHistory>60</maxHistory>"
rs4="${indentation}<totalSizeCap>20GB</totalSizeCap>"

# use sed to perform replacement
sed -i "" -e "s|${search_pattern}|${rs1}\\n${rs2}\\n${rs3}\\n${rs4}|g" logback.xml

cat logback.xml
echo $indentation
```
- returned the results I've seen in the past, cause it was looking at search pattern in the .sh, not the spacing in the file. clarified, and Chat recommended
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90<\/maxHistory>"

# get the indentation from the line containing the search pattern
indentation=$(sed -n "s/^\( *\).*/\1/p" logback.xml)

# define the replacement strings with indentation
rs1="${indentation}<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="${indentation}<maxFileSize>100MB<\/maxFileSize>"
rs3="${indentation}<maxHistory>60<\/maxHistory>"
rs4="${indentation}<totalSizeCap>20GB<\/totalSizeCap>"

# use sed to perform replacement
sed -i "" -e "s|${search_pattern}|${rs1}\\n${rs2}\\n${rs3}\\n${rs4}|g" logback.xml

cat logback.xml

#and I added this bit
echo $indentation
```
- got the following error 
```
sed: 1: "s|<maxHistory>90</maxHi ...": unescaped newline inside substitute pattern
<some_settings>
  <additional_settings>
    <maxHistory>90</maxHistory>
```
- chat recommended the following
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90</maxHistory>"

# get the indentation from the line containing the search pattern
indentation=$(sed -n "s/^\( *\).*/\1/p" logback.xml)

# define the replacement strings with indentation
rs1="${indentation}<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="${indentation}<maxFileSize>100MB<\/maxFileSize>"
rs3="${indentation}<maxHistory>60<\/maxHistory>"
rs4="${indentation}<totalSizeCap>20GB<\/totalSizeCap>"

# escape forward slashes in the replacement strings
rs1_escaped=$(sed 's/\//\\\//g' <<< "$rs1")
rs2_escaped=$(sed 's/\//\\\//g' <<< "$rs2")
rs3_escaped=$(sed 's/\//\\\//g' <<< "$rs3")
rs4_escaped=$(sed 's/\//\\\//g' <<< "$rs4")

# use sed to perform replacement
sed -i "" -e "s|${search_pattern}|${rs1_escaped}\\
${rs2_escaped}\\
${rs3_escaped}\\
${rs4_escaped}|g" logback.xml

cat logback.xml
```
- same error, Chat recommended
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90<\/maxHistory>"

# get the indentation from the line containing the search pattern
indentation=$(sed -n "s/^\( *\).*/\1/p" logback.xml)

# define the replacement strings with indentation
rs1="${indentation}<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="${indentation}<maxFileSize>100MB<\/maxFileSize>"
rs3="${indentation}<maxHistory>60<\/maxHistory>"
rs4="${indentation}<totalSizeCap>20GB<\/totalSizeCap>"

# use sed to perform replacement
sed -i "" -e "s|${search_pattern}|$(printf '%s\\n%s\\n%s\\n%s' "$rs1" "$rs2" "$rs3" "$rs4")|g" logback.xml

cat logback.xml
```
- still same error. I think we're on the wrong path here 
- went back to figuring out the indentation
    - it took me a minute to realize it, but just `echo $indentation` in the script did in fact return blank lines, which weren't immediately obvious
    - chat recommended `echo "$rs1"` and the same formatting for the others to also show whitespace. It seemed like there is a newline along with the whitespace. 
- Chat suggested to try this to remove whitespace
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90<\/maxHistory>"

# get the indentation from the line containing the search pattern
indentation=$(grep -o "^[[:space:]]*" logback.xml | tr -d '\n')

# define the replacement strings with indentation
rs1="${indentation}<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="${indentation}<maxFileSize>100MB<\/maxFileSize>"
rs3="${indentation}<maxHistory>60<\/maxHistory>"
rs4="${indentation}<totalSizeCap>20GB<\/totalSizeCap>"

# use sed to perform replacement
sed -i "" -e "s|${search_pattern}|${rs1}\\
${rs2}\\
${rs3}\\
${rs4}|g" logback.xml

cat logback.xml

# display the captured indentation
echo "Captured Indentation: '$indentation'"

# display the replacement strings with trimmed whitespace and newlines
echo "${rs1}" | sed 's/^[[:space:]]*//'
echo "${rs2}" | sed 's/^[[:space:]]*//'
echo "${rs3}" | sed 's/^[[:space:]]*//'
echo "${rs4}" | sed 's/^[[:space:]]*//'
```
- okay, we're on a better path here. There was a double indentation on the first line, but the other lines are how I wanted them
```
<some_settings>
  <additional_settings>
          <!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
      <maxFileSize>100MB</maxFileSize>
      <maxHistory>60</maxHistory>
      <totalSizeCap>20GB</totalSizeCap>
Captured Indentation: '      '
<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
<maxFileSize>100MB<\/maxFileSize>
<maxHistory>60<\/maxHistory>
<totalSizeCap>20GB<\/totalSizeCap>
``` 
- what happens if maxhistory is at different levels? 
```
<stuff>
    <things>
        <maxHistory>90<\/maxHistory>
            <maxHistory>90<\/maxHistory>
```
also, remove the space deletion from the echos. that's the opposite of what I'm trying to accomplish 
- I'm a bit confused, here's Chat's latest output
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90<\/maxHistory>"

# get the indentation from the line containing the search pattern
indentation=$(grep -o "^[[:space:]]*<maxHistory>" logback.xml)

# define the replacement strings with indentation
rs1="${indentation}<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="${indentation}    <maxFileSize>100MB<\/maxFileSize>"
rs3="${indentation}    <maxHistory>60<\/maxHistory>"
rs4="${indentation}    <totalSizeCap>20GB<\/totalSizeCap>"

# use sed to perform replacement
sed -i "" -e "s|${search_pattern}|${rs1}\\
${rs2}\\
${rs3}\\
${rs4}|g" logback.xml

cat logback.xml

# display the captured indentation
echo "Captured Indentation: '$indentation'"

# display the replacement strings with leading whitespace
echo "$rs1"
echo "$rs2"
echo "$rs3"
echo "$rs4"
```
- returning the following, which is a little weird 
```
<some_settings>
  <additional_settings>    
          <!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
      <maxFileSize>100MB</maxFileSize>
      <maxHistory>60</maxHistory>
      <totalSizeCap>20GB</totalSizeCap>
Captured Indentation: '      <maxHistory>'
      <maxHistory><!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
      <maxHistory>    <maxFileSize>100MB<\/maxFileSize>
      <maxHistory>    <maxHistory>60<\/maxHistory>
      <maxHistory>    <totalSizeCap>20GB<\/totalSizeCap>
```
turns out xml doesn't actually care about spacing... 

### 20230608 testing
- Matt said that only the first one should be replaced
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90</maxHistory>"

# define the replacement strings
rs1="<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="<maxFileSize>100MB</maxFileSize>" 
rs3="<maxHistory>60</maxHistory>"
rs4="<totalSizeCap>20GB</totalSizeCap>"

# use sed to perform replacement
sed -i "" -e "0,|${search_pattern}|{s|${search_pattern}|${rs1}\\n${rs2}\\n${rs3}\\n${rs4}|}" logback.xml

cat logback.xml
```
- didn't do any substitution - removed `|g`
- tested in sed editor https://sed.js.org/
- removed `0,|${search_pattern}|{` and `}` still getting same error. substituted the vars 
    - `-i -e "0,|<maxHistory>90</maxHistory>|{s|<maxHistory>90</maxHistory>|<maxHistory>60</maxHistory>|}"`
        - 'no input files' - had to remove -i and -e 
            - `'s|<maxHistory>90</maxHistory>|<maxHistory>60</maxHistory>|'` worked, but w the `0,` same error 
            - 0, works with GNU sed only 
- https://superuser.com/questions/644036/how-to-do-replace-using-sed-only-in-one-section-of-file
    - `'sed |<appender name="logfile"|,|^</appender>|s|<maxHistory>90</maxHistory>|<maxHistory>60</maxHistory>|` 
        - `sed: -e expression #1, char 14: unknown option to 's'`
- https://superuser.com/questions/394282/sed-perform-only-first-nth-matched-replacement
    - `/1/{s|<maxHistory>90</maxHistory>|<maxHistory>60</maxHistory>|}`
        - replaces all the instances of maxHistory in the file, but will only update the first occurance in a _line_ 
- https://superuser.com/questions/1689644/find-and-replace-text-in-a-file-after-match-of-pattern-only-for-first-occurrence
    - `sed "/Server 'Test EF'/,/Server/ s/option port '1234'/option port '9876'/" file` was the suggestion 
    - `sed '|<appender name="logfile|,|</appender>| s|<maxHistory>90</maxHistory>|<maxHistory>60</maxHistory>|'`
        - `sed: -e expression #1, char 3: unterminated 's' command` 
        - going to test on my local machine
    - `sed -i "" -e '|<appender name="logfile|,|</appender>| s|<maxHistory>90</maxHistory>|<maxHistory>60</maxHistory>|' logback.xml`
        - `sed: 1: "|<appender name="logfil ...": invalid command code |`
    - `sed -i "" -e "0,|<maxHistory>90</maxHistory>|{s|<maxHistory>90</maxHistory>|<maxHistory>60</maxHistory>|}" logback.xml`
        - `sed: 1: "0,|<maxHistory>90</maxH ...": expected context address`
- switched back to trying Chat's recommendations 
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90</maxHistory>"

# define the replacement strings
rs1="<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="<maxFileSize>100MB</maxFileSize>" 
rs3="<maxHistory>60</maxHistory>"
rs4="<totalSizeCap>20GB</totalSizeCap>"

# use sed to perform replacement (only the first match)
sed -i "" -e "0,/${search_pattern}/{s|${search_pattern}|${rs1}\\
${rs2}\\
${rs3}\\
${rs4}|}" logback.xml

cat logback.xml
``` 
`sed: 1: "0,/<maxHistory>90</maxH ...": invalid command code m`
```
#!/bin/bash

# define the search pattern
search_pattern="<maxHistory>90</maxHistory>"

# define the replacement strings
rs1="<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
rs2="<maxFileSize>100MB</maxFileSize>" 
rs3="<maxHistory>60</maxHistory>"
rs4="<totalSizeCap>20GB</totalSizeCap>"

# use sed to perform replacement (only the first match)
sed -i "" -e "0,|${search_pattern}|{s|${search_pattern}|${rs1}\\n${rs2}\\n${rs3}\\n${rs4}|}" logback.xml

cat logback.xml

```
- `sed: 1: "0,|<maxHistory>90</maxH ...": expected context address` would work with gsed, but not with regular sed 
- Justin Roysdon came up with this, which replaces the first occurence on mac 
```
search_pattern="<maxHistory>90</maxHistory>"
comment='<\!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->'
max_file_size="<maxFileSize>100MB</maxFileSize>"
max_history="<maxHistory>60</maxHistory>"
total_size_cap="<totalSizeCap>20GB</totalSizeCap>"

sed -i -e "1,\#${search_pattern}#s#${search_pattern}#${comment}\n${max_history}\n${max_file_size}\n${total_size_cap}#" logback.xml
```
- this is what I had in user-data which (in theory) would replace all the contents in logback.xml, although it didn't even get that far for some reason
``` 
  # update max history with additional log file constraints 
  search_pattern="<maxHistory>90</maxHistory>"

  # define the replacement strings 
  rs1="<!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->"
  rs2="<maxFileSize>10KB</maxFileSize>"
  rs3="<maxHistory>60</maxHistory>"
  rs4="<totalSizeCap>2MB</totalSizeCap>" 

  sed -i -e "s|$search_pattern|$rs1\\n$rs2\\n$rs3\\n$rs4|g" "$file"
``` 
- this is Justin's code in the user-data file, untested in the user-data.sh, but tested in the primary logic part of it 
```
  # Justin helped figure it out once my troubleshooting got to a dead end. I was close, and he closed the gap - thanks! 
  search_pattern="<maxHistory>90</maxHistory>"
  comment='<\!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->'
  max_file_size="<maxFileSize>100MB</maxFileSize>"
  max_history="<maxHistory>60</maxHistory>"
  total_size_cap="<totalSizeCap>20GB</totalSizeCap>"

  sed -i -e "1,\#$search_pattern#s#$search_pattern#$comment\n$max_history\n$max_file_size\n$total_size_cap#" logback.xml
```