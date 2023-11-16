locals {
  temp_dir = "/tmp/docker_volumes_backup_config"
}

resource "ssh_resource" "restore" {
  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "create"

  pre_commands = [
    "mkdir -p ${local.temp_dir}",
    "docker volume create ${var.config_volume_name} -o type=none -o o=bind -o device=${local.temp_dir} || true",
  ]

  file {
    content     = <<EOF
    [backup]
    %{for key, value in var.backup_config~}
    ${key} = ${value}
    %{endfor~}
    EOF
    destination = "${local.temp_dir}/rclone.conf"
    permissions = "0440"
  }

  dynamic "file" {
    for_each = nonsensitive(var.secrets)
    content {
      content     = sensitive(file.value)
      destination = "${local.temp_dir}/${file.key}"
      permissions = "0400"
    }
  }

  commands = [
    <<EOF
    VOLUMES=$(docker run --rm -i -v ${var.config_volume_name}:/config/rclone rclone/rclone lsf backup: | grep ".tar.gz" | awk -F '.tar.gz' '{print $1}');
    for VOLUME in $VOLUMES; do
      docker volume create --label ${var.backup_label}=restored $VOLUME || true;
      docker run --rm -i -v ${var.config_volume_name}:/config/rclone rclone/rclone cat backup:$VOLUME.tar.gz |
        docker run --rm -i -v $VOLUME:/volume alpine tar -xvzf - -C /volume;
    done
    EOF
    , "docker volume rm ${var.config_volume_name}",
    "rm -rf ${local.temp_dir}"
  ]
}

resource "ssh_resource" "backup" {
  host        = var.connection.host
  user        = var.connection.user
  private_key = var.connection.private_key
  agent       = var.connection.agent

  when = "destroy"

  pre_commands = [
    "mkdir -p ${local.temp_dir}",
    "docker volume create ${var.config_volume_name} -o type=none -o o=bind -o device=${local.temp_dir} || true",
  ]

  file {
    content     = <<EOF
    [backup]
    %{for key, value in var.backup_config~}
    ${key} = ${value}
    %{endfor~}
    EOF
    destination = "${local.temp_dir}/rclone.conf"
    permissions = "0440"
  }

  dynamic "file" {
    for_each = nonsensitive(var.secrets)
    content {
      content     = sensitive(file.value)
      destination = "${local.temp_dir}/${file.key}"
      permissions = "0400"
    }
  }

  commands = [
    "docker stack rm $(docker stack ls --format '{{.Name}}') || true",
    "docker service rm $(docker service ls --format '{{.Name}}') || true",
    "docker stop $(docker ps -a --format '{{.Names}}') || true",
    <<EOT
    VOLUMES=$(docker volume ls -f label=${var.backup_label} --format '{{.Name}}');
    for VOLUME in $VOLUMES; do
      docker run --rm -i -v $VOLUME:/volume alpine tar -cvzf - -C /volume ./ |
        docker run --rm -i -v ${var.config_volume_name}:/config/rclone rclone/rclone rcat backup:$VOLUME.tar.gz -v ; 
    done
    EOT
    , "docker volume rm ${var.config_volume_name}",
    "rm -rf ${local.temp_dir}"
  ]
}
