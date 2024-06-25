#!/usr/bin/env python3

from github import Github
import sys
import re
from packaging.version import Version
from subprocess import run

latest_version: str = "0"
latest_branch: str = ""
previous_version: str = ""

with Github() as gh:
    for branch in gh.get_user("jhovold").get_repo("linux").get_branches():
        v = re.match("wip/sc8280xp-((v?6.[0-9]+)(-rc[0-9]+)?)", branch.name)
        if v != None and Version(v.group(1)) > Version(latest_version):
            # add .0 to version
            latest_version = f"{v.group(2)}.0{v.group(3) or ''}"
            latest_branch = v.group(0)

print("branch: " + latest_branch)
print("latest: " + latest_version)

with open("packages/default.nix", "r") as f:
    lines = f.readlines()

for line in lines:
    v = re.match(r'^\s*version = "(6[.0-9-rc]+)";.*$', line)
    if v != None:
        previous_version = v.group(1)

print("previous: " + previous_version)

if previous_version == latest_version:
    print("No update found, exiting.")
    sys.exit(1)

with open("packages/default.nix", "w") as f:
    for line in lines:
        f.write(
            re.sub(
                r'^(\s*version = ")6[.0-9-rc]+(";.*$)',
                rf"\g<1>{latest_version}\2",
                line,
            )
        )

run(
    f"npins add --name linux-jhovold github --branch {latest_branch} jhovold linux".split(
        " "
    )
)

run("git add npins/ packages/default.nix".split(" "))
run(["git", "commit", "-m", f"jhovold: {previous_version} -> {latest_version}"])
