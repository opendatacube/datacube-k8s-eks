create-servers:
	packer build packer/compute.packer.json

apply:
	./apply.sh $(workspace) $(path)

destroy:
	./destroy.sh $(workspace) $(path)

clean-terraform:
	rm -rf infra/.terraform; \
	rm -rf nodes/.terraform; \
	rm -rf addons/.terraform

patch:
	@cd infra; \
	./deploy.sh $(workspace) $(path);

setup:
	@cd helm; \
	/bin/bash deploy.sh $(workspace) $(path);
	@cd scripts; \
	/bin/bash ./create-workspace-defaults-secret.sh

setup-orchestration:
	@cd infra/orchestration; \
	./deploy.sh $(workspace) $(path)

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
	./test.sh $(workspace) $(path)
