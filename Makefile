create-backend:
	@cd examples/quickstart/backend; \
	terraform init; \
	terraform apply -auto-approve -input=false -var region=$(region) -var backend_name=$(backend)

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
	./patch.sh $(workspace) $(path) $(ami);

setup-orchestration:
	@cd infra/orchestration; \
	./deploy.sh $(workspace) $(path)