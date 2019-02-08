BUCKET="s3://ugg-cv-raw-test-data"
LOCAL_RAW="/Users/paulyeo/Downloads/ugg-cv-raw-test-data/1.0"
LOCAL_VERIFIED="/Users/paulyeo/Downloads/ugg-cv-verified-data"

echo "$BUCKET/1.0/$1"
echo "$LOCAL_RAW/$1"
echo "$LOCAL_VERIFIED/$1"

mkdir "$LOCAL_RAW/$1"
mkdir "$LOCAL_VERIFIED/$1"
aws s3 cp "$BUCKET/1.0/$1" "$LOCAL_RAW/$1" \
  --recursive
  #--dryrun
