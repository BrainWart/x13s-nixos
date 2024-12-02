{
  callPackage,
  dosfstools,
  mtools,
  parted,
  runCommand,
  uefi ? (callPackage ./uefi.nix { }),
  util-linux,
}:

let
  name = "bios_update_utility";
  version = uefi.version;
in
runCommand name
  {
    inherit version;
    nativeBuildInputs = [
      parted
      util-linux
      dosfstools
      mtools
    ];
  }
  ''
    img=${name}-${version}.iso
    gap=8
    blocks=$(du -B 512 --summarize --apparent-size ${uefi} | awk '{ print $1 }')
    blocks=$(( 2 * blocks ))
    size=$(( 512 * blocks + gap * 1024 * 1024 + 34*512))
    truncate -s $size $img
    sfdisk $img <<EOF
      label: gpt
      start=''${gap}M, size=$blocks, type=uefi
    EOF

    eval $(partx $img -o START,SECTORS --nr 1 --pairs)
    truncate -s $(( SECTORS * 512 )) part.img
    mkfs.vfat part.img
    mcopy -spvm -i ./part.img ${uefi}/EFI "::/EFI"
    mcopy -spvm -i ./part.img ${uefi}/Flash "::/Flash"

    dd conv=notrunc if=part.img of=$img seek=$START count=$SECTORS
    rm -fr part.img

    mkdir $out
    mv ${name}-${version}.iso $out/
  ''
