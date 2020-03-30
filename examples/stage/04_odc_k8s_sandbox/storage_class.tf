# NOTE: This patch is required to resolve pending issue: https://github.com/jupyterhub/zero-to-jupyterhub-k8s/issues/1413
# Below null_resource makes the default StorageClass - gp2 (default) - not default
# In your jupyterhub k8s config template - create a new custom StorageClass and make it a default StorageClass as per zero-to-jupyterhub docs: https://readthedocs.org/projects/zero-to-jupyterhub/downloads/pdf/0.8.0/

resource "null_resource" "patch_gp2_storageclass" {
  provisioner "local-exec" {
    command = "aws eks --region ${local.region} update-kubeconfig --name ${local.cluster_id} && kubectl patch storageclass gp2 -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}'"
  }
}