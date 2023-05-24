class RouteCommand {
    [String] $Route;
    [String] $Method;
    [scriptblock] $Command;
    [void] Invoke([System.Net.HttpListenerContext] $context)
    {
        Invoke-Command -ScriptBlock $this.Command -ArgumentList $context;
    }
}

Add-Member `
    -InputObject $Global:Job `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "WebServer" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());
Add-Member `
    -InputObject $Global:Job.WebServer `
    -TypeName "Collections.Hashtable" `
    -NotePropertyName "RouteFunctions" `
    -NotePropertyValue ([Collections.Hashtable]::new());
Add-Member `
    -InputObject $Global:Job.WebServer `
    -TypeName "System.Net.HttpListener" `
    -NotePropertyName "Listener" `
    -NotePropertyValue ([System.Net.HttpListener]::new());
Add-Member `
    -InputObject $Global:Job.WebServer `
    -Name "IsListening" `
    -MemberType "ScriptMethod" `
    -Value {
        Return $Global:Job.WebServer.Listener.IsListening;
    }
Add-Member `
    -InputObject $Global:Job.WebServer `
    -Name "AddRouteCommand" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Route,

            [Parameter(Mandatory=$true)]
            [String] $Method,

            [Parameter(Mandatory=$true)]
            [scriptblock] $Command
        )
        [String] $Key = $Method.ToUpper() + "|" + $Route.ToLower();
        [RouteCommand] $RouteCommand = [RouteCommand]::new();
        $RouteCommand.Route = $Route.ToLower();
        $RouteCommand.Method = $Method.ToUpper();
        $RouteCommand.Command = $Command;
        [void] $Global:Job.WebServer.RouteFunctions.Add($Key, $RouteCommand);
    };
Add-Member `
    -InputObject $Global:Job.WebServer `
    -Name "HasRouteCommand" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([Boolean])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Route,

            [Parameter(Mandatory=$true)]
            [String] $Method
        )
        [String] $Key = $Method.ToUpper() + "|" + $Route.ToLower();
        Return $Global:Job.WebServer.RouteFunctions.ContainsKey($Key);
    };
Add-Member `
    -InputObject $Global:Job.WebServer `
    -Name "GetRouteCommand" `
    -MemberType "ScriptMethod" `
    -Value {
        [OutputType([RouteCommand])]
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Route,

            [Parameter(Mandatory=$true)]
            [String] $Method
        )
        [String] $Key = $Method.ToUpper() + "|" + $Route.ToLower();
        Return $Global:Job.WebServer.RouteFunctions[$Key];
    };
    Add-Member `
    -InputObject $Global:Job.WebServer `
    -Name "InvokeRouteCommand" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String] $Route,

            [Parameter(Mandatory=$true)]
            [String] $Method,

            [Parameter(Mandatory=$true)]
            [System.Net.HttpListenerContext] $Context
        )
        [String] $Key = $Method.ToUpper() + "|" + $Route.ToLower();
        [RouteCommand] $routeCommand = $Global:Job.WebServer.RouteFunctions[$Key];
        $routeCommand.Invoke($Context);
    };
Add-Member `
    -InputObject $Global:Job.WebServer `
    -Name "Start" `
    -MemberType "ScriptMethod" `
    -Value {
        Param
        (
            [Parameter(Mandatory=$true)]
            [String[]] $ListeningURIs
        )
        ForEach ($ListeningURI In $ListeningURIs)
        {
            $Global:Job.WebServer.Listener.Prefixes.Add($ListeningURI);
        }
        $Global:Job.WebServer.Listener.Start();
    };



