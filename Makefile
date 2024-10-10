
download-numpy:
	rm -rf python.zip & mkdir -p python & rm -rf python/ &
	/opt/homebrew/bin/python3.11 -m pip --python /opt/homebrew/bin/python3.11 \
    install \
    --platform manylinux2014_aarch64 \
    --implementation cp \
    --target=./python \
    --only-binary=:all: --upgrade \
    numpy pandas sympy & rm -f python.zip & zip -vr python.zip python/ -x "tests" -x "*.pyc"


publish-numpy:download-numpy
	aws lambda publish-layer-version --layer-name numpy-pandas-sympy-Arm64 \
	--description "numpy pandas sympy python3.11 arm64"  \
	--license-info "MIT" --zip-file fileb://python.zip \
 	--compatible-runtimes python3.11 \
  	--compatible-architectures "arm64" \
  	--region ap-southeast-1


publish-Brotli:
	./publish_python_package_arm64_layer.sh Brotli

publish-cryptography:
	./publish_python_package_arm64_layer.sh cryptography

publish-babel:
	./publish_python_package_arm64_layer.sh babel

publish-msgspec:
	./publish_python_package_arm64_layer.sh msgspec

publish-langchain-core:
	./publish_python_package_arm64_layer.sh pydantic msgspec jiter

publish-litellm:
	./publish_python_package_arm64_layer.sh litellm numpy pandas sympy

deploy-ubuntu:
	rsync -avzP -rt --delete . detalytics.aws:publish-python-package-as-lambda