# Deprecation policy

The Omnibus GitLab packages come with number of different libraries and services which offers users plethora of configuration options.

As libraries and services get updated, their configuration options change
and become obsolete. To increase maintainability and preserve a working
setup, various configuration requires removal.

## Configuration deprecation

### Policy

The Omnibus GitLab package will retain configuration for at least **one major**
version. We cannot guarantee that deprecated configuration
will be available in the next major release. See [example](#example) for more details.

### Notice

If the configuration becomes obsolete, we will announce the deprecation:

- via release blog post on `https://about.gitlab.com/blog/`. The blog post item
  will contain the deprecation notice together with the target removal date.
- via installation/reconfigure output (if applicable).
- via official documentation on `https://docs.gitlab.com/`. The documentation update will contain the corrected syntax (if applicable) or a date of configuration removal.

### Procedure

This section lists steps necessary for deprecating and removing configuration.

We can differentiate two different types of configuration:

- Sensitive: Configuration that can cause major service outage ( Data integrity,
  installation integrity, preventing users from reaching the installation, etc.)
- Regular: Configuration that can make a feature unavailable but still makes the installation useable ( Change in default project/group settings, miscommunication with other components and similar )

We also need to differentiate deprecation and removal procedure.

#### Deprecating configuration

Deprecation procedure is similar for both `sensitive` and `regular` configuration. The only difference is in the removal target date.

Common steps:

1. Create an issue at the [Omnibus GitLab issue tracker](https://gitlab.com/gitlab-org/omnibus-gitlab/issues) with details on deprecation type and other necessary information. Apply the label `deprecation`.
1. Decide on the removal target for the deprecated configuration
1. Formulate deprecation notice for each item as noted in [Notice section](#notice)

Removal target:

For regular configuration, removal target should always be the date of the **next major** release. If the date is not known, you can reference the next major version.

For sensitive configuration things are a bit more complicated.
We should aim to not remove sensitive configuration in the *next major* release if the next major release is 2 minor releases away (This number is chosen to match our security backport release policy).

See the table below for some examples:

| Config. type | Deprecation announced | Final minor release | Remove |
| -------- | -------- | -------- | -------- |
| Sensitive | 10.1.0   | 10.9.0   | 11.0.0 |
| Sensitive | 10.7.0   | 10.9.0   | 12.0.0 |
| Regular | 10.1.0 | 10.9.0 | 11.0.0 |
| Regular | 10.8.0 | 10.9.0 | 11.0.0 |

#### Removing configuration

When deprecation is announced and removal target set, the milestone for the issue
should be changed to match the removal target version.

The final comment in the issue **has to have**:

1. Text snippet for the release blog post section
1. Documentation MR ( or snippet ) for introducing the change
1. WIP MR removing the configuration OR details on what needs to be done. See [Adding deprecation messages](../development/adding-deprecation-messages.md) for more on this

## Example

User configuration available in `/etc/gitlab/gitlab.rb` was introduced in GitLab version 10.0, `gitlab_rails['configuration'] = true`. In GitLab version 10.4.0, a new change was introduced that requires rename of this configuration option. New configuration option is `gitlab_rails['better_configuration'] = true`. Development team will translate the old configuration into new one
and trigger a deprecation procedure.

This means that these two configuration
options will both be valid through GitLab version 10. In other words,
if you still have `gitlab_rails['configuration'] = true` set in GitLab 10.8.0
the feature will continue working the same way as if you had `gitlab_rails['better_configuration'] = true` set.
However, setting the old version of configuration will print out a deprecation
notice at the end of installation/upgrade/reconfigure run.

With GitLab 11, `gitlab_rails['configuration'] = true` will no longer work and you will have to manually change the configuration in `/etc/gitlab/gitlab.rb` to the new valid config.
**Note** If this configuration option is sensitive and can put integrity of the installation or
data in danger, installation/upgrade will be aborted.
