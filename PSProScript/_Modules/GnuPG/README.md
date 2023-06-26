# GnuPG
## Manages keys used by GnuPG.

- ### Requires [Utilities](_Modules/Utilities/README.md)  
- ### ExecutablePath `[property]`
    Path to the gpg.exe file.
- ### GetPublicKeys `[method]`
    Returns: `System.Boolean`  
    Lists all public keys in the key ring  
    - HomeDirectory `System.String`  
        If null defualts to the current user's key ring

- ### GetPrivateKeys `[method]`
    Returns: `System.Boolean`  
    Lists all private keys in the key ring  
    - HomeDirectory `System.String`  
        If null defualts to the current user's key ring

- ### GetKeys `[method]`
    Returns: `System.Boolean`  
    Lists all private and public keys in the key ring  
    - HomeDirectory `System.String`  
        If null defualts to the current user's key ring

- ### AddPrivateKey `[method]`
    Returns: `System.Boolean`  
    Adds a private key to the key ring  
    - FilePath `System.String`  
        Path to the key file

    - Passphrase `System.String`  
        Passphrase for the key file

    - HomeDirectory `System.String`  
        If null defualts to the current user's key ring

- ### AddPublicKey `[method]`
    Returns: `System.Boolean`  
    Adds a public key to the key ring  
    - FilePath `System.String`  
        Path to the key file

    - HomeDirectory `System.String`  
        If null defualts to the current user's key ring

- ### RemovePrivateKey `[method]`
    Returns: `System.Boolean`  
    Removes a private key from the key ring  
    - Fingerprint `System.String`  
        The fingerprint of the key to remove

    - HomeDirectory `System.String`  
        If null defualts to the current user's key ring

- ### RemovePublicKey `[method]`
    Returns: `System.Boolean`  
    Removes a public key from the key ring  
    - Fingerprint `System.String`  
        The fingerprint of the key to remove

    - HomeDirectory `System.String`  
        If null defualts to the current user's key ring

