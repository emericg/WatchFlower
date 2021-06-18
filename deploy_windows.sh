#!/usr/bin/env bash

echo "> WatchFlower packager (Windows x86_64)"

export APP_NAME="WatchFlower";
export APP_VERSION=2.0;
export GIT_VERSION=$(git rev-parse --short HEAD);

## CHECKS ######################################################################

if [ ${PWD##*/} != "WatchFlower" ]; then
  echo "This script MUST be run from the WatchFlower/ directory"
  exit 1
fi

## SETTINGS ####################################################################

use_contribs=false
create_package=false
upload_package=false

while [[ $# -gt 0 ]]
do
case $1 in
  -c|--contribs)
  use_contribs=true
  ;;
  -p|--package)
  create_package=true
  ;;
  -u|--upload)
  upload_package=true
  ;;
  *)
  echo "> Unknown argument '$1'"
  ;;
esac
shift # skip argument or value
done

## APP INSTALL #################################################################

#echo '---- Running make install'
#make INSTALL_ROOT=bin/ install;

#echo '---- Installation directory content recap:'
#find bin/;

## DEPLOY ######################################################################

#echo '---- Running windeployqt'
windeployqt bin/ --qmldir qml/

#echo '---- Installation directory content recap:'
#find bin/;

mv bin $APP_NAME-$GIT_VERSION-win64;

## PACKAGE (zip) ###############################################################

if [[ $create_package = true ]] ; then
  echo '---- Compressing package'
  7z a $APP_NAME-$GIT_VERSION-win64.zip $APP_NAME-$GIT_VERSION-win64
fi

## PACKAGE (NSIS) ##############################################################

if [[ $create_package = true ]] ; then
  echo '---- Creating installer'
  mv $APP_NAME-$GIT_VERSION-win64 assets/windows/$APP_NAME
  makensis assets/windows/setup.nsi
  mv assets/windows/*.exe $APP_NAME-$APP_VERSION-win64.exe
fi

## UPLOAD ######################################################################

if [[ $upload_package = true ]] ; then
  echo '---- Uploading to transfer.sh'
  curl --upload-file $APP_NAME*.zip https://transfer.sh/$APP_NAME-git.$GIT_VERSION-win64.zip;
  echo '\n'
  curl --upload-file $APP_NAME*.exe https://transfer.sh/$APP_NAME-git.$GIT_VERSION-win64.exe;
  echo '\n'
fi