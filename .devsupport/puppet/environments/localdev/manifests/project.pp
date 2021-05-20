class project (
){
  $project = lookup('project')

  $project_class = "::profile::server::${regsubst($project['type'], '/', '::', 'G')}"
  $vagrant_user = 'sysop'
  $domain_name = "${project['name']}.localdev"

  if ('aws::s3' in $project['services']) {
    $php_env_vars = {
      'AWS_S3_ENDPOINT' => 'http://localhost:10001',
      'AWS_S3_BUCKET'   => $domain_name,
    }
  } else {
    $php_env_vars = {}
  }

  Resource[$project_class]{ $domain_name:
    domain_www      => false,
    https           => true,
    user            => $vagrant_user,
    user_dir        => '/home/sysop',
    manage_user_dir => false,
    webroot_parent_dir  => '/vagrant',
    php_development => true,
    php_env_vars    => $php_env_vars,
    *               => delete($project, ['type', 'services']),
  }

  mysql::db { $domain_name:
    user     => $domain_name,
    password => $domain_name,
    host     => '%',
    grant    => ['ALL'],
  }

  if ('aws::s3' in $project['services']) {
    $aws_cred_directory = '/home/sysop/.aws'
    $aws_cred_file = '/home/sysop/.aws/credentials'
    file{ $aws_cred_directory:
      ensure => 'directory',
      owner  => $vagrant_user,
      group  => $vagrant_user,
      mode   => '0700',
    }
    -> file{ $aws_cred_file:
      ensure  => 'present',
      owner   => $vagrant_user,
      group   => $vagrant_user,
      mode    => '0600',
      content => "[default]\naws_access_key_id = minioadmin\naws_secret_access_key = minioadmin\n",
    }

    exec { 'setup:add_project_bucket':
      command => "/opt/minio/mcc mb local/${$domain_name}",
      path    => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      unless  => "/opt/minio/mcc ls local | /bin/grep ${$domain_name}",
    }
  }
}
