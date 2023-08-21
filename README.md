# dotfiles
                                 
my personal configuration dotfiles

* Windows dotfiles
* Linux dotfiles

*If you want to use it consider forking it and changing it to fit your own needs*, don't go around blindly running scripts from the internet!

> This is an old-school way to JetBrains Setting Sync/OneDrive/Google Sync/ your settings. At least those that are *easy to automate*.

A `dotfiles` repository is an attempt to keep multiple settings in-sync across multiple environments **without relying on external solutions.** Basically once you have this repository done all you gotta do is `git clone` it into a new environment and run the `bootstrap` script.

--------------

### Reference sources

1. (https://www.jetbrains.com/help/idea/sharing-your-ide-settings.html#IDE_settings_sync)
2. (https://dotfiles.github.io/)
3. (https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789)

Technique used for this repo:

* Symbolic links linking a git repo in Desktop on Windows
  1. Created a Python script to install and call a Powershell script
  2. crafted a Powershell script to link the files
  1. Check out the repo (https://github.com/rodolphocastro/dotfiles/blob/master/bootstrap.ps1)

* Storing a Git bare repository in a "side" folder .cfg on Linux 
   1. Created a git bare repository
   2. crafted alias so that commands are run against that repository and not the usual .git local folder, which would interfere with any other Git repositories around.
   3. Check out the website (https://www.atlassian.com/git/tutorials/dotfiles)
  
--------------

## Windows dotfiles

1. Git clone the repo or download it to the Desktop 
2. Change directory to the dotfiles folder
3. Then run the bootstrap.py

--------------

## Linux dotfiles

1. Run bootstrap.py in the $HOME directory

After setup executed, any file within the $HOME folder can be versioned with normal commands, replacing git with config alias.

```
config status
config add .bashrc
config commit -m "Add bashrc"
config push
```
