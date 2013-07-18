#!/bin/bash

user=$1
echo "Add $user to group ctu." 

useradd -m -g ctu -s /bin/bash $user
passwd $user

