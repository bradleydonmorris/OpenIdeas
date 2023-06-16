# WebServer
## Allows the running of an HTTP web server.

- ### Listener `[property]`
    The HttpListener to use.
- ### RouteFunctions `[property]`
    Hash table of routes to listen for
- ### `Method` AddRouteCommand
    Adds a route to the listener.  
    - Route `System.String`  
        The route to listen for

    - Method `System.String`  
        The HTTP method to listen for

    - Method `System.String`  
        The script to execute when the route is triggered

- ### HasRouteCommand `[method]`
    Returns: `System.Boolean`  
    Checks to see if a route exists  
    - Route `System.String`  
        The route to listen for

    - Method `System.String`  
        The HTTP method to listen for

- ### GetRouteCommand `[method]`
    Returns: `RouteCommand`  
    Gets a RouteCommand  
    - Route `System.String`  
        The route to listen for

    - Method `System.String`  
        The HTTP method to listen for

- ### `Method` InvokeRouteCommand
    Executes the script for the RouteCommand  
    - Route `System.String`  
        The route to listen for

    - Method `System.String`  
        The HTTP method to listen for

    - Context `System.Net.HttpListenerContext`  
        The context of the calling web request

- ### `Method` Start
    Starts a web server listening on the specified URIs  
    - ListeningURIs `System.String[]`  
        The list of URI to listen on

- ### `Method` Stop
    Stops the web server.
