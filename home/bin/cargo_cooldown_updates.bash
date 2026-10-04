#!/bin/bash

# SPDX-FileCopyrightText: © 2026 hashcatHitman
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

# This script will try to update all crates installed from crates.io that have
# a new version available published at least 14 days ago. This relies on the RSS
# feeds for those crates, which have no rate limit (if I understand correctly),
# but come with the limitation that the feeds only contain updates from the past
# 24 hours, but at least 10 versions (so beyond 24 hours if needed to meet 10
# versions). This script will fail to update a crate that publishes a new
# version often enough that the 10th most recent version is never older than 14
# days (roughly 1 version every 2016 minutes or 33.6 hours, if I'm not
# mistaken).
#
# This script assumes it is impossible for a crate published 14 days ago to have
# dependencies in its lockfile that are newer than 14 days without time travel.
# It is entirely possible this assumption is wrong (is there anything stopping
# me from uploading a lockfile that specifies a version that hasn't been
# released yet? What about a build script that modifies its own lockfile?), but
# it is the best option I have at the moment.
#
# The behavior of this script when crates are installed from a custom registry
# is undefined, because I don't know how those show up when you run
# `cargo install --list`. If you need support for custom registries, feel free
# to open an issue and include the output of `cargo install --list`. If crates
# installed from custom registries are indistinguishable from those installed
# from crates.io, assume support will be difficult or impossible.
#
# In general, this script is only tested to meet my needs. If you experience any
# issues, please let me know!

# Regex guide for parsing `cargo install --list`
#
# Match every kind with:
# ```text
# (?:([a-zA-Z\-]+)\sv([0-9\.]+):)|(?:([a-zA-Z\-]+)\sv([0-9\.]+) \(([a-zA-Z/\-]*)\):)|(?:([a-zA-Z\-]+)\sv([0-9\.]+) \((https://github\.com/[0-9=\?#a-zA-Z/\-]*)\):)
# ```
# Where:
#   Group 1: crates.io crate name
#   Group 2: crates.io crate version
#   Group 3: Locally installed crate name
#   Group 4: Locally installed crate version
#   Group 5: Locally installed crate path
#   Group 6: GitHub crate name
#   Group 7: GitHub crate version
#   Group 8: GitHub crate URL
#
# Match crates.io with:
# ```text
# (?:([a-zA-Z\-]+)\sv([0-9\.]+):)
# ```
# Where:
#   Group 1: crate name
#   Group 2: crate version
#
# Match locally installed with:
# ```text
# (?:([a-zA-Z\-]+)\sv([0-9\.]+) \(([a-zA-Z/\-]*)\):)
# ```
# Where:
#   Group 1: crate name
#   Group 2: crate version
#   Group 3: crate path
#
# Match installed from GitHub with:
# ```text
# (?:([a-zA-Z\-]+)\sv([0-9\.]+) \((https://github\.com/[0-9=\?#a-zA-Z/\-]*)\):)
# ```
# Where:
#   Group 1: crate name
#   Group 2: crate version
#   Group 3: crate URL

set -euo pipefail

# A relative date as the cooldown. Should be understood by `date`.
minimum_release_age="14 days ago"
must_be_before="$(date -d "${minimum_release_age}" +%s)"

installed_crates="$(cargo install --list)"

crates_from_registry="$(echo "${installed_crates}" |
    rg "(?:([a-zA-Z\-]+)\sv([0-9\.]+):)" -r '$1 $2')"

mapfile -t crates_from_registry <<<"${crates_from_registry}"
for crate_ver_pair in "${crates_from_registry[@]}"; do
    IFS=" " read -r crate installed_ver <<<"${crate_ver_pair}"

    recent_versions="$(curl --proto '=https' --tlsv1.3 -sSf \
        https://static.crates.io/rss/crates/"${crate}".xml)"

    date_version_pairs="$(echo "${recent_versions}" | rg -U \
        "(?:<pubDate>(.*)</pubDate>\s*<crates:name>${crate}</crates:name>\s*\
<crates:version>(.*)</crates:version>)" -r '$1`$2')"

    mapfile -t date_version_pairs <<<"${date_version_pairs}"
    for date_ver_pair in "${date_version_pairs[@]}"; do
        IFS="\`" read -r publish_date version <<<"${date_ver_pair}"

        publish_date_timestamp="$(date -d "${publish_date}" +%s)"

        if [[ "${version}" == "${installed_ver}" ]]; then
            echo "Latest acceptable version of ${crate} available is already \
installed!"
            break
        fi

        publish_date_human="$(date -d "@${publish_date_timestamp}" \
            +'%b %d, %Y at %I:%M:%S %p %Z')"

        must_be_before_human="$(date -d "@${must_be_before}" \
            +'%b %d, %Y at %I:%M:%S %p %Z')"

        now="$(date +'%b %d, %Y at %I:%M:%S %p %Z')"

        # TODO: Maybe this should be silenced for crates that don't pass by
        # default?
        echo "${crate} version ${version} was published ${publish_date_human}"

        echo "It needs to have been published before ${must_be_before_human} \
(${minimum_release_age})"

        echo "It is currently ${now}"

        if [[ "${publish_date_timestamp}" -le "${must_be_before}" ]]; then
            read -rp "It is old enough!
crates.io URL: https://crates.io/crates/${crate}/${version}
Current installed: ${crate} ${installed_ver}
Install ${crate} ${version}? (y/N): " answer

            if [[ "${answer,,}" == "y" ]]; then
                cargo auditable install --locked --force --message-format \
                    short --keep-going --profile release "${crate}@${version}"
                break
            else
                echo "Skipping ${crate} version ${version} by user request."
                break
            fi
        else
            echo "Skipping ${crate} version ${version}, too new!"
        fi
    done
done
