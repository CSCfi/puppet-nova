# == Class: nova::metadata
#
# Setup and configure the Nova metadata API endpoint for wsgi
#
# === Parameters
#
# [*enabled_apis*]
#   (optional) A list of apis to enable
#   Defaults to ['metadata'] in case of wsgi
#
# [*neutron_metadata_proxy_shared_secret*]
#   (optional) Shared secret to validate proxies Neutron metadata requests
#   Defaults to undef
#
# [*enable_proxy_headers_parsing*]
#   (optional) This determines if the HTTPProxyToWSGI
#   middleware should parse the proxy headers or not.(boolean value)
#   Defaults to $::os_service_default
#
# [*metadata_cache_expiration*]
#   (optional) This option is the time (in seconds) to cache metadata.
#   Defaults to $::os_service_default
#
# DEPRECATED
#
# [*vendordata_jsonfile_path*]
#   (optional) Represent the path to the data file.
#   Cloud providers may store custom data in vendor data file that will then be
#   available to the instances via the metadata service, and to the rendering of
#   config-drive. The default class for this, JsonFileVendorData, loads this
#   information from a JSON file, whose path is configured by this option
#   Defaults to undef.
#
# [*vendordata_providers*]
#   (optional) vendordata providers are how deployers can provide metadata via
#   configdrive and metadata that is specific to their deployment. There are
#   currently two supported providers: StaticJSON and DynamicJSON.
#   Defaults to undef.
#
# [*vendordata_dynamic_targets*]
#   (optional) A list of targets for the dynamic vendordata provider. These
#   targets are of the form <name>@<url>.
#   Defaults to undef.
#
# [*vendordata_dynamic_connect_timeout*]
#   (optional) Maximum wait time for an external REST service to connect.
#   Defaults to undef.
#
# [*vendordata_dynamic_read_timeout*]
#   (optional) Maximum wait time for an external REST service to return data
#   once connected.
#   Defaults to undef.
#
# [*vendordata_dynamic_failure_fatal*]
#   (optional) Should failures to fetch dynamic vendordata be fatal to
#   instance boot?
#   Defaults to undef.
#
#  [*vendordata_dynamic_auth_auth_type*]
#   (optional) Authentication type to load for vendordata dynamic plugins.
#   Defaults to undef.
#
#  [*vendordata_dynamic_auth_auth_url*]
#   (optional) URL to use for authenticating.
#   Defaults to undef.
#
#  [*vendordata_dynamic_auth_os_region_name*]
#   (optional) Region name for the vendordata dynamic plugin credentials.
#   Defaults to undef.
#
#  [*vendordata_dynamic_auth_password*]
#   (optional) Password for the vendordata dynamic plugin credentials.
#   Defaults to undef.
#
#  [*vendordata_dynamic_auth_project_domain_name*]
#   (optional) Project domain name for the vendordata dynamic plugin
#    credentials.
#   Defaults to undef.
#
#  [*vendordata_dynamic_auth_project_name*]
#   (optional) Project name for the vendordata dynamic plugin credentials.
#   Defaults to undef.
#
#  [*vendordata_dynamic_auth_user_domain_name*]
#   (optional) User domain name for the vendordata dynamic plugin credentials.
#   Defaults to undef.
#
#  [*vendordata_dynamic_auth_username*]
#   (optional) User name for the vendordata dynamic plugin credentials.
#   Defaults to undef.
#
class nova::metadata(
  $enabled_apis                                = 'metadata',
  $neutron_metadata_proxy_shared_secret        = undef,
  $enable_proxy_headers_parsing                = $::os_service_default,
  $metadata_cache_expiration                   = $::os_service_default,
  # DEPRECATED PARAMETERS
  $vendordata_jsonfile_path                    = undef,
  $vendordata_providers                        = undef,
  $vendordata_dynamic_targets                  = undef,
  $vendordata_dynamic_connect_timeout          = undef,
  $vendordata_dynamic_read_timeout             = undef,
  $vendordata_dynamic_failure_fatal            = undef,
  $vendordata_dynamic_auth_auth_type           = undef,
  $vendordata_dynamic_auth_auth_url            = undef,
  $vendordata_dynamic_auth_os_region_name      = undef,
  $vendordata_dynamic_auth_password            = undef,
  $vendordata_dynamic_auth_project_domain_name = undef,
  $vendordata_dynamic_auth_project_name        = undef,
  $vendordata_dynamic_auth_user_domain_name    = undef,
  $vendordata_dynamic_auth_username            = undef,
) inherits nova::params {

  include ::nova::deps
  include ::nova::db
  include ::nova::keystone::authtoken

  if (length(delete_undef_values([$vendordata_jsonfile_path,
                                  $vendordata_providers,
                                  $vendordata_dynamic_targets,
                                  $vendordata_dynamic_connect_timeout,
                                  $vendordata_dynamic_read_timeout,
                                  $vendordata_dynamic_failure_fatal,
                                  $vendordata_dynamic_auth_auth_type,
                                  $vendordata_dynamic_auth_auth_url,
                                  $vendordata_dynamic_auth_os_region_name,
                                  $vendordata_dynamic_auth_password,
                                  $vendordata_dynamic_auth_project_domain_name,
                                  $vendordata_dynamic_auth_project_name,
                                  $vendordata_dynamic_auth_user_domain_name,
                                  $vendordata_dynamic_auth_username])) > 0) {
    warning('Vendordata parameters are deprecated in nova::metadata, nova::vendordata should be used instead.')
  }
  class { '::nova::vendordata':
    vendordata_caller => 'metadata',
  }

  nova_config {
    'DEFAULT/enabled_apis':                        value => $enabled_apis;
    'api/metadata_cache_expiration':               value => $metadata_cache_expiration;
  }

  oslo::middleware {'nova_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
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
