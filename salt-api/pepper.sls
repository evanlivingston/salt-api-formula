# Install salt-pepper module, https://github.com/saltstack/pepper
salt-pepper:
  pip.installed:
    - require:
      - pkg: python-pip
