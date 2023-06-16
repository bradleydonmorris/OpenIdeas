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
    -InputObject $Global:Session `
    -TypeName "System.Management.Automation.PSObject" `
    -NotePropertyName "WebServer" `
    -NotePropertyValue ([System.Management.Automation.PSObject]::new());

#region Properties
Add-Member `
    -InputObject $Global:Session.WebServer `
    -TypeName "Collections.Hashtable" `
    -NotePropertyName "RouteFunctions" `
    -NotePropertyValue ([Collections.Hashtable]::new());
Add-Member `
    -InputObject $Global:Session.WebServer `
    -TypeName "System.Net.HttpListener" `
    -NotePropertyName "Listener" `
    -NotePropertyValue ([System.Net.HttpListener]::new());
#region Properties

#region Methods
Add-Member `
    -InputObject $Global:Session.WebServer `
    -Name "IsListening" `
    -MemberType "ScriptMethod" `
    -Value {
        Return $Global:Session.WebServer.Listener.IsListening;
    }
Add-Member `
    -InputObject $Global:Session.WebServer `
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
            [ScriptBlock] $Command
        )
        [String] $Key = $Method.ToUpper() + "|" + $Route.ToLower();
        [RouteCommand] $RouteCommand = [RouteCommand]::new();
        $RouteCommand.Route = $Route.ToLower();
        $RouteCommand.Method = $Method.ToUpper();
        $RouteCommand.Command = $Command;
        [void] $Global:Session.WebServer.RouteFunctions.Add($Key, $RouteCommand);
    };
Add-Member `
    -InputObject $Global:Session.WebServer `
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
        Return $Global:Session.WebServer.RouteFunctions.ContainsKey($Key);
    };
Add-Member `
    -InputObject $Global:Session.WebServer `
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
        Return $Global:Session.WebServer.RouteFunctions[$Key];
    };
Add-Member `
    -InputObject $Global:Session.WebServer `
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
        [RouteCommand] $routeCommand = $Global:Session.WebServer.RouteFunctions[$Key];
        [void] $routeCommand.Invoke($Context);
    };
Add-Member `
    -InputObject $Global:Session.WebServer `
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
            [void] $Global:Session.WebServer.Listener.Prefixes.Add($ListeningURI);
        }
        [void] $Global:Session.WebServer.Listener.Start();
    };
Add-Member `
    -InputObject $Global:Session.WebServer `
    -Name "Stop" `
    -MemberType "ScriptMethod" `
    -Value {
        [void] $Global:Session.WebServer.Listener.Stop();
    };
#region Methods
