# MyConfManager

## Options
- auto_load: whether to Apply the Load function (see below) automatically everytime a new buffer is opened.
    default: true
- conf_file_name: name that will be looked for.
    default: .nvim.lua
- auto_untrust: whether to untrust a trusted dir if the conf file has been modified.
    default: false
- unsafe_line_limit: number from which files are considered potentially unsafe.
    default: 200

## CMD Functions
All of these functions will be prefixed with MyConfManager.

- **Load**: Looks for config files in the directory. If it finds a config file, a pop up will appear with the following options:
     1) Load and trust current directory tree
     2) Load and trust current directory 
     3) Load
     4) Ignore

- **TrustList**: Shows the list of trusted paths
- **Untrust**: Untrusts a path
- **Trust**: Adds a path to the list of trusted paths

- **ChangeName**: Changes the name of the conf files to look for

## Additional noteworthy features
- Failsafe for files with 200 (default value) lines or more: Pop up asking whether to continue or cancel

## Ideas
vim.fn.stdpath("data")
vim.fn.json_


