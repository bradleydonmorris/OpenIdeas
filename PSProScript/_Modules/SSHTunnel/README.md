# SSHTunnel
## Used to manage SSH Tunnels

- ### Requires [Connections](_Modules/Connections/README.md)  
- ### Internals `[property]`
    Stores tunnel information for later use
- ### `Method` SetConnection
    Sets a SSHTunnel connection either in memory or persisted.  
    - Name `System.String`  
        Name of the Connection

    - Comments `System.String`  
        Comments for the Connection

    - IsPersisted `System.String`  
        True to store in file system.

    - AuthType `System.String`  
        Either Passowrd or KeyFile

    - SSHServerAddress `System.String`  
        The address of the SSH server

    - SSHServerPort `System.Int32`  
        The port of the SSH server

    - UserName `System.String`  
        The user name

    - Password `System.String`  
        The password for the user account. Ignored for KeyFile auth type

    - KeyFilePath `System.String`  
        The path to the key file. Ignored for Password auth type

    - KeyFilePassphrase `System.String`  
        The passphrase for the key file. Ignored for Password auth type

    - LocalAddress `System.String`  
        The address of the local system to map. Typically localhost

    - LocalPort `System.Int32`  
        The port of the local system to map

    - RemoteAddress `System.String`  
        The address of the remote system to map

    - RemotePort `System.Int32`  
        The port of the remote system to map

- ### GetConnection `[method]`
    Returns: `System.Management.Automation.PSCustomObject`  
    Gets a SSHTunnel connection either from memory or from file storage.  
    - Name `System.String`  
        Name of the Connection

- ### `Method` CreateTunnel
    Creates the SSH tunnel  
    - ConnectionName `System.String`  
        The named connection to create the tunnel

- ### IsTunnelEstablished `[method]`
    Returns: `System.Boolean`  
    Checks if a tunnel is establised
- ### `Method` DestroyTunnel
    Destroys the active tunnel.
