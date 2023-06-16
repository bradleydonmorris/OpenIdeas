# NuGet
## This module can be used to install NuGet packages.

- ### ExecutablePath `[property]`
    The path to nuget.exe
- ### `Method` AddAssembly
    Adds an assembly reference for use by scripts.  
    - Name `System.String`  
        The name of the assembly

    - RelativePath `System.String`  
        The the path to the assembly relative to the Packages directory

- ### `Method` InstallPackage
    Installs the latest version of a package.  
    - PackageName `System.String`  
        The name of the package

- ### `Method` InstallPackageIfMissing
    Installs the latest version of a package if it is not installed.  
    - PackageName `System.String`  
        The name of the package

- ### `Method` InstallPackageVersion
    Installs the specified version of a package.  
    - PackageName `System.String`  
        The name of the package

    - Version `System.String`  
        The version of the package

- ### `Method` InstallPackageVersionIfMissing
    Installs the specified version of a package if it is not installed.  
    - PackageName `System.String`  
        The name of the package

    - Version `System.String`  
        The version of the package

- ### IsPackageInstalled `[method]`
    Returns: `System.Boolean`  
    Determines if a package is installed.  
    - PackageName `System.String`  
        The name of the package

- ### IsPackageVersionInstalled `[method]`
    Returns: `System.Boolean`  
    Determines if a specific version of a package is installed.  
    - PackageName `System.String`  
        The name of the package

    - Version `System.String`  
        The version of the package

