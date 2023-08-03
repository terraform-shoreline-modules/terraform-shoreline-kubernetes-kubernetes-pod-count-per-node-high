resource "shoreline_notebook" "kubernetes_pod_count_per_node_high" {
  name       = "kubernetes_pod_count_per_node_high"
  data       = file("${path.module}/data/kubernetes_pod_count_per_node_high.json")
  depends_on = [shoreline_action.invoke_script_name,shoreline_action.invoke_kube_terminate_unnecessary_pods]
}

resource "shoreline_file" "script_name" {
  name             = "script_name"
  input_file       = "${path.module}/data/script_name.sh"
  md5              = filemd5("${path.module}/data/script_name.sh")
  description      = "Define variables"
  destination_path = "/agent/scripts/script_name.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kube_terminate_unnecessary_pods" {
  name             = "kube_terminate_unnecessary_pods"
  input_file       = "${path.module}/data/kube_terminate_unnecessary_pods.sh"
  md5              = filemd5("${path.module}/data/kube_terminate_unnecessary_pods.sh")
  description      = "Identify and terminate any unnecessary or redundant pods running on the nodes."
  destination_path = "/agent/scripts/kube_terminate_unnecessary_pods.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_script_name" {
  name        = "invoke_script_name"
  description = "Define variables"
  command     = "`chmod +x /agent/scripts/script_name.sh && /agent/scripts/script_name.sh`"
  params      = []
  file_deps   = ["script_name"]
  enabled     = true
  depends_on  = [shoreline_file.script_name]
}

resource "shoreline_action" "invoke_kube_terminate_unnecessary_pods" {
  name        = "invoke_kube_terminate_unnecessary_pods"
  description = "Identify and terminate any unnecessary or redundant pods running on the nodes."
  command     = "`chmod +x /agent/scripts/kube_terminate_unnecessary_pods.sh && /agent/scripts/kube_terminate_unnecessary_pods.sh`"
  params      = ["POD_NAME","NODE_NAME","NAMESPACE"]
  file_deps   = ["kube_terminate_unnecessary_pods"]
  enabled     = true
  depends_on  = [shoreline_file.kube_terminate_unnecessary_pods]
}

