REGION=""
ACCOUNT_NUMBER=""
VERSION_NUMBER="latest"

docker buildx -t bnfd/nginx-docker .

docker tag bnfd/nginx-docker $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/bnfd_nginx:latest

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com
docker push $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/bnfd_nginx:latest
docker push $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/bnfd_nginx:${VERSION_NUMBER}

