<#
.DESCRIPTION
    Install programs with winget from .txt list 
    and 
    Creates a symlink between two files on windows
#>


# Get the content of winget programs' ids to variable $SoftwareList
$SoftwareListFile = ".\software_winget_list.txt"
[string[]]$SoftwareList = Get-Content $SoftwareListFile



#------------------------------------------------------------#
#                    Functions definitions                   |
#------------------------------------------------------------#


# Install programs in the software_winget_list.txt file
function Install-Programs {

    [CmdletBinding(
        SupportsShouldProcess=$True, # Allows the use of -Confirm and -Whatif
        ConfirmImpact="Medium" # Confirms before installing
    )]
    param (
        [Parameter(Mandatory=$True)]
        [string]$WingetCommandParam,
        [Parameter(Mandatory=$True)]
        [string]$program2
    )

    Begin {
	    # Uncomment the line below to activate -whatif
        # $WhatIfPreference = $True 
	
	    # Uncomment the line below not to ask for confirmation to install
		# $ConfirmPreference = "High"
	}

    # Contains the main part of the function
    Process {
        # Debug message
        Write-Debug "Installing program..."
        # If the user confirmed Yes, or user didn't use -Confirm
        if ($PSCmdlet.ShouldProcess($program)) {
            Write-Host "`n"
            &winget $WingetCommandParam -e --id $program2
        }
        else {
            Write-Host $program2 " will not be installed."
            return -1
        }
    }
}


# ----------------------------------------------------


# Creates a Symlink between two files
Function Add-Symlink {
    [CmdletBinding(
        SupportsShouldProcess=$True, # Allows the use of -Confirm and -Whatif
        ConfirmImpact="Medium" # Confirms before linking
    )]
    param (
        [Parameter(Mandatory=$True)]
        [string]$from,
        [Parameter(Mandatory=$True)]
        [string]$to
    )

    Begin {
	    # Uncomment the line below to activate -whatif
	    # $WhatIfPreference = $True
	
	    # Uncomment the line below not to ask for confirmation when moving each file
		# $ConfirmPreference = "High"
	}

    # Contains the main part of the function
    Process {
        # Debug message
        Write-Debug "Symlinking file..."
        # If the user confirmed Yes, or user didn't use -Confirm
        if ($PSCmdlet.ShouldProcess($from, $to)) {
            New-Item -ItemType SymbolicLink -Path $from -Target $to -Force
        }
        else {
            Write-Host "Files will not be linked."
            return -2
        }
    }
}


#------------------------------------------------------------#
#                     Functions calls                        |
#------------------------------------------------------------#


# Checks if winget command is currently available on Powershell
if (!(Get-Command winget -ErrorAction Stop)) {
    Write-Host "Winget not found, unable to continue"
    Write-Host "Check on https://github.com/microsoft/winget-cli for instructions"
    exit -3
}
else {
    Write-Host "`nWinget command-line tool is available."
}

