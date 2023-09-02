<# 
.LINK
    https://github.com/microsoft/winget-cli/blob/master/doc/Completion.md
.LINK
    https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/tab-completion?view=powershell-7.3
#>

# Shows navigable menu of all options when hitting Tab

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete


# Register-ArgumentCompleter script for the Windows Package Manager tool. 
# It allows for completion of command names, argument names, and argument values, 
# dependent on the current command line state.

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}


# Setting alias for locating a file or directory

function Locate-Files {
    <#
	.LINK
	https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/set-alias?view=powershell-7.3

	.LINK
	https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.3
    #>
	
    [CmdletBinding(
        SupportsShouldProcess=$True
    )]
    param (
        [Parameter(Mandatory=$True)]
        [string]$FileOrDirectory
    )

    Begin {
	    # Uncomment the line below to activate -whatif
        # $WhatIfPreference = $True 
	}

    # Contains the main part of the function
    Process {
        # Get-ChildItem cmdlet with 
        Get-ChildItem -Recurse | where {$_.Name -like $FileOrDirectory} | select FullName
    }
}

Set-Alias -Name locate -Value Locate-Files


# Setting alias for Get-Help cmdlet

Set-Alias -Name help -Value Get-Help