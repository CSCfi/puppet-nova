# == Class: nova::metadata
#
# Setup and configure the Nova metadata API endpoint for wsgi
#
# === Parameters
#
# [*neutron_metadata_proxy_shared_secret*]
#   (optional) Shared secret to validate proxies Neutron metadata requests
#   Defaults to undef
#
# [*metadata_cache_expiration*]
#   (optional) This option is the time (in seconds) to cache metadata.
#   Defaults to $::os_service_default
#
# [*local_metadata_per_cell*]
#   (optional) Indicates that the nova-metadata API service has been deployed
#   per-cell, so that we can have better performance and data isolation in a
#   multi-cell deployment. Users should consider the use of this configuration
#   depending on how neutron is setup. If networks span cells, you might need
#   to run nova-metadata API service globally. If your networks are segmented
#   along cell boundaries, then you can run nova-metadata API service per cell.
#   When running nova-metadata API service per cell, you should also configure
#   each Neutron metadata-agent to point to the corresponding nova-metadata API
#   service.
#   Defaults to $::os_service_default
#
# DEPRECATED
#
# [*dhcp_domain*]
#   (optional) domain to use for building the hostnames
#   Defaults to undef.
#
#  [*enabled_apis*]
#   (optional) A list of apis to enable
#   Defaults to undef.
#
# [*enable_proxy_headers_parsing*]
#   (optional) This determines if the HTTPProxyToWSGI
#   middleware should parse the proxy headers or not.(boolean value)
#   Defaults to undef.
#
# [*max_request_body_size*]
#   (Optional) Set max request body size
#   Defaults to undef.
#
class nova::metadata(
  $neutron_metadata_proxy_shared_secret        = undef,
  $metadata_cache_expiration                   = $::os_service_default,
  $local_metadata_per_cell                     = $::os_service_default,
  # DEPRECATED PARAMETERS
  $dhcp_domain                                 = undef,
  $enabled_apis                                = undef,
  $enable_proxy_headers_parsing                = undef,
  $max_request_body_size                       = undef,
) inherits nova::params {

  include ::nova::deps
  include ::nova::db
  include ::nova::keystone::authtoken

  if $enabled_apis != undef {
    warning('enabled_apis parameter is deprecated, use nova::compute::enabled_apis instead.')
  }

  if $enable_proxy_headers_parsing {
    warning('enable_proxy_headers_parsing in ::nova::metadata is deprecated, has no effect \
and will be removed in the future. Please use the one ::nova::api.')
  }
  if $max_request_body_size {
    warning('max_request_body_size in ::nova::metadata is deprecated, has no effect \
and will be removed in the future. Please use the one ::nova::api.')
  }
  if $dhcp_domain {
    warning('dhcp_domain in nova::metadata is deprecated, use nova::dhcp_domain instead.')
  }

  nova_config {
    'api/metadata_cache_expiration':               value => $metadata_cache_expiration;
    'api/local_metadata_per_cell':                 value => $local_metadata_per_cell;
  }

  if ($neutron_metadata_proxy_shared_secret){
    nova_config {
      'neutron/service_metadata_proxy': value => true;
      'neutron/metadata_proxy_shared_secret':
        value => $neutron_metadata_proxy_shared_secret, secret => true;
    }
  } else {
    nova_config {
      'neutron/service_metadata_proxy':       value  => false;
      'neutron/metadata_proxy_shared_secret': ensure => absent;
    }
  }
}