# Search or install
Write-Output "This script will attempt to install multiple softwares on your system"
$DoInstall = Read-Host -Prompt "To install programs, type 'install' to continue"
if ($DoInstall -eq "install") {
    $WingetCommandParam = $DoInstall

    # Prompt user to install each program
    foreach ($program1 in $SoftwareList) {
        Install-Programs $WingetCommandParam $program1 -Confirm 
    }
}
else {
    # $WingetCommandParam = "search";
    $DebugPreference = "Continue"
    Write-Debug -Message "You typed the word '$DoInstall'" 
    Write-Host "    Exiting installation...`
    ...Now trying configuration`n"
}


# ----------------------------------------------------


# Array with software name from software_winget_list
$software_names = @(
    "4KVideoDownloader",
    "Anki",
    "Apache Xampp",
    "Calibre",
    "Git",
    "JetBrains.Toolbox",
    "Microsoft Visual Studio Code",
    "Microsoft Windows Terminal",
    "OBSProject.OBSStudio",
    "OpenOffice",
    "JavaRuntimeEnvironment",
    "Oracle.VirtualBox",
    "PostgreSQL",
    "R",
    "Posit.RStudio",
    "Rustlang.Rustup",
    "Slack",
    "StarUML",
    "VideoLAN.VLC",
    "WinRAR",
    "Assistente de Instalação do Windows 11",
    "Wireshark",
    "Wondershare PDFelement"
)

# Nested hashtable with programs' name, fromFilePath and toFilePath
$path_list_programs = [ordered]@{
    ".gitconfig" = @{
        storePackages = "${HOME}\.gitconfig"
        fromFilePath = "${HOME}\.gitconfig"
        toFilePath = "${PSScriptRoot}\.gitconfig"
    }
    ".gitignore" = @{
        storePackages = "${HOME}\.gitignore"
        fromFilePath = "${HOME}\.gitignore"
        toFilePath = "${PSScriptRoot}\.gitignore"
    }
    "profile" = @{
        storePackages = "${HOME}\Documents\WindowsPowerShell"
        fromFilePath = "${PROFILE}"
        toFilePath = "${PSScriptRoot}\powershell\Microsoft.PowerShell_profile.ps1"
    }
    "vlc" = @{
        storePackages = "${HOME}\AppData\Roaming\vlc\"
        fromFilePath = "${HOME}\AppData\Roaming\vlc\vlcrc"
        toFilePath = "${PSScriptRoot}\VLC media player\vlcrc"
    }
    "windows_terminal" = @{
        storePackages = "${HOME}\AppData\Local\Packages\*Microsoft.WindowsTerminal*"
        fromFilePath = "${programDir}\LocalState\settings.json"
        toFilePath = "${PSScriptRoot}\terminal\settings.json"
    }
}

# Symlink software config files
$DoSymlink = Read-Host -Prompt "To customize with your own configuration files, type 'symlink' to continue"
if ($DoSymlink -eq "symlink") {
    $WingetCommandParam = $DoSymlink
    
    # Check if file exists and Prompt user to Symlink
    foreach ($name in $path_list_programs.keys) {

        $programName = $path_list_programs[$name]

        # get child items from $StorePackages path in $path_list_programs above
        Write-Output "Checking for existing files..."
        $StorePackages = $programName.storePackages
        $programDir = Get-ChildItem $StorePackages -ErrorAction SilentlyContinue

        # Prompt user to Symlink between each pair of files
        if ($programDir) {
            Write-Output "Found $name on ${programDir}, create symlink ?"
            Add-Symlink $programName.fromFilePath $programName.toFilePath > $null -Confirm
        }
    }
}
else {
    # $WingetCommandParam = "search";
    Write-Host "`nExiting customization..."
    Write-Host "Have a nice day !`n"
    Exit -4
}


# VSCode settings
Write-Output "Attempting to Replace VSCode settings"
$VSCodeDir = "${HOME}\AppData\Roaming\Code"
if (Get-ChildItem $VSCodeDir -ErrorAction SilentlyContinue) {
    Write-Output "Found VSCode on User's AppData, creating symlink"
    Add-Symlink "${VSCodeDir}\User\settings.json" "${PSScriptRoot}\vscode\settings.json"  > $null -Confirm
    Add-Symlink "${VSCodeDir}\User\keybindings.json" "${PSScriptRoot}\vscode\keybindings.json"  > $null -Confirm
    # Clear snippets before attempting to link
    Get-Item "${VSCodeDir}\User\snippets\" -ErrorAction SilentlyContinue |
    Remove-Item -Force -Recurse
    Add-Symlink "${VSCodeDir}\User\snippets\" "${PSScriptRoot}\vscode\snippets\" > $null -Confirm
}

Write-Warning "If you see Powershell Profile errors you'll want to run ./powershell/setup/install_pwsh_modules.ps1 as well"
Write-Output "If this is a really fresh install run install_softwares.ps1 to get going"
Write-Output "Done, your profile will be reloaded"
Write-Output "`n"

# Reloads the Profile
. {$PROFILE}
