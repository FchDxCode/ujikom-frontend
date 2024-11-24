; Inno Setup Script
[Setup]
AppName=Luminova Manajemen
AppVersion=1.0.0
DefaultDirName={pf}\Luminova
DefaultGroupName=Luminova
OutputDir=OutputInstaller
OutputBaseFilename=LuminovaInstaller
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Luminova"; Filename: "{app}\flutter_manajemen.exe"
Name: "{group}\Uninstall Luminova"; Filename: "{uninstallexe}"

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

