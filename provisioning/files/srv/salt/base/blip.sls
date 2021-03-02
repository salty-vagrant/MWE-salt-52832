install-packages:
  pkg.installed:
    - pkgs: {{ salt['pillar.get']('packages') }}

