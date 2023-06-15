# Compression7Zip
## 

- ### ExecutablePath `[property]`
    Path to 7Zip executable. Typically C:\Program Files\7-Zip\7z.exe
- ### GetAssets `[method]`
    Returns: `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
    Returns a list of all assets in the specified Zip file  
    - CompressedFilePath `System.String`  
        Path to Zip file
- ### ExtractAsset `[method]`
    Returns: `System.String`  
    Extracts the specified asset from the Zip file and returns the path to the asset  
    - CompressedFilePath `System.String`  
        Path to Zip file
    - AssetPath `System.String`  
        Path within the zip file to the asset to extract
    - OutputDirectoryPath `System.String`  
        Path to the folder where the asset should be placed
