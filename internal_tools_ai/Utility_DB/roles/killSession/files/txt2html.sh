filename=`echo $1 | awk -F'.' '{print $1}'`
NL="
"
cat $1 \
| sed -e 's/ at / at /g' \
| sed -e 's/[[:cntrl:]]/ /g'\
| sed -e 's/^[[:space:]]*$//g' \
| sed -e '/^$/{'"$NL"'N'"$NL"'/^\n$/D'"$NL"'}' \
| sed -e 's/^$/<\/UL><P>/g' \
| sed -e '/<P>$/{'"$NL"'N'"$NL"'s/\n//'"$NL"'}'\
| sed -e 's/<P>[[:space:]]*"/<P><UL>"/' \
| sed -e 's/^[[:space:]]*-/<BR> -/g' \
| sed -e 's/http:\/\/[[:graph:]\.\/]*/<A HREF="&">[&]<\/A> /g'\
                                > ${filename}.html
