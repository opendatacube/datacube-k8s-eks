# NOTE: This patch is required to solve pending issue: https://github.com/jupyterhub/zero-to-jupyterhub-k8s/issues/1413
# Below null_resource patch the default StorageClass - gp2 (default) - set not to default
# Makesure you create a new StorageClass using k8s template as per zero-to-jupyterhub docs: https://zero-to-jupyterhub.readthedocs.io/_/downloads/en/latest/pdf/
#
# Example:
#  ---
#  apiVersion: storage.k8s.io/v1
#  kind: StorageClass
#  metadata:
#    name: standard-gp2
#    annotations:
#      storageclass.kubernetes.io/is-default-class: "true"
#  parameters:
#    type: gp2
#    fsType: ext4
#  provisioner: kubernetes.io/aws-ebs
#  reclaimPolicy: Delete
#  volumeBindingMode: Immediate
#  allowVolumeExpansion: true

resource "null_resource" "patch_gp2_storageclass" {
  provisioner "local-exec" {
    command = "aws eks --region ${local.region} update-kubeconfig --name ${local.cluster_id} && kubectl patch storageclass gp2 -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}'"
  }
}