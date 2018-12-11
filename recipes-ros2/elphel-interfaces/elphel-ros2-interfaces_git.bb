# Copied from https://github.com/bmwcarit/meta-ros.git:
#     meta-ros/recipes-ros2/example-interfaces

SUMMARY = "Contains message and service definitions"
HOMEPAGE = "https://git.elphel.com/Elphel/ros2-interfaces.git"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

DEPENDS = " \
    rosidl-default-generators \
    rosidl-cmake \
    rosidl-parser \
    rosidl-generator-c \
    rosidl-generator-cpp \
    rosidl-generator-py \
    rmw-implementation-cmake \
    rmw \
    rmw-fastrtps-cpp \
    rosidl-typesupport-c \
    rosidl-typesupport-cpp \
    python-cmake-module \
"

#SRCREV = "2b5d7f2621e207b87d7d6cb9fd5ab4f7e92cad99"
SRCREV = "d046f7552724a6b0ca730ce6c69ee25e8849d9c8"
SRC_URI = "git://git.elphel.com/Elphel/ros2-interfaces.git;protocol=https"

inherit ament pythonpath-insane

S = "${WORKDIR}/git"

ROS_BPN = "elphel_interfaces"
