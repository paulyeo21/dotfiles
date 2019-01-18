BUCKET="s3://static2.u.gg"

aws s3 cp "$BUCKET/assets/lol/riot_static/8.24.1/data/en_US" "/Users/paulyeo/Develop/gitgud-frontend/src/assets/riot_static/en_US/"  \
  --recursive
