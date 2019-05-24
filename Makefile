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
	./patch.sh $(workspace) $(path);

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
