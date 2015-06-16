# == Class: digital_signage
#
# Manages digital signage on Ubuntu computOrs
#
# === Parameters
#
# [base_url]
#   Base url for which digital sign web page is prepended.
#   Works out like base_url/<portrait or landscape depending on orientation>.php
#   Check stumpwmrc for the details
#   If this class ever gets used by other departments this will change slightly
#   < http://www.dtc.umn.edu/dtcdigitalsigndisplay/ | whatever else >
#   Default: http://www.dtc.umn.edu/dtcdigitalsigndisplay/
#
# [screen_rotation]
#   Which way the screen should be rotated by xrandr
#   Options include normal, left, right, and inverted
#   Default: normal
#
#
# === Examples
#
#  class {'digital-signage':
#     base_url => 'base url for digital sign',
#  }
#
# === Authors
#
# Brian Auron <auro0004@umn.edu>
# Evan Niessen-Derry <nies0046@umn.edu>
#
# === Copyright
#
# Copyright 2014 Math Systems Staff, University of Minnesota.
#
class digital_signage(
  $base_url = 'base_url_here/',
  $screen_rotation = 'normal'
) {

  cron { 'reboot':
    ensure   => present,
    name     => 'reboot',
    command  => '/sbin/reboot',
    user     => root,
    hour     => 2,
    minute   => 0,
    month    => absent,
    monthday => absent
  }

  file {'/etc/default/grub':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/digital_signage/etc-default-grub',
  }

  file {'/etc/init/zero-grub-timeouts.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/digital_signage/etc-init-zero-grub-timeouts.conf',
  }

  file {'/etc/init/puppet-run.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/digital_signage/etc-init-puppet-run.conf',
  }

  file {'/etc/init/lightdm.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/digital_signage/etc-init-lightdm.conf',
  }

  package { 'conkeror':
    ensure   => installed,
    name     => 'conkeror',
  }

  package { 'stumpwm':
    ensure  => installed,
    name    => 'stumpwm',
  }

  file { 'stumpwm.desktop':
    path    =>  '/usr/share/xsessions/stumpwm.desktop',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/digital_signage/stumpwm.desktop',
  }

  file { '10-monitor.conf':
    path    => '/usr/share/X11/xorg.conf.d/10-monitor.conf',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/digital_signage/10-monitor.conf',
  }

  file { '/etc/lightdm/lightdm.conf':
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/digital_signage/etc-lightdm-lightdm.conf',
  }

  group { 'autologin':
    ensure  => present,
    name    => 'autologin',
  }

  user { 'signage':
    ensure      => present,
    name        => 'signage',
    groups      => ['autologin'],
    shell       => '/bin/bash',
    home        => '/home/signage',
    managehome  => true
  }

  file { 'conkerorrc':
    path    => '/home/signage/.conkerorrc',
    mode    => '0600',
    owner   => 'signage',
    group   => 'signage',
    source  => 'puppet:///modules/digital_signage/conkerorrc',
  }

  file { 'stumpwmrc':
    path      => '/home/signage/.stumpwmrc',
    mode      => '0644',
    owner     => 'signage',
    group     => 'signage',
    content   => template('digital_signage/stumpwmrc.erb'),
  }

  file { 'dmrc':
    path    => '/home/signage/.dmrc',
    mode    => '0644',
    owner   => 'signage',
    group   => 'signage',
    source  => 'puppet:///modules/digital_signage/dmrc',
  }

  Package['conkeror'] -> Package['stumpwm'] -> Group['autologin']
  Group['autologin'] -> User['signage']
  User['signage'] -> File['conkerorrc']
  User['signage'] -> File['stumpwmrc']
  File['conkerorrc'] -> File['/etc/init/puppet-run.conf']
  File['/etc/init/puppet-run.conf'] -> File['/etc/lightdm/lightdm.conf']
  File['/etc/lightdm/lightdm.conf'] -> File['stumpwm.desktop']

}
# vim: et ts=2 sw=2
