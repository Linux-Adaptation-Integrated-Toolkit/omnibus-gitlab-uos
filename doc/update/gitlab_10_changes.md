# GitLab 10 specific changes

From version 10.0 GitLab requires the version of PostgreSQL to be 9.6 or
higher.

Check out [docs on upgrading packaged PostgreSQL server](../settings/database.md#upgrade-packaged-postgresql-server)
for details.

- For users running versions below 8.15 and using PostgreSQL bundled with
  omnibus, this means they will have to first upgrade to 9.5.x, during which
  PostgreSQL will be automatically updated to 9.6.
- Users who are on versions above 8.15, but chose not to update PostgreSQL
  automatically during previous upgrades, can run the following command to
  update the bundled PostgreSQL to 9.6

  ```sh
  sudo gitlab-ctl pg-upgrade
  ```

You can check the PostgreSQL version with:

```sh
/opt/gitlab/embedded/bin/psql --version
```
