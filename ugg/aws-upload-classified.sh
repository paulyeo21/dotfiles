BUCKET="s3://ugg-cv-verified-data/1920x1200"
LOCAL="/Users/paulyeo/Downloads/ugg-cv-verified-data"

echo "$LOCAL/$1"
echo "$BUCKET/$1"

aws s3 cp "$LOCAL/$1" "$BUCKET/$1" \
  --recursive \
  --exclude ".DS_Store"
  #--dryrun
# aws s3 cp "$LOCAL/wrong" "$BUCKET/wrong" \
#   --recursive  \
#   --exclude ".DS_Store"
  #--dryrun
