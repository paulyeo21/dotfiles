FROM_BUCKET="s3://static.u.gg"
TO_BUCKET="s3://static2.u.gg"

aws s3 cp "$FROM_BUCKET" "$TO_BUCKET/assets" \
  --recursive
