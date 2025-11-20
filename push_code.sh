#!/bin/bash

 eval "$(ssh-agent -s)"
 ssh-add -D
 ssh-add --apple-use-keychain ~/.ssh/id_nova

 git config --global user.name "nova"
 git config --global user.email "nova@nova.nova"

 git add .
 git commit -m "handle change map"

 git push --set-upstream origin develop

 git config --global user.name "jiro"
 git config --global user.email "jiro@darasa.io"