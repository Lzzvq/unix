# Mounting Volumes on Linux
- `sudo -s` to start, or append all with sudo
- `lsblk` to get volume name
- `mkfs -t xfs /dev/<volume-name>` to format the volume
- `mkdir /dir/to/mount/to` to have a directory to mount the volume to
- `mount /dev/<volume-name> /dir/to/mount/to` to mount the volume to the directory

## Creating fstab entry
- `sudo -s` still doing sudo stuff
- `cp /etc/fstab /etc/fstab.orig` to create a backup of the fstab
- `blkid` to get UUID of volume for use in fstab
- `vi /etc/fstab` and add `UUID=<string-from-previous-step> /dir/to/mount/to xfs defaults,nofail 0 2` at the bottom of the file (type `G` `o`in vi to go to the bottom and make a new line under the last line)
- `umount /dir/to/mount/to` then `mount -a` to test that the directory automatically mounts 

# grep
- to list X entries that grep returns (instead of all of them): `history | grep -m X <query>` where X is how many entries to list 

# zsh
- In iTerm2 with zsh, go to settings > profiles > keys > key mappings > presets and can set 'Natural Text Editing' to use the normal shortcuts of macOS to move around text 
- to list X entries of history (instead of all of it): `history -X` where X is how many entries to list, this way output isn't wiped out when looking for a historical command 

## creating new aliases
https://stephencharlesweiss.com/oh-my-zsh-and-persistent-aliases
TLDR add to `~/.oh-my-zsh/custom/` and either to aliases.zsh or another .zsh file in that dir. `source ~/.zshrc` to get the terminal to grab the new aliases


## Ryan's Oh My Zsh configuration
https://bitbucket.di2e.net/users/ryan.hammond/repos/zshrc/browse
look for p10k for prompt creator 
```
  # show aws-vault profile
  function prompt_vault() {
    if [[ -z $AWS_VAULT ]]; then
      # No 'AWS_VAULT' environment var
      return
    fi
    #p10k segment -b 116 -f 3 -t $AWS_VAULT
    p10k segment -b 116 -f 016 -t $AWS_VAULT
  }
``` 

# Searching help pages 
- I saw Doug search through a help page with `aws backup --help | rg -i <search-term>`
    - rg -i sorts through the aws backup help page and only returns items that match the term, instead of having to scroll through the the whole help page 

# zip
- I was having real challenges getting all files within a deep directory structure all zipped into one thing
- I had a single dir I wanted to zip, and it had files and directories all the way throughout that I wanted to get all of
- what I ended up doing was cd'ing into the directory, then `zip -r <zip-name>.zip *` to recursively grab everything in the dir, then moved the zip out of the dir and deleted the dir (so I could push to github)

# Bastion ssh 
## If bastion and private instance both use the same key to authenticate
- `ssh-add -k PEMfilename.pem`
- `ssh -A <username>@bastion.host.public.ip`
- once in bastion, `ssh <username>@private.host.public.ip`

# AWS CLI
## View user data
- for smaller bits of userdata, that don't need to be zipped
  `INSTANCE=<instance-id>; aws-vault exec <profile> -- aws ec2 describe-instance-attribute --instance-id $INSTANCE --attribute userData --output text --query "UserData.Value"  | base64 --decode`
  - if this returns machine-language gobbldey-gook, will need to zip the values
- for larger bits of userdata
  `INSTANCE=<instance-id>; aws-vault exec <profile> -- aws ec2 describe-instance-attribute --instance-id $INSTANCE --attribute userData --output text --query "UserData.Value"  | base64 --decode > userdata.gz | gunzip -c`
  - then need to unzip with `gunzip userdata.gz` then can `vi userdata`

# Searching
## For a term in a file
- `grep -rnwi '/path/to/somewhere/' -e 'pattern'` 
  - recursive, line number, match whole word, case insensitive 
  - path to somehwere can also point directly to a file 
  - GREP IS CASE-SENSITIVE
  - `grep -i '/path/to/somewhere/file.file' -e 'pattern'` does just about the same thing 

# SCP 
- basic syntax
  - `scp username@source:/location/to/file username@destination:/where/to/put`
- from remote to local
  - `scp username@remote:/file/to/send /where/to/put`