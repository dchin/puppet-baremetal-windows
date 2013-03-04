function download-winbits {

# this can probably be cleaned up.  I wanted this to work first
# and then i can wrap Get-WebFile 


  # create download folder if it doesnt exist
  if (-not(test-path -path $downloadfolder)) {
    mkdir -p $downloadfolder
  }

  #create mount folder if it doesnt exist
  if (-not(test-path -path $mountfolder)) {
    mkdir -p $mountfolder
  }

  #create gems folder if it doesnt exist
  if (-not(test-path -path "$downloadfolder\gems")) {
    mkdir -p "$downloadfolder\gems"
  }

  
  #create adk folder if it does not exist
  if (-not(test-path -path "$downloadfolder\adk")) {
    mkdir -p "$downloadfolder\adk"
  }

  foreach ($url in $adklist) {
    $adkname = $url.Substring($url.LastIndexOf("/") + 1)
    $adkname = join-path "$downloadfolder\adk" $adkname
    if (-not(test-path -path "$adkname")) {
      Get-WebFile $url $adkname
    }
    else {write-output "Skipping download $adkname"}
  }


  if (-not(test-path -path "$zipfile")) {Get-WebFile $zipurl $zipfile}
  else {write-output "Skipping download $zipfile"}


  if (-not(test-path -path "$rubyfile")) {Get-WebFile $rubyurl $rubyfile}
  else {write-output "Skipping download $rubyfile"}

  
  if (-not(test-path -path "$devkitfile")) {Get-WebFile $devkit $devkitfile}
  else {write-output "Skipping download $devkitfile"}

  if (-not(test-path -path "$facterfile")) {Get-WebFile $facter $facterfile}
  else {write-output "Skipping download $facterfile"}

  if (-not(test-path -path "$puppetfile")) {Get-WebFile $puppeturl $puppetfile}
  else {write-output "Skipping download $puppetfile"}



  # install gems
  foreach ($gem in $gemlist) {
    $gemfile = $gem.Substring($gem.LastIndexOf("/") + 1)
    $gemfile = join-path "$downloadfolder\gems" $gemfile
    if (-not(test-path -path "$gemfile")) {
      Get-WebFile $gem $gemfile
    }
  }
}