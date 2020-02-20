node default {
   include ::profile::server::base
   include ::profile::server::mysql
   include ::profile::server::golang
   include ::profile::server::pebble
   include ::profile::server::nginx
   include ::profile::server::phpfpm
   include ::profile::server::mailhog
   include ::profile::server::minio

   include ::project
}
