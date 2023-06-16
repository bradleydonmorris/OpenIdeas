# SQLServerFileImport
## A set of methods for importing delimited files into SQL server.

- ### `Method` CSVToDataTable
    Converts a CSV file into a DataTable.  
    - FilePath `System.String`  
        The path to the CSV file

    - Delimiter `System.String`  
        The field delimiter used in the CSV. Defaults to ",".

- ### GetCSVRowCount `[method]`
    Returns: `System.Int64`  
    Gets the number of rows in a CSV.  
    - FilePath `System.String`  
        The path to the CSV file

    - Delimiter `System.String`  
        The field delimiter used in the CSV. Defaults to ",".

- ### `Method` ImportCSV
    Imports a CSV file into a SQL Server table.  
    - ConnectionName `System.String`  
        The named connection to execute against

    - Schema `System.String`  
        The schema of the table to import to

    - Table `System.String`  
        The table to import to

    - FilePath `System.String`  
        The path to the CSV file

    - Delimiter `System.String`  
        The field delimiter used in the CSV. Defaults to ",".

    - BatchSize `System.Int32`  
        The number of records to import in each batch

    - AdditionalDataItems `System.Collections.Generic.List[System.Management.Automation.PSObject]`  
        Addtional columns to add to the DataTable prior to import

