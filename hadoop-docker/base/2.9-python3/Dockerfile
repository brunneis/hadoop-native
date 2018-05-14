# Hadoop (Vanilla) for Orchestration on CentOS 7 with native libraries for x86_64.
# Copyright (C) 2018 Rodrigo Martínez <dev@brunneis.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM brunneis/hadoop-64-passive:2.9.0
MAINTAINER "Rodrigo Martínez" <dev@brunneis.com>

################################################
# HADOOP + PYTHON 3
################################################

RUN \
    yum -y update && yum clean all \
    && yum -y install python36 \
    && ln -sf /usr/bin/python36 /usr/bin/python3 \
    && curl https://bootstrap.pypa.io/get-pip.py | python - \
    && yum clean all

# The container stays idle
CMD bash --login -i
