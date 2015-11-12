# Install pip
python-pip:
  pkg.installed

# Install dependencies for pyOpenSsl
python-dev:
  pkg.installed
libffi-dev:
  pkg.installed
libssl-dev:
  pkg.installed

# Install salt-api
salt-api_pkg:
  pkg:
    - name: salt-api
    - installed

# Install PyOpenSsl for creation of SSL certs
pyopenssl:
  pip.installed:
    - require:
      - pkg: python-pip
      - pkg: python-dev
      - pkg: libffi-dev
      - pkg: libssl-dev
    - require_in:
      - cmd: salt-call --local tls.create_self_signed_cert

# Install salt-pepper module, https://github.com/saltstack/pepper
salt-pepper:
  pip.installed:
    - require:
      - pkg: python-pip

# Copy salt-api conf
/etc/salt/master.d/salt-api.conf:
  file.managed:
    - source: salt://salt-api/files/salt-api.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: salt-api

# Copy salt/master
/etc/salt/master:
  file.managed:
    - source: salt://salt-api/files/master
    - user: root
    - group: root
    - mode: 644

# create user for salt-api
saltdev:
  user.present:
    - password: $1$xyz$MvaCwgVdoByCnms7NSXwi1

salt-call --local tls.create_self_signed_cert:
  cmd.run:
    - creates: /etc/pki/tls/certs/localhost.key
    - creates: /etc/pki/tls/certs/localhost.crt

salt-master:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - user: saltdev
      - file: /etc/salt/master.d/salt-api.conf
      - file: /etc/salt/master

salt-api:
  service.running:
    - enable: True
    - reload: True
    - require:
        - file: /etc/salt/master.d/salt-api.conf
    - watch:
        - file: /etc/salt/master.d/salt-api.conf
