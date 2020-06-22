#!/bin/bash

# Ensure that the GITHUB_TOKEN secret is included
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

reponame=$(basename $GITHUB_REPOSITORY)
if [[ -z "$UTC_OFFSET" ]]; then
  wordcount.rb --repo ${reponame}
  exit 0
fi
wordcount.rb --repo ${reponame} --offset $UTC_OFFSET
exit 0
