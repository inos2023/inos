#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <tag>   eg: $0 1.0"
  exit 1
fi

tag="$1"
tagname="refs/tags/$1"
echo $tag
echo $tagname

if [ ! -f "default.xml" ]; then
  echo "default.xml does not exist."
  exit 1
fi

sed -i "s#"master"#$tagname#g" "default.xml"
echo "new tag $tagname replacement complete."

