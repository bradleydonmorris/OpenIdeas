. ([IO.Path]::Combine([IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($PSCommandPath)), ".init.ps1")) -RequiredModules @(
    "WebServer"
);

#$Global:Session.Config is automatically loaded if a sibling file with an extension of .config.json is found for this script.

$Global:Session.Logging.WriteVariables("Valirables", @{
    "ListeningURIs" = $Global:Session.Config.ListeningURIs;
});
$Global:Session.WebServer.Start($Global:Session.Config.ListeningURIs);
If ($Global:Session.WebServer.IsListening())
{
    Write-Host "HTTP Server Running" -ForegroundColor Black -BackgroundColor Green;
    Write-Host "Listening on..." -ForegroundColor Green -BackgroundColor Black;
    ForEach ($Prefix In $Global:Session.WebServer.Listener.Prefixes)
    {
        Write-Host $Prefix -ForegroundColor Green -BackgroundColor Black;;
    }
}


# [String] $HostNameOrIP = "localhost";
# [Int32] $Port = 8091;
# [String[]] $ListeningURIs = @(
#     "http://" + $HostNameOrIP + ":" + $Port.ToString() + "/"
# );
# $http = [System.Net.HttpListener]::new()
# ForEach ($ListeningURI In $ListeningURIs)
# {
    
#     $http.Prefixes.Add($ListeningURI);
# }
#$http.Start();
# if ($http.IsListening) {
#     Write-Host "HTTP Server Running" -ForegroundColor Black -BackgroundColor Green;
#     Write-Host "Listening on..." -ForegroundColor Green -BackgroundColor Black;
#     ForEach ($Prefix In $http.Prefixes)
#     {
#         Write-Host $Prefix;
#     }
# # }
# [Collections.Hashtable] $routeFunctions = [Collections.Hashtable]::new();
# [RouteCommand] $OneTwo = [RouteCommand]::new();
# $OneTwo.Route = "/one/two";
# $OneTwo.Method = "Get";
# $OneTwo.Command = [scriptblock]::Create({
#     Param
#     (
#         [Parameter(Mandatory=$true)]
#         [System.Net.HttpListenerContext] $context
#     )
#     Write-Host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'
#     [String] $html = "<h1>A Powershell Webserver</h1><p>One / Two</p>";
#     $buffer = [System.Text.Encoding]::UTF8.GetBytes($html);
#     $context.Response.ContentLength64 = $buffer.Length;
#     $context.Response.OutputStream.Write($buffer, 0, $buffer.Length);
#     $context.Response.OutputStream.Close();
# })

# [void] $routeFunctions.Add($OneTwo.Route, $OneTwo);


