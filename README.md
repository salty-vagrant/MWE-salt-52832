# MWE-salt-52832
MWE supporting salt issue 52832

# Run through

```bash
vagrant@debian-10:~$ sudo -i
root@debian-10:~# salt-call pillar-items
local:
    ----------
    base:
        ----------
        roles:
            - vim
    packages:
        - vim
```

This is as expected given the `pillarenv: base` in `/etc/salt/minion`.

```bash
root@debian-10:~# salt-call pillar-items pillarenv=project
local:
    ----------
    base:
        ----------
        roles:
            - vim
    packages:
        - vim
    project:
        ----------
        roles:
            - git
```

This is wrong. `project` merged with `base` where it should have replaced it.

Edit `/etc/salt/minion` to replace `pillarenv: base` with `pillarenv: project`.

```bash
root@debian-10:~# salt-call pillar-items
local:
    ----------
    packages:
        - git
    project:
        ----------
        roles:
            - git
```

This is as expected (and is what the previous command *should* have returned).

Remove the `pillarenv: project` from `/etc/salt/minion`.

```bash
root@debian-10:~# salt-call pillar-items
local:
    ----------
    base:
        ----------
        roles:
            - vim
    packages:
        - git
        - vim
    project:
        ----------
        roles:
            - git
```

So far, so good. But...

```bash
salt-call pillar.get packages
local:
```

Wrong. Running the command with loggging (only relevant lines shown).
```bash
root@debian-10:~# salt-call pillar.get packages -l debug
[DEBUG   ] LazyLoaded stack.ext_pillar
[DEBUG   ] Config: /srv/stack/core.cfg
[DEBUG   ] LazyLoaded pillar.get
[DEBUG   ] Interesting []
[DEBUG   ] Interesting []
[DEBUG   ] Interesting []
[INFO    ] Ignoring pillar stack template "personal/core.sls": can't find from root dir "/srv/stack"
[INFO    ] Ignoring pillar stack template "project/core.sls": can't find from root dir "/srv/stack"
[DEBUG   ] YAML: basedir=/srv/stack, path=/srv/stack/base/core.sls
[INFO    ] Ignoring pillar stack template "/srv/stack/base/core.sls": Can't parse as a valid yaml dictionary
[DEBUG   ] LazyLoaded jinja.render
[DEBUG   ] LazyLoaded yaml.render
[DEBUG   ] LazyLoaded pillar.get
[DEBUG   ] LazyLoaded direct_call.execute
[DEBUG   ] LazyLoaded nested.output
local:
```

Lines 87-89 are output from the rendering of the pillar stack `config.cfg` and show that the pillar data for `base:roles` and `project:roles` are not avialable.

But...

```bash
salt-call pillar.get base:roles
local:
    - vim
```

So the entry *is* available.

Try specifying an environment.

```bash
pillar.get packages pillarenv=base -l debug
[DEBUG   ] LazyLoaded stack.ext_pillar
[DEBUG   ] Config: /srv/stack/core.cfg
[DEBUG   ] LazyLoaded pillar.get
[DEBUG   ] Interesting []
[DEBUG   ] Interesting ['git']
[DEBUG   ] Interesting ['vim']
[INFO    ] Ignoring pillar stack template "personal/core.sls": can't find from root dir "/srv/stack"
[INFO    ] Ignoring pillar stack template "project/core.sls": can't find from root dir "/srv/stack"
[DEBUG   ] YAML: basedir=/srv/stack, path=/srv/stack/project/roles/git.sls
[DEBUG   ] YAML: basedir=/srv/stack, path=/srv/stack/base/core.sls
[INFO    ] Ignoring pillar stack template "/srv/stack/base/core.sls": Can't parse as a valid yaml dictionary
[DEBUG   ] YAML: basedir=/srv/stack, path=/srv/stack/base/roles/vim.sls
[DEBUG   ] LazyLoaded nested.output
local:
    - git
    - vim
```

So specifying the `pillarenv` on the command line causes the `base:roles` *and* the `project:roles` to be available, which is wrong as only the `base:roles` should be available.

Finally, try with `pillarenv: base` in the `/etc/salt/minion` configuration.

```bash
root@debian-10:~# salt-call pillar.get packages -l debug
[DEBUG   ] LazyLoaded stack.ext_pillar
[DEBUG   ] Config: /srv/stack/core.cfg
[DEBUG   ] LazyLoaded pillar.get
[DEBUG   ] Interesting []
[DEBUG   ] Interesting []
[DEBUG   ] Interesting []
[INFO    ] Ignoring pillar stack template "personal/core.sls": can't find from root dir "/srv/stack"
[INFO    ] Ignoring pillar stack template "project/core.sls": can't find from root dir "/srv/stack"
[DEBUG   ] YAML: basedir=/srv/stack, path=/srv/stack/base/core.sls
[INFO    ] Ignoring pillar stack template "/srv/stack/base/core.sls": Can't parse as a valid yaml dictionary
[DEBUG   ] LazyLoaded jinja.render
[DEBUG   ] LazyLoaded yaml.render
[DEBUG   ] LazyLoaded pillar.get
[DEBUG   ] LazyLoaded direct_call.execute
[DEBUG   ] LazyLoaded nested.output
local:
```

And it's broken again. No pillar data seems to be available to the pillar stack resulting in `packages` not being set.
