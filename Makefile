# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: image clean bootstrap deps 
.DEFAULT_GOAL := build

# Tools required for different make targets or for development purposes
EXTERNAL_TOOLS=\
	github.com/Masterminds/glide 

IMAGE?=openebs-provisioner

# Bootstrap the build by downloading additional tools
bootstrap:
	@for tool in  $(EXTERNAL_TOOLS) ; do \
		echo "Installing $$tool" ; \
		go get $$tool; \
	done 

deps: 
	rm -rf vendor
	@glide up

openebs-provisioner: $(shell find . -name "*.go")
	#glide install -v --strip-vcs
	CGO_ENABLED=0 go build -a -ldflags '-extldflags "-static"' -o openebs-provisioner .

build: $(shell find . -name "*.go")
	glide install -v --strip-vcs
	CGO_ENABLED=0 go build -a -ldflags '-extldflags "-static"' -o openebs-provisioner .

image: build
	@cp openebs-provisioner buildscripts/docker/
	@cd buildscripts/docker && sudo docker build -t openebs/openebs-k8s-provisioner:ci .
	@sh buildscripts/push

clean:
	rm -rf vendor
	rm openebs-provisioner
