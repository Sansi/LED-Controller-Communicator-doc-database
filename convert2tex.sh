pandoc overview.md -o latex/content/overview.tex
pandoc process.md -o latex/content/process.tex
pandoc tables.md -o latex/content/tables.tex
pandoc append1.md -o latex/content/append1.tex
sed 's/{longtable}/{longtabu}/g' -i latex/content/*.tex
sed 's/}llll@{/}lXXX@{/g' -i latex/content/tables.tex
sed 's/}rlll@{/}rXXX@{/g' -i latex/content/append1.tex
