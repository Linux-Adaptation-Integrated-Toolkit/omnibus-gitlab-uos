# Package Licensing

## License

While GitLab itself is MIT, the Omnibus GitLab sources are licensed under the Apache-2.0.

## License file location

Starting with version 8.11, the Omnibus GitLab package contains license
information of all software that is bundled within the package.

After installing the package, licenses for each individual bundled library
can be found in `/opt/gitlab/LICENSES` directory.

There is also one `LICENSE` file which contains all licenses compiled together.
This compiled license can be found in `/opt/gitlab/LICENSE` file.

Starting with version 9.2, the Omnibus GitLab package ships a
`dependency_licenses.json` file containing version and license information of
all bundled software, including software libraries, Ruby gems that the rails
application uses, and JavaScript libraries that is required for the frontend
components. This file, being in JSON format, is easily machine parseable and
can be used for automated checks or validations. The file may be found at
`/opt/gitlab/dependency_licenses.json`.

Starting with version 11.3, we have also made the license information available
online, at: <http://gitlab-org.gitlab.io/omnibus-gitlab/licenses.html>

## Checking licenses

The Omnibus GitLab package is made up of many pieces of software, comprising code
that is covered by many different licenses. Those licenses are provided and
compiled as stated above.

Starting with version 8.13, GitLab has placed an additional step into
Omnibus GitLab. The `license_check` step calls
`lib/gitlab/tasks/license_check.rake`, which checks the compiled `LICENSE` file
against the current list of approved and questionable licenses as denoted in the
arrays at the top of the script. This script will output one of `Good`,
`Unknown` or `Check` for each piece of software that is a part of the
Omnibus GitLab package.

- `Good`: denotes a license that is approved for all usage types, within GitLab and
  Omnibus GitLab.
- `Unknown`: denotes a license that is not recognized in the list of 'good' or 'bad',
  which should be immediately reviewed for implications of use.
- `Check`: denotes a license that has the potential be incompatible with GitLab itself,
  and thus should be checked for how it is used as a part of the Omnibus GitLab package
  to ensure compliance.

This list is currently sourced from the [GitLab development documentation on licensing](https://gitlab.com/gitlab-org/gitlab-foss/blob/master/doc/development/licensing.md).
However, due to the nature of the Omnibus GitLab package the licenses may not apply
in the same way. Such as with `git` and `rsync`. See the [GNU License FAQ](https://www.gnu.org/licenses/gpl-faq.en.html#MereAggregation)

## License acknowledgements

### libjpeg-turbo - BSD 3-clause license

This software is based in part on the work of the Independent JPEG Group.

## Trademark Usage

Within the GitLab documentation, reference to third party technology(ies) and/or trademarks of third party entities, may be made. The inclusion of reference to third party technology and/or entities is solely for the purposes of example(s) of how GitLab software may interact with, or be used in conjunction with, such third party technology.
All trademarks, materials, documentation, and other intellectual property remain the property of any/all such third party.

### Trademark Requirements

Use of GitLab Trademarks must be in compliance with the standards set forth in [our guidelines](https://about.gitlab.com/handbook/marketing/brand-and-digital-design/#gitlab-trademark--logo-guidelines) (as updated from time to time).
CHEF® and all Chef marks are owned by Chef Software, Inc. and must be used in accordance with the [Chef Trademark policy](https://www.chef.io/trademark-policy/) (as updated from time to time) located at.

When using a GitLab or 3rd party trademark in documentation, include the (R) symbol in the first instance, for example, "Chef(R) is used for configuring...." You may omit the symbol in subsequent instances.

If a trademark owner requires a particular notice or trademark requirement, such notice or requirement should be stated above.
