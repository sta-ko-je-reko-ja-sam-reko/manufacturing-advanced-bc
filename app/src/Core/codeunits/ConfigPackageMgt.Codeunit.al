namespace ManufacturingAdvanced.Core;

using System.IO;

codeunit 85008 "MFG Config. Package Mgt."
{
    Access = Public;

    /// <summary>
    /// Creates a feature's configuration package unless it exists already. A feature's demo data
    /// seeder calls this when, and only when, the user chooses to load sample data.
    /// </summary>
    /// <param name="PackageCode">The package code, by convention MFG- followed by the feature.</param>
    /// <param name="PackageName">The package name shown on the configuration package list.</param>
    /// <returns>True when the package was created now; false when it already existed, so the caller adds no tables.</returns>
    procedure CreatePackage(PackageCode: Code[20]; PackageName: Text[50]): Boolean
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageManagement: Codeunit "Config. Package Management";
    begin
        ConfigPackage.SetLoadFields(Code);
        if ConfigPackage.Get(PackageCode) then
            exit(false);

        ConfigPackageManagement.InsertPackage(ConfigPackage, PackageCode, PackageName, true);
        exit(true);
    end;

    /// <summary>
    /// Adds a table the app owns to a package, with every field included.
    /// </summary>
    /// <param name="PackageCode">The package to add the table to.</param>
    /// <param name="TableId">The table, which must belong to this app and must not be a feature setup table.</param>
    procedure AddOwnTable(PackageCode: Code[20]; TableId: Integer)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageManagement: Codeunit "Config. Package Management";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, PackageCode, TableId);
    end;

    /// <summary>
    /// Adds a standard table the app extends to a package, with only its primary key and the given
    /// fields included, so the package carries this app's fields and never Microsoft's whole table.
    /// </summary>
    /// <param name="PackageCode">The package to add the table to.</param>
    /// <param name="TableId">The standard table.</param>
    /// <param name="FieldNos">The numbers of the fields this app added to the table.</param>
    procedure AddExtendedTable(PackageCode: Code[20]; TableId: Integer; FieldNos: List of [Integer])
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageManagement: Codeunit "Config. Package Management";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, PackageCode, TableId);

        ConfigPackageField.SetRange("Package Code", PackageCode);
        ConfigPackageField.SetRange("Table ID", TableId);
        ConfigPackageField.SetRange("Primary Key", false);
        if not ConfigPackageField.FindSet(true) then
            exit;

        repeat
            if ConfigPackageField."Include Field" <> FieldNos.Contains(ConfigPackageField."Field ID") then begin
                ConfigPackageField.Validate("Include Field", FieldNos.Contains(ConfigPackageField."Field ID"));
                ConfigPackageField.Modify(true);
            end;
        until ConfigPackageField.Next() = 0;
    end;
}
