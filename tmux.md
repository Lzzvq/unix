https://tmuxcheatsheet.com/

# Basic controls 
Ctrl+b + % to split vertical, C-b + " to split horizontal
C-b + up arrow to resize window 
Justin does most of his stuff just in panes 
C-b + z to zoom in on one 
- can't scroll up in the :setw synchronize
    - zoom into a window, then `C-b + [` to be able to use page up 
- to get in/out of synchronized panes, C-b then `:setw synchronize-panes`
- `tmux a` will go back into the first session if tmux is quit and there are still sessions up 

- C-b + q to get pane numbers, and then quickly type the pane number after that to switch panes 

# Tmux basic tutorial 
https://www.youtube.com/watch?v=Yl7NFenTgIo
## Sessions
- create new session (unnamed) `tmux` w green bar at bottom & shows open windows 
    - window labeling starts at 0
    - asterisk indicates which window is selected 
- sessions preserve state of what is running in the session 
    - e.g. for long-running processes, tmux is able to continue in the background 
- ctrl+b + d to detach from session
- tmux ls view sessions 
- `tmux attach -t <session name>` (may be 0 if there's no name written) to reconnect to session 
- `tmux rename-session -t <current session name> <new session name>`
- `tmux new -s <session name>` create new session with specified session name 
- `tmux kill-session -t <session name>` to kill session 
## Panes 
- ctrl-b + % to create new pane to the right 
- ctrl-b + " to create new pane below 
- ctrl-b + arrow keys to switch between panes  
- exit to close out of each pane/session/window 
## Windows
- entirely new session, can be sorted by task meant to be achieved in each 
- ctrl-b + c
- ctrl-b + 0 to switch back to window 0
- ctrl-b + , to rename window 