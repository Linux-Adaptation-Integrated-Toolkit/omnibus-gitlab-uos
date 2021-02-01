# Package defaults

Unless configuration is specified in the `/etc/gitlab/gitlab.rb` file,
the package will assume the defaults as noted below.

## Ports

See the table below for the list of ports that the Omnibus GitLab assigns
by default:

| Component                                             | On by default | Communicates via | Alternative | Connection port                        |
| :----------------------------------------------------: | :------------:| :--------------: | :---------: | :------------------------------------: |
| <a name="gitlab-rails"></a>        GitLab Rails        | Yes           | Port             | X           | 80 or 443                              |
| <a name="gitlab-shell"></a>        GitLab Shell        | Yes           | Port             | X           | 22                                     |
| <a name="postgresql"></a>          PostgreSQL          | Yes           | Socket           | Port (5432) | X                                      |
| <a name="redis"></a>               Redis               | Yes           | Socket           | Port (6379) | X                                      |
| <a name="unicorn"></a>             Unicorn             | Yes           | Socket           | Port (8080) | X                                      |
| <a name="gitlab-workhorse"></a>    GitLab Workhorse    | Yes           | Socket           | Port (8181) | X                                      |
| <a name="nginx-status"></a>        NGINX status        | Yes           | Port             | X           | 8060                                   |
| <a name="prometheus"></a>          Prometheus          | Yes           | Port             | X           | 9090                                   |
| <a name="node-exporter"></a>       Node exporter       | Yes           | Port             | X           | 9100                                   |
| <a name="redis-exporter"></a>      Redis exporter      | Yes           | Port             | X           | 9121                                   |
| <a name="postgres-exporter"></a>   PostgreSQL exporter | Yes           | Port             | X           | 9187                                   |
| <a name="pgbouncer-exporter"></a>  PgBouncer exporter  | No            | Port             | X           | 9188                                   |
| <a name="gitlab-exporter"></a>     GitLab Exporter     | Yes           | Port             | X           | 9168                                   |
| <a name="sidekiq-exporter"></a>    Sidekiq exporter    | Yes           | Port             | X           | 8082                                   |
| <a name="unicorn-exporter"></a>    Unicorn exporter    | No            | Port             | X           | 8083                                   |
| <a name="puma-exporter"></a>       Puma exporter       | No            | Port             | X           | 8083                                   |
| <a name="geo-postgresql"></a>      Geo PostgreSQL      | No            | Socket           | Port (5431) | X                                      |
| <a name="redis-sentinel"></a>      Redis Sentinel      | No            | Port             | X           | 26379                                  |
| <a name="incoming-email"></a>      Incoming email      | No            | Port             | X           | 143                                    |
| <a name="elasticsearch"></a>       Elastic search      | No            | Port             | X           | 9200                                   |
| <a name="gitlab-pages"></a>        GitLab Pages        | No            | Port             | X           | 80 or 443                              |
| <a name="gitlab-registry-web"></a> GitLab Registry     | No*            | Port             | X           | 80, 443 or 5050                        |
| <a name="gitlab-registry"></a>     GitLab Registry     | No            | Port             | X           | 5000                                   |
| <a name="ldap"></a>                LDAP                | No            | Port             | X           | Depends on the component configuration |
| <a name="kerberos"></a>            Kerberos            | No            | Port             | X           | 8443 or 8088                           |
| <a name="omniauth"></a>            OmniAuth            | Yes           | Port             | X           | Depends on the component configuration |
| <a name="smtp"></a>                SMTP                | No            | Port             | X           | 465                                    |
| <a name="remote-syslog"></a>       Remote syslog       | No            | Port             | X           | 514                                    |
| <a name="mattermost"></a>          Mattermost          | No            | Port             | X           | 8065                                   |
| <a name="mattermost-web"></a>      Mattermost          | No            | Port             | X           | 80 or 443                              |
| <a name="pgbouncer"></a>           PgBouncer           | No            | Port             | X           | 6432                                   |
| <a name="consul"></a>              Consul              | No            | Port             | X           | 8300, 8500                             |

Legend:

- `Component` - Name of the component.
- `On by default` - Is the component running by default.
- `Communicates via` - How the component talks with the other components.
- `Alternative` - If it is possible to configure the component to use different type of communication. The type is listed with default port used in that case.
- `Connection port` - Port on which the component communicates.

GitLab also expects a filesystem to be ready for the storage of Git repositories
and various other files.

Note that if you are using NFS (Network File System), files will be carried
over a network which will require, based on implementation, ports `111` and
`2049` to be open.

NOTE: **Note:** In some cases, the GitLab Registry will be automatically enabled by default. Please see [our documentation](https://docs.gitlab.com/ee/administration/packages/container_registry.html) for more details
