#!/bin/bash

gitlab_version="17.0.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="e8578507c0f14253a7d702e8305c9689742da89e8ff25c1c43f485f64d7a0bb3"
gitlab_x86_64_bullseye_source_sha256="ac33d4abf6856067c26b74ab263819db80111a1a0dd5e159e2a2a8f865b4f67f"
gitlab_x86_64_buster_source_sha256="31790cddd976a803a79dcb2ab62a0420e223c0ac80f23a91684cbe21b513aa09"

gitlab_arm64_bookworm_source_sha256="a885abfbf62f1993d00fc639a3aa60ce577fce9cb099f87bf48530d4f9fa530d"
gitlab_arm64_bullseye_source_sha256="7e8b3210983b1260cda9ea935dc517c71485da0040f8a2964fc4bee60ca20648"
gitlab_arm64_buster_source_sha256="41a82d681025493103b9aaae5d701576fb3ba34d16c28696e0b2a8148790101e"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="15ab0c73b8708aeba897d1c7d55f5b487ff6996c66bfb0f6b115075dee274c6a"
gitlab_arm_buster_source_sha256="30dd1a11f50de3b9c2e73cbbb833a53b23d1e62db63ac6c9c29dfa000132a04c"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

# Evaluating indirect/reference variables https://mywiki.wooledge.org/BashFAQ/006#Indirection 
# ref=gitlab_${architecture}_${gitlab_debian_version}_source_sha256
# gitlab_source_sha256=${!ref}

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm_bookworm_source_sha256
		if [ -z "$gitlab_arm_bookworm_source_sha256" ]
		then
			gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
		fi
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	fi
fi

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	ynh_backup_if_checksum_is_different --file="$config_path/gitlab.rb"
	cat <<EOF >> "$config_path/gitlab.rb"
# Last chance to fix Gitlab
package['modify_kernel_parameters'] = false
EOF
	ynh_store_file_checksum --file="$config_path/gitlab.rb"
}
