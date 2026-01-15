SHELL=/bin/bash

baseUrl = https://raw.githubusercontent.com/BinaryBirds/github-workflows/refs/heads/main/scripts

check: symlinks language deps lint headers

symlinks:
	curl -s $(baseUrl)/check-broken-symlinks.sh | bash

language:
	curl -s $(baseUrl)/check-unacceptable-language.sh | bash

deps:
	curl -s $(baseUrl)/check-local-swift-dependencies.sh | bash

lint:
	curl -s $(baseUrl)/run-swift-format.sh | bash

format:
	curl -s $(baseUrl)/run-swift-format.sh | bash -s -- --fix
	find Sources -type f -name '*.swift' -print0 | xargs -0 sed -i '' 's/nonisolated (nonsending/nonisolated(nonsending/g'

docc-local:
	curl -s $(baseUrl)/generate-docc.sh | bash -s -- --local

run-docc:
	curl -s $(baseUrl)/run-docc-docker.sh | bash

docc-warnings:
	curl -s $(baseUrl)/check-docc-warnings.sh | bash

headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash

fix-headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash -s -- --fix


testprep:
	rm -rf docker/postgres/certificates && mkdir -p docker/postgres/certificates && cd docker/postgres/certificates && ../scripts/generate-certificates.sh
	rm -rf docker/mariadb/certificates && mkdir -p docker/mariadb/certificates && cd docker/mariadb/certificates && ../scripts/generate-certificates.sh
	docker compose up -d --build postgres mariadb

test: testprep
	swift test --parallel
