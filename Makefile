

download-numpy:
	pip install \
    --platform manylinux2014_aarch64 \
    --implementation cp \
    --python 3.9 \
    --target=./python \
    --only-binary=:all: --upgrade \
    numpy pandas sympy

create-zip:
	rm python.zip & zip -vr python.zip python/ -x "tests"

publish-layer:create-zip
	aws lambda publish-layer-version --layer-name numpy-pandas-sympy-Arm64 --description ""  \
	--license-info "MIT" --zip-file fileb://python.zip \
 	--compatible-runtimes python3.9 \
  	--compatible-architectures "arm64" \
  	--region ap-southeast-1

publish-Brotli:
	./publish_python_package_arm64_layer.sh Brotli

publish-cryptography:
	./publish_python_package_arm64_layer.sh cryptography

publish-babel:
	./publish_python_package_arm64_layer.sh babel
