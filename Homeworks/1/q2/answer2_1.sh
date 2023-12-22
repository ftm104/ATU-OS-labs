pip install --upgrade -r < pip list --outdated | awk '{ if ( NR > 2 ) print ($1)}'
