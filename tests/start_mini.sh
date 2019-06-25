#!/usr/bin/env bash
set -xeo pipefail

source tests/common.sh

function finish {
  echo "Installation Complete"
}

trap finish EXIT

function run_minikube {
  cd blackknight

  # do we need to adjust the mini[kube|shift] mememory/cpu/disk?
  sed -i "s/hosty.com/$NODE_NAME/" inventory

  echo "Starting minikube"
  ansible-playbook start_minikube.yml

  cd ..

  # Check if minikube status returns true implying it is running
  if [ `minikube status` ]
  then
    echo "Run minikube: Success"
  fi
}

function run_minishift {
  cd blackknight

  # do we need to adjust the mini[kube|shift] mememory/cpu/disk?
  sed -i "s/hostx.com/$NODE_NAME/" inventory

  echo "Starting minishift"
  ansible-playbook start_minishift.yml

  cd ..

  # Check if minishift status returns true implying it is running
  if [ `minishift status` ]
  then
    echo "Run minishift: Success"
  fi
}

function clone_blackknight {
  # Pulling blackknight from git
  git clone https://github.com/cloud-bulldozer/blackknight
  echo "Cloning Blackknight git"
}

function install_mini {
  # Check if minishift or minikube is in the Jenkins node label. If you are running this locally you can 
  # Set the NODE_LABEL variable to minikube or minishift and NODE_NAME to the hostname if running manually.
  # If left blank it should do nothing.

  # Node label is a white space seperated list so we iterate over it
  MINIINSTALL = false 
  for L in $NODE_LABEL
  do
    if [ $L = "minishift" && $MINIINSTALL = "false" ]
    then
      clone_blackknight
      install_minishift
      MINIINSTALL = true
    elif [ $L = "minikube" && $MINIINSTALL = "false" ]
    then
      clone_blackknight
      install_minikube
      MINIINSTALL = true
    fi
  done
}
install_mini
