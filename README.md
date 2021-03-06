puppet-baremetal-windows
========================

member of the rismoney suite of Puppet stuff. (not a provider)

## tl;dr: manage windows from baremetal to bar none

## Status
(work in progress - non functional)

## Goal:
1. PXE boot to WinPE
2. Run Puppet
3. OS installation
4. Run Puppet

## Overview
We're going to use the Windows ADK (specifically WinPE) and Puppet to fully bootstrap and configure a node.

What is [Puppet](www.puppetlabs.com)? Puppet is IT automation software that helps system administrators manage infrastructure throughout its lifecycle, from provisioning and configuration to patch management and compliance. Using Puppet, you can easily automate repetitive tasks, quickly deploy critical applications, and proactively manage change, scaling from 10s of servers to 1000s, on-premise or in the cloud.

## What is [ADK] (http://www.microsoft.com/en-us/download/details.aspx?id=30652)
Windows Deployment is for OEMs and IT professionals who customize and automate the large-scale installation of Windows, such as on a factory floor or across an organization. The Windows ADK supports this work with the deployment tools that were previously released as part of the OEM Preinstallation Kit (OPK) and the Windows Automated Installation Kit (AIK) and include Windows Preinstallation Environment, Deployment Imaging, Servicing and Management, and Windows System Image Manager. 

## Requirements - 
Minimum Win7+ Build host (could be a VM)
Windows ADK for Windows 8 (I chose this so we are not building around obsolescence 
Facter from Source
Puppet from Source
Ruby 1.87 (Puppet on Windows only supports 1.8.7 currently)
Gems - see the list here https://github.com/rismoney/puppet-baremetal-windows/blob/master/make_pe/config/config.ps1#L24-L35

## Relevant tidbits:
SysWow64 is not present in WinPE_x64 so we will use x86
EventViewer is not present in WinPE so we will patch puppet source (destinations.rb L254-258)

pxe server is your choice and is outside of scope.


## TODO

### After downloads
Download patch http://gnuwin32.sourceforge.net/downlinks/patch-bin-zip.php
Extractionss using 7zip

### WinPE Run (the actual work- some steps off the top of my head)
1. add ruby to path
2. install gems - Gemfile with :platform => 'mswin', :path => 'c:\gems'
3. install ruby devkit - config.yml needs x:\ruby187
4. facter (ruby install.rb)
5. puppet (ruby install.rb)
6. dynamically configure puppet.conf to use a cert_name thats not minint-*...maybe based on mac
7. patch destinations.pp 
8. run puppet agent interactively

### puppet config
1. erb template sysprep.xml
2. download driver set based on facter fact (tbd) make/model to $oem?
3. have puppet do a post run task, that runs setup against sysprep.xml (token replacement)
4. client and server os (win7,win8, win2008r2, win2012)

### optimization ideas
1. strip down winPE to only include bare minimum for speed
2. leverage hiera for puppet module
3. tune process for easy driver injection (probably nic and san are pain points)



# WHY?
I currently have complex build process for our nodes.  Its awesome, and I hope to open source it one day.
But it is unnecessarily complex, because we want our cake and eat it too.  Every host permutation conceivable
is what we do.  I want disparate perfect unattended builds on unique hardware everytime.
The same build bootstrap system for desktops, laptops, servers, etc.  And I want it DONE with 1 command to set 
set it all up.  

Currently I have a minimalist sysprep, and perform a series of tasks post setup based on a series of 
version controlled files csv, yaml and txt file.  This process is now 15 steps, and requires a ton of reboots.
Everything from domain joins, renames, driver loads requires rebooting, dot net 4, you name it.
This is an experiment to make 1 step.  To have one data source hiera yaml files.  To eliminate powershell scripts
wherever possible.  To leverage the logic needed to build any type of host you want, just by editing a file
stored in version control.
