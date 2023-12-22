pip install --upgrade -r < pip list --outdated --format=json | jq -r'.[].name'
