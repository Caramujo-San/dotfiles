<#
.DESCRIPTION
    Install programs with winget from .txt list 
    and 
    Creates a symlink between two files on windows
#>


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
            Write-Output "`n"
            Winget $WingetCommandParam -e --id $program2
        }
        else {
            Write-Output $program2 " will not be installed."
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
            Write-Output "Files will not be linked."
            return -2
        }
    }
}


#------------------------------------------------------------#
#                     Functions calls                        |
#------------------------------------------------------------#

# Check if there is a json list
if (!(Get-ChildItem ".\software_winget_list.json")) {
    # Get list of packages intalled on system
    Write-Verbose "Do you want to get list of packages intalled on this system ?"
    Winget export -o ".\software_winget_list.json" -Confirm
}

# Get winget programs list to variable $SoftwareList
$SoftwareList = Get-Content -Path ".\software_winget_list.json" | ConvertFrom-Json



# Nested hashtable with programs' name, and paths fromFilePath and toFilePath to be linked
<#
.NOTES
    'storePackages' nested key in hashtable is used for 
    checking if file exists before symlinking
#>
$path_list_programs = [ordered]@{
    # "4KVideoDownloader"
    # "Anki"
    # "Apache Xampp"
    # "Calibre"
    # "Eclipse Temurin JDK with Hotspot"
    # "Git"
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
    # "JetBrains.Toolbox"
    # "OBSProject.OBSStudio"
    # "OpenOffice"
    # "Oracle.VirtualBox"
    # "JavaRuntimeEnvironment"
    # "PostgreSQL"
    "profile" = @{
        storePackages = "${HOME}\Documents\WindowsPowerShell"
        fromFilePath = "${PROFILE}"
        toFilePath = "${PSScriptRoot}\powershell\Microsoft.PowerShell_profile.ps1"
    }
    # "R"
    # "Posit.RStudio"
    # "Rustlang.Rustup"
    # "Slack"
    # "StarUML"
    "VideoLAN.VLC" = @{
        storePackages = "${HOME}\AppData\Roaming\vlc\"
        fromFilePath = "${HOME}\AppData\Roaming\vlc\vlcrc"
        toFilePath = "${PSScriptRoot}\VLC media player\vlcrc"
    }
    "VsCode" = @{
        storePackages = "${HOME}\AppData\Roaming\Code\User\"
        fromFilePath = "${HOME}\AppData\Roaming\Code\User\settings.json"
        toFilePath = "${PSScriptRoot}\vscode\settings.json"
    }
    # "WinRAR"
    # "Wireshark"
    # "Wondershare PDFelement"
    # "Assistente de Instalação do Windows 11"
    # "Microsoft Visual Studio Code"
    "Microsoft Windows Terminal" = @{
        storePackages = "${HOME}\AppData\Local\Packages\*Microsoft.WindowsTerminal*"
        fromFilePath = "${programDir}\LocalState\settings.json"
        toFilePath = "${PSScriptRoot}\terminal\settings.json"
    }
}


# ----------------------------


# Checks if winget command is currently available on Powershell
if (!(Get-Command winget -ErrorAction Stop)) {
    Write-Output "Winget not found, unable to continue"
    Write-Output "Check on https://github.com/microsoft/winget-cli for instructions"
    exit -3
}
else {
    Write-Output "`nWinget command-line tool is available."
}

# Search or install
Write-Output "This script will attempt to install multiple softwares on your system"
$DoInstall = Read-Host -Prompt "To install programs, type 'install' to continue"

if ($DoInstall -eq "install") {
    $WingetCommandParam = $DoInstall

    # Prompt user to install each program
    foreach ($program1 in $SoftwareList.Sources.Packages) {
        $InstallProg = Read-Host -Prompt "Install $program1 ? [Yes / No / 'q' for cancel]"

        if ($InstallProg -eq "Y".ToLower()) {
            Install-Programs $WingetCommandParam $program1 

        } elseif ($InstallProg -eq "Q".ToLower()) {
            Write-Verbose "Quitting installation...`n"
            break
        }
    }
}
else {
    # $WingetCommandParam = "search";
    $DebugPreference = "Continue"
    Write-Debug -Message "You typed the word '$DoInstall'" 
    Write-Output "    Exiting installation...`
    ...Now trying configuration`n"
}


# ----------------------------


# Symlink software config files
$DoSymlink = Read-Host -Prompt "To customize with your own configuration files, type 'symlink' to continue"

if ($DoSymlink -eq "symlink") {
    $WingetCommandParam = $DoSymlink
    
    # Check if file exists and Prompt user to Symlink
    foreach ($name in $path_list_programs.keys) {

        $programName = $path_list_programs[$name]

        # get child items from $StorePackages path on hashtable in $path_list_programs above
        Write-Output "Checking for existing files..."
        $StorePackages = $programName.storePackages
        $programDir = Get-ChildItem $StorePackages -ErrorAction SilentlyContinue

        # Prompt user to Symlink between each pair of files
        $DOsymlink = Read-Host -Prompt "Install $program1 ? [Yes / No / 'q' for cancel]"

        if ($programDir -and ($DOsymlink -eq "Y".ToLower())) {
            Write-Output "Found $name on ${programDir}, creating symlink..."
            Add-Symlink $programName.fromFilePath $programName.toFilePath > $null

        } elseif ($DOsymlink -eq "Q".ToLower()) {
            Write-Verbose "Quitting symlinking...`n" 
            break
        }
    }
}
else {
    # $WingetCommandParam = "search";
    Write-Output "Exiting customization..."
    Write-Output "Have a nice day !`n"
    Exit -4
}


Write-Output "Done, your profile will be reloaded"
try {
    # Reloads the Profile
    $Reload = . {$PROFILE}
    $Reload
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Output $Reload.Exception.Message
}