vi/vim commands
vim supports using the mouse
Notes
General Buffer (GB) ~= clipboard
Format of VI commands: [count][command] to repeat the effect of the command

input commands
a: append after cursor
i: insert before cursor
o: open line below
O: open line above
:r <file>: insert <file> after current line

change commands 
cw: change word - removes the rest of the characters in the word after the cursor
ciw: change inner word - replace word cursor is currently in
cc: change line - 'cut' the line and store in GB
c$: change to end of line - 'cut' from the cursor to the end of the line and store in GB   
r<character>: replace character where cursor is at with a new character
R: replace - typeover
s: subsitute 1 character with string - delete character that cursor is over? I don't understand this one
S: substitute rest of line with text - also don't understand this one yet
.: repeat last change - can be used to 'redo' a single 'undo' and repeat the last chunk of typing 

changes during insert mode
<ctrl>h: delete one character
<ctrl>w: delete one word
<ctrl>u: delete back to beginning of insert

window motions
<ctrl>d: scroll down (half a screen)
<ctrl>u: scroll up (half a screen)
<ctrl>f: page forward
<ctrl>b: page backward
/string: search forward
?string: search backward
n: repeat search
N: repeat search reverse
<ctrl>l: redraw screen
<ctrl>g: display current line number and file information
gg: go to first line
G: go to last line
<n>G: go to last line <n>
:<n>: go to line <n>
z<CR>: reposition window: cursor at top - not tracking on this one
z.: resposition window: cursor in middle
z-: reposition window: cursor at bottom

cursor motions
H: upper left corner (home) of visible pane
M: middle line of visible pane
L: lower left corner of visible pane
h: navigate a character back
l: navigate a character forward 
b: navigate one word backward
w: navigate one word forward
j: navigate down a line
k: navigate up a line
^: beginning of line
$: end of line
f<c>: find <c>
;: repeat find (find next <c>) - not sure how either of these c commands work

deletion commands (note: most of these will not delete the letter under the cursor)
dd or <n>dd: delete line or delete <n> lines to GB
dw: delete word to GB
d<n>w: delete <n> words to GB
d): delete to end of sentence
db: delete previous word
D: delete to end of line
x: delete character
d0: delete to beginning of line 
d$: delete from current position to end of word
"+dd: delete to system clipboard (verify `:echo has ('clipboard')` returns 1) 

recovering deletions
p: put GB after cursor - tends to make a new line and put the pasted text there
P: put GB before cursor - tends to paste text on same line as cursor

undo commands
u: undo last change
U: undo all changes on line

rearrangement commands
yy or Y: yank (copy) line to GB
yw: yank word to general buffer
"z6yy: yank 6 lines to buffer z
"a9dd: delete 9 lines to buffer a
"A9dd: delete 9 lines; append to buffer a
"ap: put text from general buffer a after the cursor
J: join lines
"+yy: copy to system clipboard (copy b/w vim windows) 
"+p: paste from system clipboard
