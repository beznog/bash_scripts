#!/bin/bash

echo "# bash_scripts" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/beznog/bash_scripts.git
git push -u origin master
