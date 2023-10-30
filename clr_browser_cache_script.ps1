#------------------------------------------------------------------#
#- Removes Stored Pwsds-Chrome                                     #
#------------------------------------------------------------------#

Function RemovesPwd {
    param([string]$user=$env:USERNAME)
    Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Login Data" -Force -ErrorAction SilentlyContinue
     Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\Login Data" -Force -ErrorAction SilentlyContinue 
}

#------------------------------------------------------------------#
#- Clear-WindowsUserCacheFiles                                     #
#------------------------------------------------------------------#

Function Clear-WindowsUserCacheFiles {
    param([string]$user=$env:USERNAME)
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Temp"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\WER"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files"    
}

#------------------------------------------------------------------#
#- Clear-GlobalWindowsCache                                        #
#------------------------------------------------------------------#

Function Clear-GlobalWindowsCache {
    Remove-CacheFiles 'C:\Windows\Temp' 
    Remove-CacheFiles "C:\`$Recycle.Bin"
    Remove-CacheFiles "C:\Windows\Prefetch"
    C:\Windows\System32\rundll32.exe InetCpl.cpl, ClearMyTracksByProcess 255
    C:\Windows\System32\rundll32.exe InetCpl.cpl, ClearMyTracksByProcess 4351
}

#------------------------------------------------------------------#
#- Clear-ChromeCache                                               #
#------------------------------------------------------------------#

Function Clear-ChromeCache {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Google\Chrome\User Data\Default"))
    {
        $chromeAppData = "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default" 
        $possibleCachePaths = @('Cache','Cache2\entries\','Cookies','History','Top Sites','VisitedLinks','Web Data','Media Cache','Cookies-Journal','ChromeDWriteFontCache')
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$chromeAppData\$cachePath"
        }      
    } 
}

#------------------------------------------------------------------#
#- Clear-MsEdgeCache                                               #
#------------------------------------------------------------------#

Function Clear-MsEdgeCache {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Microsoft\Edge\User Data\Default"))
    {
        $msedgeAppData = "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default" 
        $possibleCachePaths = @('Cache','Cache2\entries\','Cookies','History','Top Sites','VisitedLinks','Web Data','Media Cache','Cookies-Journal','Cache_Data')
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$msedgeAppData\$cachePath"
        }      
    } 
}

#------------------------------------------------------------------#
#- Clear-UserCacheFiles                                            #
#------------------------------------------------------------------#

Function Clear-UserCacheFiles {
    Kill-BrowserSessions
    ForEach($localUser in (Get-ChildItem 'C:\users').Name)
    {
        Clear-ChromeCache $localUser
        Clear-MsEdgeCache $localUser
        Clear-FirefoxCacheFiles $localUser
        Clear-WindowsUserCacheFiles $localUser

    }
}

#------------------------------------------------------------------#
#- Clear-FirefoxCacheFiles                                         #
#------------------------------------------------------------------#

Function Clear-FirefoxCacheFiles {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Mozilla\Firefox\Profiles"))
    {
        $possibleCachePaths = @('cache','cache2\entries','thumbnails','cookies.sqlite','webappsstore.sqlite','chromeappstore.sqlite')
        $firefoxAppDataPath = (Get-ChildItem "C:\users\$user\AppData\Local\Mozilla\Firefox\Profiles" | Where-Object { $_.Name -match 'Default' }[0]).FullName 
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$firefoxAppDataPath\$cachePath"
        }
    } 
}

#------------------------------------------------------------------#
#- Clear-WaterfoxCacheFiles                                        #
#------------------------------------------------------------------#

Function Clear-WaterfoxCacheFiles { 
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Waterfox\Profiles"))
    {
        $possibleCachePaths = @('cache','cache2\entries','thumbnails','cookies.sqlite','webappsstore.sqlite','chromeappstore.sqlite')
        $waterfoxAppDataPath = (Get-ChildItem "C:\users\$user\AppData\Local\Waterfox\Profiles" | Where-Object { $_.Name -match 'Default' }[0]).FullName
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$waterfoxAppDataPath\$cachePath"
        }
    }   
}

#------------------------------------------------------------------#
#- Kill-BrowserSessions                                            #
#------------------------------------------------------------------#

Function Kill-BrowserSessions {
    $activeBrowsers = Get-Process Firefox*,Chrome*,Waterfox*,Msedge*,MicrosoftEdge*
    ForEach($browserProcess in $activeBrowsers)
    {
        try 
        {
            $browserProcess.CloseMainWindow() | Out-Null 
        } catch { }
    }
}

#------------------------------------------------------------------#
#- Remove-CacheFiles                                               #
#------------------------------------------------------------------#

Function Remove-CacheFiles {
    param([Parameter(Mandatory=$true)][string]$path)    
    BEGIN 
    {
        $originalVerbosePreference = $VerbosePreference
        $VerbosePreference = 'Continue'  
    }
    PROCESS 
    {
        if((Test-Path $path))
        {
            if([System.IO.Directory]::Exists($path))
            {
                try 
                {
                    if($path[-1] -eq '\')
                    {
                        [int]$pathSubString = $path.ToCharArray().Count - 1
                        $sanitizedPath = $path.SubString(0, $pathSubString)
                        Remove-Item -Path "$sanitizedPath\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                    }
                    else 
                    {
                        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose              
                    } 
                } catch { }
            }
            else 
            {
                try 
                {
                    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue -Verbose
                } catch { }
            }
        }    
    }
    END 
    {
        $VerbosePreference = $originalVerbosePreference
    }
}

#------------------------------------------------------------------#
#- MAIN                                                            #
#------------------------------------------------------------------#

Clear-UserCacheFiles
Clear-GlobalWindowsCache
RemovesPwd