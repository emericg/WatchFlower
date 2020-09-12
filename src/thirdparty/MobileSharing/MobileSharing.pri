QT += core

MOBILESHARING_VERSION = 0.2

SOURCES += $${PWD}/SharingUtils.cpp \
           $${PWD}/SharingApplication.cpp
HEADERS += $${PWD}/SharingUtils.h \
           $${PWD}/SharingApplication.h
INCLUDEPATH += $${PWD}

android {
    QT += androidextras

    SOURCES += $${PWD}/SharingUtils_android.cpp
    HEADERS += $${PWD}/SharingUtils_android.h

    # Add this line to the dependencies {} section of build.gradle file:
    #compile 'com.android.support:support-v4:25.3.1'

    # These files are from the parent project:
    #ANDROID_PACKAGE_SOURCE_DIR = $${PWD}/android
    #OTHER_FILES += $${PWD}/src/com/minivideo/infos/QShareActivity.java \
    #               $${PWD}/src/com/minivideo/utils/QShareUtils.java \
    #               $${PWD}/src/com/minivideo/utils/QSharePathResolver.java

    # Rename these to match your project:
    #com/minivideo/utils
    #com.minivideo.infos
    #com_minivideo_infos
}

ios {
    OBJECTIVE_SOURCES += $${PWD}/SharingUtils_ios.mm \
                         $${PWD}/docviewcontroller_ios.mm

    HEADERS += $${PWD}/SharingUtils_ios.h \
               $${PWD}/docviewcontroller_ios.h
}
