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
        [string]$program
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
            &winget $WingetCommandParam -e --id $program
        }
        else {
            Write-Host $program " will not be installed."
            return -1
        }
    }
}


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
    exit -1
}
else {
    Write-Host "`nWinget command-line tool is available."
}

# Search or install
Write-Output "This script will attempt to install multiple softwares on your system"
$DoInstall = Read-Host -Prompt "To install programs, type 'install' to continue. Else Winget will just search"
if ($DoInstall -eq "install") {
    $WingetCommandParam = $DoInstall
}
else {
    $WingetCommandParam = "search";
}

# Prompt user to install each program
foreach ($program in $SoftwareList) {
    Install-Programs $WingetCommandParam $program -Confirm 
}


# Creates a Symlink between files
Write-Output "Replacing .gitconfig"
Add-Symlink "${HOME}\.gitconfig" "${PSScriptRoot}\.gitconfig" > $null -Confirm
Write-Output "Replacing .gitignore"
Add-Symlink "${HOME}\.gitignore" "${PSScriptRoot}\.gitignore" > $null -Confirm

Write-Output "Replacing Powershell Profile"
Add-Symlink "${PROFILE}" "${PSScriptRoot}\powershell\Microsoft.PowerShell_profile.ps1" > $null -Confirm

Write-Output "Attempting to Replace Windows Terminal settings"
$StorePackages = "${HOME}\AppData\Local\Packages\*Microsoft.WindowsTerminal*"
$WindowsTerminalDir = Get-ChildItem $StorePackages -ErrorAction SilentlyContinue
if ($WindowsTerminalDir) {
    Write-Output "Found WindowsTerminal on ${WindowsTerminalDir}, creating symlink"
    Add-Symlink "${WindowsTerminalDir}\LocalState\settings.json" "${PSScriptRoot}\terminal\settings.json" > $null -Confirm
}

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
. $PROFILE
