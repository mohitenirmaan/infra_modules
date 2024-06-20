# ============Elastic file Storage=================#
  
  resource "aws_efs_file_system" "en-efs" {
    creation_token = var.creation_token
    encrypted = true
    throughput_mode = "elastic"
    lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS"
    }
  }

  resource "aws_efs_mount_target" "efs_mount_target" {
    for_each = {
    for k, v in slice(var.private_subnet_ids, 0, 2) : k => v
    }
    file_system_id = aws_efs_file_system.en-efs.id
    subnet_id      = each.value

    # Security group allowing access from instances
    security_groups = [var.security_group_ids[2]]
  }

