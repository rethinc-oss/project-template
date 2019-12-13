class project (
){
  $project = lookup('project')

  $project_class = "::profile::server::${regsubst($project['type'], '/', '::', 'G')}"

   Resource[$project_class]{ $project['name']:
      domain_www => true,
      https => true,
      user => 'sysop',
      user_dir => '/vagrant',
      manage_user_dir => false,
      php_development => true,
      * => delete($project, 'type'),
   }
   mysql::db { "${project['name']}":
      user     => "${project['name']}",
      password => "${project['name']}",
      host     => "%",
      grant    => ['ALL'],
   }
}
