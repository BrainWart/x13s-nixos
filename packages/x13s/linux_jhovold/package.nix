{
  buildLinux,
  fetchFromGitHub,
  lib,
  ...
}:
let
  inherit (builtins)
    attrNames
    filter
    fromJSON
    getAttr
    pathExists
    readDir
    readFile
    ;

  inherit (lib.strings)
    hasSuffix
    ;

  source = fromJSON (readFile ./source.json);

  linux_jhovold_src = fetchFromGitHub {
    inherit (source)
      hash
      owner
      repo
      rev
      ;
  };

  patches =
    let
      basePatchDir = ./patches/${source.rev};
      entries = readDir basePatchDir;
      files = filter (key: (getAttr key entries) == "regular" && (hasSuffix ".patch" key)) (
        attrNames entries
      );
    in
    if pathExists basePatchDir then
      map (filename: {
        name = filename;
        patch = basePatchDir + "/${filename}";
      }) files
    else
      [ ];

in
buildLinux {
  modDirVersion = source.version;

  src = linux_jhovold_src;
  version = source.version;
  defconfig = "johan_defconfig";

  kernelPatches = patches;

  ignoreConfigErrors = true;
 
  extraMeta.branch = source.rev;
}
