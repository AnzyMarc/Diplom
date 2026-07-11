
# ============ Backups ============
resource "yandex_compute_snapshot_schedule" "daily_backup" {
  name = "daily-backup"

  schedule_policy {
    expression = "0 3 * * *"
  }

  retention_period = "168h"

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.web_a.boot_disk[0].disk_id,
    yandex_compute_instance.web_b.boot_disk[0].disk_id,
    yandex_compute_instance.zabbix.boot_disk[0].disk_id,
    yandex_compute_instance.elastic.boot_disk[0].disk_id,
    yandex_compute_instance.kibana.boot_disk[0].disk_id
  ]
}