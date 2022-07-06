#! /bin/sh
set -e


package_name=$1

echo publish layer $package_name for arm64 architecture
# cleanup workspace
rm -rf python && mkdir python

# install to directory
pip3 install \
    --platform manylinux2014_aarch64 \
    --implementation cp \
    --python 3.9 \
    --target=./python \
    --only-binary=:all: --upgrade \
    $package_name

# make zip package
rm -f python.zip & zip -vr python.zip python/ -x "tests" -x "*.pyc"

# push to aws
aws lambda publish-layer-version --layer-name $package_name-Arm64 --description "$package_name arm64"  \
	--license-info "MIT" --zip-file fileb://python.zip \
 	--compatible-runtimes python3.9 \
  	--compatible-architectures "arm64" \
  	--region ap-southeast-1