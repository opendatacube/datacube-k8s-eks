create-servers:
	packer build packer/compute.packer.json

create:
	./create.sh $(workspace) $(path)

destroy:
	./destroy.sh $(workspace) $(path)

patch:
	@cd infra; \
	./deploy.sh $(workspace) $(workspaces);

setup:
	@cd helm; \
	/bin/bash deploy.sh $(workspace) $(workspaces);
	@cd scripts; \
	/bin/bash ./create-workspace-defaults-secret.sh

setup-orchestration:
	@cd infra/orchestration; \
	./deploy.sh $(workspace) $(workspaces)

# use like "make run template=index-job name=nrt"
run-index:
	@cd jobs; \
	/usr/bin/env bash ./run-index.sh  -t $(template)

create-db:
	@cd jobs; \
	/usr/bin/env bash ./create-db.sh -n $(name)

test:
	@cd testing; \
	./run_newman_test.sh $(target) $(url)
	@cd testing/webserviceconformancetests; \
	export PYTHONPATH=. ; \
	python3 ./ws_conf_tests/client/ws_content/wms_conformance_cmdline_report.py -v true -u https://$(url)

test-infra:
	@cd infra; \
	./test.sh $(workspace) $(workspaces)
