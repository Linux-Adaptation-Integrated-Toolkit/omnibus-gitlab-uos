# Package information

The Omnibus GitLab package is bundled with all dependencies required for GitLab
to function correctly. More details can be found
at [bundling dependencies document](omnibus_packages.md).

## Licenses

See [licensing](licensing.md)

## Defaults

The Omnibus GitLab package requires various configuration to get the
components in working order.
If the configuration is not provided, the package will use the default
values assumed in the package.

These defauts are noted in the package [defaults document](defaults.md).

## Checking the versions of bundled software

Once the Omnibus GitLab package is installed, all versions of the bundled
libraries are located in `/opt/gitlab/version-manifest.txt`.

If you don't have the package installed, you can always check the Omnibus GitLab
[source repository](https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master), specifically the
[config directory](https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/config).

For example, if you take a look at the `8-6-stable` branch, you can conclude that
8.6 packages were running [Ruby 2.1.8](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/8-6-stable/config/projects/gitlab.rb#L48).
Or, that 8.5 packages were bundled with [NGINX 1.9.0](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/8-5-stable/config/software/nginx.rb#L20).

## Signatures of GitLab, Inc. provided packages

Documentation on package signatures can be found at [Signed Packages](signed_packages.md)

## Checking for newer configuration options on upgrade

Configuration file in `/etc/gitlab/gitlab.rb` is created on initial installation
of the Omnibus GitLab package. On subsequent package upgrades, the configuration
file is not updated with new configuration. This is done in order to avoid
accidental overwrite of user configuration provided in `/etc/gitlab/gitlab.rb`.

New configuration options are noted in the
[`gitlab.rb.template` file](https://gitlab.com/gitlab-org/omnibus-gitlab/raw/master/files/gitlab-config-template/gitlab.rb.template).

The Omnibus GitLab package also provides convenience command which will
compare the existing user configuration with the latest version of the
template contained in the package.

To view a diff between your configuration file and the latest version, run:

```shell
sudo gitlab-ctl diff-config
```

_**Note:** This command is available from GitLab 8.17_

**Important:** If you are copy-pasting the output of this command into your
`/etc/gitlab/gitlab.rb` configuration file, make sure to omit leading `+` and `-`
on each line.

## Init system detection

Omnibus GitLab will attempt to query the underlaying system in order to
check which init system it uses.
This manifests itself as a `WARNING` during the `sudo gitlab-ctl reconfigure`
run.

Depending on the init system, this `WARNING` can be one of:

```plaintext
/sbin/init: unrecognized option '--version'
```

when the underlying init system *IS NOT* upstart.

```plaintext
  -.mount loaded active mounted   /
```

when the underlying init system *IS* systemd.

These warnings _can be safely ignored_. They are not suppressed because this
allows everyone to debug possible detection issues faster.
