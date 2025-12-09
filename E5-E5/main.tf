// Copyright (c) 2018, 2021 Oracle and/or its affiliates.

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=4.67.3"
    }
  }
  required_version = ">= 1.0.0"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

resource "oci_core_instance" "instance1-E5" {
    availability_domain = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
    fault_domain = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
    compartment_id = var.compartment_ocid
    shape = var.instance1_shape
    cluster_placement_group_id = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
    metadata = {
        ssh_authorized_keys = file("~/.ssh/authorized_keys")
    } 
    agent_config {
        #Optional
        are_all_plugins_disabled = true
        is_management_disabled = true
        is_monitoring_disabled = true
    }    
    create_vnic_details {
        assign_public_ip = false
        private_ip = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
        subnet_id = var.subnet_id
    }
    display_name = var.instance1_display_name
    #fault_domain = var.instance_fault_domain
    shape_config {
        #Optional
        memory_in_gbs = var.instance_flex_memory_in_gbs
        ocpus = var.instance_flex_ocpus
    }
    source_details {
        #Required
        source_id = var.instance1_source_ocid
        source_type = "image"

        #Optional
        boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    }
    preserve_boot_volume = false
}

resource "oci_core_instance" "instance2-E5" {
    availability_domain = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
    fault_domain = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
    compartment_id = var.compartment_ocid
    shape = var.instance2_shape
    cluster_placement_group_id = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
    metadata = {
        ssh_authorized_keys = file("~/.ssh/authorized_keys")
    }
    agent_config {
        #Optional
        are_all_plugins_disabled = true
        is_management_disabled = true
        is_monitoring_disabled = true
    }    
    create_vnic_details {
        assign_public_ip = false
        private_ip = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
        subnet_id = var.subnet_id
    }
    display_name = var.instance2_display_name
    #fault_domain = var.instance_fault_domain
    shape_config {
        #Optional
        memory_in_gbs = var.instance_flex_memory_in_gbs
        ocpus = var.instance_flex_ocpus
    }
    source_details {
        #Required
        source_id = var.instance2_source_ocid
        source_type = "image"

        #Optional
        boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    }
    preserve_boot_volume = false
        provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      private_key = file("~/.ssh/id_rsa")
      host        = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
    }

    inline = [
      "sleep 60",
      "FILENAME=$(date +%Y%m%d_%H%M%S)",
      "ping -c 500 10.0.0.1 > /tmp/$FILENAME", #ハードコードしたのでvariablesに今度やるときは追加する
      "curl -X PUT --data-binary @/tmp/$FILENAME <オブジェクト・ストレージのバケット>/$FILENAME"
    ]
  }
}