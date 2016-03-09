name             'mo_reverse_proxy'
maintainer       'Christian A. Rodriguez & Leandro Di Tommaso'
maintainer_email 'chrodriguez@gmail.com leandro.ditommaso@mikroways.net'
license          'MIT'
description      'Installs/Configures mo_reverse_proxy'
long_description 'Installs/Configures mo_reverse_proxy'

version          '1.2.11'

depends 'certificate',            '~>0.6.3'
depends 'mo_application',         '~>1.1.1'
depends 'mo_monitoring_client',   '~>1.0.12'
depends 'mo_collectd',            '~>1.0.5'
depends 'rsyslog',                '>= 0.0'
