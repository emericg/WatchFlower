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

    # Add this line to the dependencies {} section of 'build.gradle' file:
    #implementation 'androidx.appcompat:appcompat:1.1.0'
    #implementation 'androidx.core:core:1.1.0'

    # And this line in 'gradle.properties' file:
    #android.useAndroidX=true

    # These files are from the parent project:
    #ANDROID_PACKAGE_SOURCE_DIR = $${PWD}/android
    #OTHER_FILES += $${PWD}/src/com/watchflower/infos/QShareActivity.java \
    #               $${PWD}/src/com/watchflower/utils/QShareUtils.java \
    #               $${PWD}/src/com/watchflower/utils/QSharePathResolver.java

    # Rename these to match your project:
    #com/emeric/utils
    #com.emeric.watchflower
    #com_emeric_watchflower
}

ios {
    OBJECTIVE_SOURCES += $${PWD}/SharingUtils_ios.mm \
                         $${PWD}/docviewcontroller_ios.mm

    HEADERS += $${PWD}/SharingUtils_ios.h \
               $${PWD}/docviewcontroller_ios.h
}
