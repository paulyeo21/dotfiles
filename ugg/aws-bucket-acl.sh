BUCKET="s3://ugg-cv-raw-test-data"

for path in $(aws s3 ls $BUCKET --recursive | awk '{print $4}');
do
  aws s3api put-object-acl --bucket $BUCKET --key $path --grant-full-control uri=http://acs.amazonaws.com/groups/global/AllUsers
done
