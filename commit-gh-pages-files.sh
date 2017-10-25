#!/bin/bash 

GIT_REPO=rahulinux.github.io

hugo

rsync -avzp public/* $GIT_REPO/* 

cd $GIT_REPO && git add --all && git commit -m "Publishing to gh-pages" && git push && cd ..
