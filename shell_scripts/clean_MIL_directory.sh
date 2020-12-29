#! /bin/bash
# A program intended to adjust MIL permissions and ownership.
# Access to folders is restricted by the stfacl -m command.

# Go into the MIL Directory
cd /archive/MIL/;

# Change the Permissions
ls . | parallel --will-cite chmod -R 775 {};

# Change the Group Ownership
find . -maxdepth 5 -gid 2020 -type d -print | parallel --will-cite chgrp -Rv MIL {}