$Global:Session.WebServer.AddRouteCommand("/logs", "Get", [scriptblock]::Create({
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerContext] $Context
    )
    Write-Host "$($Context.Request.UserHostAddress)  =>  $($Context.Request.Url)" -f 'mag'
    [String] $Level = "Logs";
    [String] $Project = [String]::Empty;
    [String] $Job = [String]::Empty;
    [String] $Group = [String]::Empty;
    If ($Context.Request.QueryString.AllKeys.Contains("Project"))
    {
        $Project = $Context.Request.QueryString["Project"];
        $Level = "Project";
    }
    If ($Context.Request.QueryString.AllKeys.Contains("Job"))
    {
        $Job = $Context.Request.QueryString["Job"];
        $Level = "Job";
    }
    If ($Context.Request.QueryString.AllKeys.Contains("Group"))
    {
        $Group = $Context.Request.QueryString["Group"];
        $Level = "Group";
    }
    [System.Text.StringBuilder] $StringBuilder = [System.Text.StringBuilder]::new();
    If ($Level -eq "Logs")
    {
        [void] $StringBuilder.Append("<h1>Projects</h1>");
        ForEach ($Item In (Get-ChildItem -Path $Global:Session.Directories.LogsRoot | Where-Object -FilterScript { $_.PSIsContainer }))
        {
            [void] $StringBuilder.Append("<h3><a href=`"/logs?Project=" + $Item.Name + "`">" + $Item.Name + "</a></h3>");
        }
    }
    ElseIf ($Level -eq "Project")
    {
        [void] $StringBuilder.Append("<h1>Jobs</h1>");
        ForEach ($Item In (Get-ChildItem -Path ([IO.Path]::Combine($Global:Session.Directories.LogsRoot, $Project)) | Where-Object -FilterScript { $_.PSIsContainer }))
        {
            [void] $StringBuilder.Append("<h3><a href=`"/logs?Project=" + $Project + "&Job=" + $Item.Name + "`">" + $Item.Name + "</a></h3>");
        }
    }
    ElseIf ($Level -eq "Job")
    {
        [void] $StringBuilder.Append("<h1>Logs</h1>");
        [Collections.ArrayList] $LogGroups = [Collections.ArrayList]::new()
        ForEach ($LogFileItem In (Get-ChildItem -Path ([IO.Path]::Combine($Global:Session.Directories.LogsRoot, $Project, $Job)) -Filter "*.json" | Where-Object -FilterScript { -not $_.PSIsContainer } ))
        {
            If ($LogFileItem.Name.Length -gt 14)
            {
                [String] $LogTimeStamp = $LogFileItem.Name.Substring(0, 15);
                If (!$LogGroups.Contains($LogTimeStamp))
                {
                    [void] $LogGroups.Add([IO.Path]::GetFileNameWithoutExtension($LogTimeStamp));
                }
            }
        }
        ForEach ($LogGroup In $LogGroups)
        {
            [void] $StringBuilder.Append("<h3><a href=`"/logs?Project=" + $Project + "&Job=" + $Job + "&Group=" + $LogGroup + "`">" + $LogGroup + "</a></h3>");
        }
    }
    ElseIf ($Level -eq "Group")
    {
        [String] $LogFilePath = [IO.Path]::Combine($Global:Session.Directories.LogsRoot, $Project, $Job, ($Group + ".json"));
        [void] $StringBuilder.Append("<h1>$LogFilePath</h1>");
    }
    $Buffer = [System.Text.Encoding]::UTF8.GetBytes($StringBuilder.ToString());
    $Context.Response.ContentLength64 = $Buffer.Length;
    $Context.Response.OutputStream.Write($Buffer, 0, $Buffer.Length);
    $Context.Response.OutputStream.Close();
}));

$Global:Session.WebServer.AddRouteCommand("/one/two", "Get", [scriptblock]::Create({
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Net.HttpListenerContext] $Context
    )
    Write-Host "$($Context.Request.UserHostAddress)  =>  $($Context.Request.Url)" -f 'mag'
    [String] $html = "<h1>A Powershell Webserver</h1><p>One / Two</p>";
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html);
    $Context.Response.ContentLength64 = $buffer.Length;
    $Context.Response.OutputStream.Write($buffer, 0, $buffer.Length);
    $Context.Response.OutputStream.Close();
}));

ForEach ($Key In $Global:Session.WebServer.RouteFunctions.Keys)
{
    Write-Host -Object $Key;
}

Try
{
    While ($Global:Session.WebServer.IsListening())
    {
        $ContextTask = $Global:Session.WebServer.Listener.GetContextAsync();
        While (-not $ContextTask.AsyncWaitHandle.WaitOne(200)) { }
        $Context = $ContextTask.GetAwaiter().GetResult();
        If ($Global:Session.WebServer.HasRouteCommand($Context.Request.Url.LocalPath, $Context.Request.HttpMethod))
        {
            $Global:Session.WebServer.InvokeRouteCommand($Context.Request.Url.LocalPath, $Context.Request.HttpMethod, $Context);
        }

        # If ($routeFunctions.ContainsKey($context.Request.RawUrl))
        # {
        #     [RouteCommand] $routeCommand = $routeFunctions[$context.Request.RawUrl];
        #     If ($context.Request.HttpMethod.ToUpper() -eq $routeCommand.Method.ToUpper())
        #     {
        #         $routeCommand.Invoke($context);
        #     }
        # }
        Else
        {
            #Show Root
            If ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/')
            {
                Write-Host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'
                [String] $html = "<h1>A Powershell Webserver</h1><p>home page</p>";
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
                $context.Response.ContentLength64 = $buffer.Length
                $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                $context.Response.OutputStream.Close()
            }
            if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/some/form') {
                write-host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'
                [string]$html = "<h1>A Powershell Webserver</h1><form action='/some/post' method='post'><p>A Basic Form</p><p>fullname</p><input type='text' name='fullname'><p>message</p><textarea rows='4' cols='50' name='message'></textarea><br><input type='submit' value='Submit'></form>"
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($html) 
                $context.Response.ContentLength64 = $buffer.Length
                $context.Response.OutputStream.Write($buffer, 0, $buffer.Length) 
                $context.Response.OutputStream.Close()
            }

            if ($context.Request.HttpMethod -eq 'POST' -and $context.Request.RawUrl -eq '/some/post') {
                $FormContent = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()
                write-host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'
                Write-Host $FormContent -f 'Green'
                [string]$html = "<h1>A Powershell Webserver</h1><p>Post Successful!</p>" 
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
                $context.Response.ContentLength64 = $buffer.Length
                $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                $context.Response.OutputStream.Close() 
            }
        }
    }
}
Finally
{
    $Global:Session.WebServer.Listener.Stop()
    Write-Host "HTTP Server Stopped" -ForegroundColor Black -BackgroundColor Green;
}