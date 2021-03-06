function build-wim {

  # Create the WinPE working folder 
  if (-not(test-path -path $winpefolder)) {
    mkdir -p $winpefolder
  }
  else {
    rename-item $winpefolder "$winpefolder-$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
    mkdir -p $winpefolder
  }

  # copy winpe wim to our working folder
  $winpewim = "$adkfolder\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\en-us\winpe.wim"
  copy $winpewim $winpefolder

  #mount the wim
  try {
    $winpewim_file="$winpefolder\winpe.wim"
    $imagex_mount_arg="/mountrw $winpewim_file 1 $mountfolder"
    Start-Process "$imagex" -ArgumentList $imagex_mount_arg -NoNewWindow -Wait -ea stop
  }
  catch {
    write-output "error mounting wim"
    exit 1
  }

  # perform all the extractions to the mount folder
  unzip-winbits

  echo d | xcopy /S /Y "$downloadfolder\ruby-1.8.7-p371-i386-mingw32\*.*" "$mountfolder\Ruby187"
  
  #copy gems file to the mount
  echo d | xcopy /S /Y "$downloadfolder\gems" "$mountfolder\gems\"

  # drop in the devkit config file with x:\ruby187
  echo d | xcopy /Y "$config\config.yml" "$mountfolder\devkit"

  # patch puppet source to not use eventlog (n/a in WinPE)
  cmd /c "$mountfolder\patch\bin\patch.exe --force -d $mountfolder\puppet-2.7.x\lib\puppet\util\log -p 0 < $patchfolder\destinations.rb.patch"

  #win pe startup scripts
  echo d |xcopy /Y "$runtimefolder\startnet.cmd" "$mountfolder\Windows\System32"
  echo d |xcopy /Y "$runtimefolder\custom.ps1" "$mountfolder"
  echo d |xcopy /Y "$runtimefolder\host-enforce.ps1" "$mountfolder"
  # echo d |xcopy /Y "$config\GemFile" "$mountfolder"

  add-packages
  
  try {

    $imagex_mount_arg="/unmount /commit $mountfolder"
    Start-Process "$imagex" -ArgumentList $imagex_mount_arg -NoNewWindow -Wait -ea stop
  }
  catch {
    write-output "error unmounting"
    exit 1
  }
}