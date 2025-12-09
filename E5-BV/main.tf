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

resource "oci_core_instance" "instance-E5-vb" {
  availability_domain = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
  fault_domain = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
  compartment_id = var.compartment_ocid
  shape = var.instance1_shape
  cluster_placement_group_id = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
  metadata = {
    ssh_authorized_keys = file("~/.ssh/authorized_keys")
  } 
  agent_config {
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
  shape_config {
    memory_in_gbs = var.instance_flex_memory_in_gbs
    ocpus = var.instance_flex_ocpus
  }
  source_details {
    source_id = var.instance1_source_ocid
    source_type = "image"
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }
  preserve_boot_volume = false
}

resource "oci_core_volume" "block_volume" {
  availability_domain = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
  compartment_id     = var.compartment_ocid
  display_name       = "bv1_cpg"
  size_in_gbs        = 50
  cluster_placement_group_id = "!!ハードコードしたのでvariablesに今度やるときは追加する!!"
}

resource "null_resource" "attach_volume" {
  provisioner "local-exec" {
    command = "oci compute volume-attachment attach --instance-id ${oci_core_instance.instance-E5-vb.id} --volume-id ${oci_core_volume.block_volume.id} --type paravirtualized"
  }

  depends_on = [
    oci_core_instance.instance-E5-vb, 
    oci_core_volume.block_volume
  ]
}

resource "null_resource" "remote_exec" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      private_key = file("~/.ssh/id_rsa")
      host        = "10.0.0.21" #ハードコードしたのでvariablesに今度やるときは追加する
    }
    inline = [
      "FILENAME=E5-vb_cpg_$(date +%Y%m%d_%H%M%S)",
      "sudo dnf install -y fio",
      "sudo fio --name=test --filename=/dev/sdb --rw=randrw --bs=4k --size=1G > /tmp/$FILENAME",
      "curl -X PUT --data-binary @/tmp/$FILENAME オブジェクト・ストレージのバケット/$FILENAME"
    ]
  }

  depends_on = [
    null_resource.attach_volume
  ]
}