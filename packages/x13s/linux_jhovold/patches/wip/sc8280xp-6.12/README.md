While building this revision, I was getting the following error:

```
undefined reference to `zlib_deflate_workspacesize'
```

I found this relevant question, and it contained the link to the
patch in this directory.

https://github.com/NixOS/nixpkgs/issues/351302

https://lore.kernel.org/all/20241003230734.653717-1-ojeda@kernel.org

