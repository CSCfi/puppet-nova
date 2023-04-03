# == Class: nova::migration::qemu
#
# Sets qemu config that is required for migration
#
# === Parameters:
#
# [*configure_qemu*]
#   (optional) Whether or not configure qemu bits.
#   Defaults to false.
#
# [*migration_port_min*]
#   (optional) Lower limit of port range used for migration.
#   Defaults to $facts['os_service_default'].
#
# [*migration_port_max*]
#   (optional) Higher limit of port range used for migration.
#   Defaults to $facts['os_service_default'].
#
class nova::migration::qemu(
  $configure_qemu     = false,
  $migration_port_min = $facts['os_service_default'],
  $migration_port_max = $facts['os_service_default'],
){

  include nova::deps

  validate_legacy(Boolean, 'validate_bool', $configure_qemu)

  Qemu_config<||> ~> Service<| tag == 'libvirt-qemu-service' |>

  if $configure_qemu {
    qemu_config {
      'migration_port_min': value => $migration_port_min;
      'migration_port_max': value => $migration_port_max;
    }
  } else {
    qemu_config {
      'migration_port_min': ensure => absent;
      'migration_port_max': ensure => absent;
    }
  }
}
