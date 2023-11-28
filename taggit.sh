#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <tag>   eg: $0 1.0"
  exit 1
fi

# define
tag="$1"
tag_name="refs/tags/$1"
file_path="default.xml"
new_branch="release"

# prepare branch
echo "Git pull..."
git pull

echo "Switching to master..."
git checkout master

echo "Deleting existing branch '$new_branch'..."
git branch -D "$new_branch"
git push inos --delete "$new_branch"

echo "Switching to branch '$new_branch'..."
git checkout -b "$new_branch" inos/master

# modify tag file
echo "Modifying $file_path master..."
sed -i "s#"master"#$tag_name#g" "$file_path"

# commit
echo "Committing changes with tag '$tag'..."
git add "$file_path"
git commit -m "Modify default.xml file [Tag: $tag]"

echo "Pushing changes to remote repository..."
git push -u inos "$new_branch"

# sync
echo "Creating and pushing a new tag '$tag'..."
git tag "$tag"
git push inos --tags

# recovery
echo "Switching to master..."
git checkout master

echo "Process complete."