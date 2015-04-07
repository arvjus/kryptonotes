#!/usr/bin/awk -f
# ./mkxml.awk <test.txt |sed -e 's@\\n@\n@g' >test.xml

BEGIN {
  FS="|"
  printf "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<items>\n"
}

{
  printf "<item category=\""$1"\" title=\""$2"\">\n"$3"\n</item>\n"
}

END {
  printf "</items>\n"
}

