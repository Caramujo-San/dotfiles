import os, subprocess

def main():
    # Check which OS is it
    operating_system = os.name

    if operating_system == 'nt':
        print("\n You are on Windows \n")
        
        # Prompt user for installing Windows softwares
        windows_software_install()
        
        # Clone repository from GitHub
        windows_git_clone_repo()
        
        # Link and overwrite files with repo files
        windows_dotfiles_overwrite()
          
    elif operating_system == 'posix':
        print("You are on Posix")
        
        # Prompt user for installing Linux softwares
    
    
# Ask if user wants to install winget list
def windows_software_install():
    
    # Intall Winget tool to install and manage applications
    # source: https://learn.microsoft.com/en-us/windows/package-manager/winget/
    winget_instal = subprocess.Popen(["$progressPreference", "=", "[string[]]silentlyContinue"])
    winget_instal.wait()
    winget_instal = subprocess.Popen(["Write-Information", "[string[]]Downloading WinGet and its dependencies..."])
    winget_instal.wait()
    winget_instal = subprocess.Popen(["Invoke-WebRequest", "-Uri", "https://aka.ms/getwinget", "-OutFile", "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"])
    winget_instal.wait()
    winget_instal = subprocess.Popen(["Invoke-WebRequest", "-Uri", "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx", "-OutFile", "Microsoft.VCLibs.x64.14.00.Desktop.appx"])
    winget_instal.wait()
    winget_instal = subprocess.Popen(["Invoke-WebRequest", "-Uri", "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx", "-OutFile", "Microsoft.UI.Xaml.2.7.x64.appx"])
    winget_instal.wait()
    winget_instal = subprocess.Popen(["Add-AppxPackage", "Microsoft.VCLibs.x64.14.00.Desktop.appx"])
    winget_instal.wait()
    winget_instal = subprocess.Popen(["Add-AppxPackage", "Microsoft.UI.Xaml.2.7.x64.appx"])
    winget_instal.wait()
    winget_instal = subprocess.Popen(["Add-AppxPackage", "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"])
    
    # Install programs with winget tool
    with open('software_winget_list.txt', 'r') as winget_list:
    
        for program in winget_list:
            
            answer_winget_list = input("Would you like to install {0} ? [Y / N]: ".format(program.rstrip('\n')))

            if answer_winget_list.lower() == 'y' or answer_winget_list.lower() == 'yes':
                winget_program = subprocess.Popen(["winget", "install", program])
                winget_program.wait()
                
            else:
                print("\n {0} was not chosen to be installed. \n".format(program.rstrip('\n')))
                continue
            
   
# Ask user to clone repository from GitHub      
def windows_git_clone_repo():
    
    answer_clone_repo = input("Would you like to clone the repo ? [Y / N]: \n")

    if answer_clone_repo.lower() == 'y' or answer_clone_repo.lower() == 'yes':
        clone_repo = subprocess.Popen(["git", "clone", "git@github.com:Caramujo-San/dotfiles.git"])
        clone_repo.wait()
        
    else:
        print("\n Repository was not cloned. \n")
        exit()
          
 
# Symbolic linking and overwriting files with repo files 
def windows_dotfiles_overwrite():
    

    exit_code = subprocess.call('./bootstrap.ps1')
    print(exit_code)

        

if __name__=='__main__':
    main()